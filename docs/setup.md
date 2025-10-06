# Setup Guide

## GitHub Organization Setup

### Organization Secrets (Recommended)

Configure secrets once at the organization level. All repositories scaffolded from this platform will automatically have access.

**Setup:**
1. Go to your GitHub Organization → Settings → Secrets and variables → Actions
2. Add organization secrets for your publishing needs:
   - **`NPM_TOKEN`** - For publishing to npm registry (Node.js projects)
   - **`PYPI_TOKEN`** - For publishing to PyPI (Python projects)
   - **`DOCKER_USERNAME`** / **`DOCKER_PASSWORD`** - For Docker Hub
   - **`GCP_SA_KEY`** - For GCP Artifact Registry (see below for setup)
3. Set repository access to "All repositories" or selected repositories

This is a **one-time setup** - all new projects scaffolded from this platform will automatically inherit these secrets.

### Repository Secrets (Alternative)

For individual developers without organization access, configure secrets per repository:
- Go to Repository → Settings → Secrets and variables → Actions
- Add the same secrets listed above

Note: This requires manual configuration for each scaffolded project.

### Artifact Registry Configuration (Optional)

The default `publish` recipe uploads to GCP Artifact Registry. To configure:

1. **Set environment variables in `.envrc`:**

   ```bash
   export GCP_PROJECT_ID="your-gcp-project-id"
   export GCP_REGION="us-central1"
   export GCP_REPOSITORY="your-artifact-repository"
   ```

2. **Authenticate locally:**

   ```bash
   gcloud auth login
   gcloud auth application-default login
   ```

3. **Add GitHub Organization Secrets (for CI/CD):**

   Go to your GitHub Organization → Settings → Secrets and variables → Actions and add:
   - `GCP_SA_KEY` - Service account JSON key for authentication
   - `GCP_PROJECT_ID` - GCP project ID
   - `GCP_REGION` - Registry region (e.g., us-east1)
   - `GCP_REPOSITORY` - Repository name

   To create a service account key:
   ```bash
   gcloud iam service-accounts create github-actions
   gcloud projects add-iam-policy-binding PROJECT_ID \
       --member="serviceAccount:github-actions@PROJECT_ID.iam.gserviceaccount.com" \
       --role="roles/artifactregistry.writer"
   gcloud iam service-accounts keys create key.json \
       --iam-account=github-actions@PROJECT_ID.iam.gserviceaccount.com
   ```

   Copy the contents of `key.json` to the `GCP_SA_KEY` organization secret.

   **Benefit:** All repositories in your organization automatically have access to these secrets. No need to reconfigure for each scaffolded project.

4. **Customize `publish` recipe for your needs:**

   The default publishes to GCP:
   ```just
   publish: test build-prod
       gcloud artifacts generic upload \
           --project={{GCP_PROJECT_ID}} \
           --location={{GCP_REGION}} \
           --repository={{GCP_REPOSITORY}} \
           --package={{PROJECT}} \
           --version={{VERSION}} \
           --source=dist/artifact.txt
   ```

   For npm:
   ```just
   publish: test build-prod
       npm publish
   ```

   For PyPI:
   ```just
   publish: test build-prod
       python -m twine upload dist/*
   ```

   For Docker:
   ```just
   publish: test build-prod
       docker push username/image:{{VERSION}}
   ```

## Workflow Triggers

The automated workflow is:

1. **Push to feature branch** → CI tests run
2. **Merge to main** → Release workflow runs
   - semantic-release analyzes commits
   - Creates version tag
   - Updates CHANGELOG.md
   - Builds production artifacts
   - Publishes to registry
   - Creates GitHub release

Everything happens in one workflow for simplicity.

## Branch Protection (Recommended)

Configure branch protection for `main`:

1. Repository → Settings → Branches → Add rule
2. Branch name pattern: `main`
3. Enable:
   - ✅ Require a pull request before merging
   - ✅ Require status checks to pass before merging
   - Select: `test` and `build` as required checks
   - ✅ Require branches to be up to date before merging
4. Save changes

This ensures all code is tested before release.

## Local Development Setup

Run the setup script to install dependencies:

```bash
just setup
```

This installs:
- bash
- just (command runner)
- docker
- direnv (environment management)
- node/npx (for semantic-release)

## Release Notes Setup (Optional)

To use Claude for generating release notes:

```bash
npm install -g @anthropic-ai/claude-cli
# or
brew install anthropics/claude/claude
```

Then run:

```bash
just release-notes
```

Claude will analyze commits and generate `RELEASE_NOTES.md`.

## Troubleshooting

### semantic-release fails with "ERELEASEBRANCHES"

**Cause:** Repository doesn't have a `main` branch

**Solution:**
1. Ensure your default branch is named `main`
2. Or update `.releaserc.json` to match your branch name

### Tests fail in CI but pass locally

**Cause:** Environment differences

**Solution:**
1. Check Node.js/Python/etc. versions match CI
2. Ensure all dependencies are committed (package-lock.json, etc.)
3. Review CI logs for specific errors
