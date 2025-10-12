# User Guide

**platform-lib** is a language-agnostic platform template for building scaffolded projects with automated versioning, testing, and CI/CD workflows.

## Table of Contents

- [Creating a New Project](#creating-a-new-project)
- [Initial Setup](#initial-setup)
- [Development Workflow](#development-workflow)
- [Just Commands Reference](#just-commands-reference)
- [CI/CD Configuration](#cicd-configuration)
- [Upgrading Projects](#upgrading-projects)
- [Troubleshooting](#troubleshooting)

---

## Creating a New Project

There are **two ways** to create a new project from this platform:

### Option 1: GitHub Template (Recommended)

1. Click **"Use this template"** on GitHub
2. Name your new repository
3. Clone your repository:
   ```bash
   git clone <your-new-repo>
   cd <your-new-repo>
   ```
4. Run the scaffold script to customize:
   ```bash
   bash scripts/scaffold.sh --src . --dest . --project your-project-name
   ```

Platform development files (tests, migrations, changelogs) are automatically excluded from the template.

### Option 2: Nedavellir CLI (Automated)

If you have the Nedavellir CLI installed:

```bash
nv create your-project-name --platform platform-lib
```

This handles everything automatically - cloning, scaffolding, and cleanup.

### Option 3: Create a New Platform (Advanced)

If you want to create a **new platform** (not a regular project), use the `--platform` flag:

```bash
bash scripts/scaffold.sh --src . --dest /path/to/new-platform --project new-platform-name --platform
```

This keeps platform development tools:
- ✅ Test suite (`test/` directory)
- ✅ Platform commands (`just platform-test`, `just new-migration`)
- ✅ Platform Claude commands (`/validate-platform`, `/new-migration`)
- ❌ Removes migrations and decisions (specific to parent platform)
- ❌ Removes changelogs (CHANGELOG.md, RELEASE_NOTES.md)

Use this when forking the platform to create your own customized version.

---

## Initial Setup

### 1. Install Development Dependencies

Run the setup script to install required tools:

```bash
just setup
```

This installs **required dependencies**:

- **bash** - Shell scripting
- **just** - Command runner
- **direnv** - Environment management

**Optional dependencies** (install with `--include-optional`):

- **docker** - Containerization
- **node/npx** - For semantic-release
- **shellcheck** - Shell script linting
- **shfmt** - Shell script formatting

To install all dependencies including optional ones:

```bash
bash scripts/setup.sh --include-optional
```

Or via just:

```bash
just setup --include-optional
```

### 2. Configure Environment

Edit `.envrc` to set your project variables:

```bash
export PROJECT=your-project-name
export VERSION=0.1.0

# Optional: GCP Artifact Registry
# export GCP_REGISTRY_PROJECT_ID="your-gcp-project"
# export GCP_REGISTRY_REGION="us-east1"
# export GCP_REGISTRY_NAME="your-repo"
```

Allow direnv to load the environment:

```bash
direnv allow
```

### 3. Customize Build Commands

Edit `justfile` and replace the TODO placeholders with your actual build commands.

**Example for Node.js:**

```just
install: _load
    npm install

build: _load
    npm run build

build-prod: _load
    NODE_ENV=production npm run build

test: build
    npm test

publish: test build-prod
    npm publish
```

**Example for Python:**

```just
install: _load
    pip install -r requirements.txt

build: _load
    python -m build

test: build
    pytest

publish: test build-prod
    python -m twine upload dist/*
```

---

## Development Workflow

### Daily Commands

```bash
just install    # Install dependencies
just build      # Build the project
just test       # Run tests
just run        # Run locally
just clean      # Clean build artifacts
```

### List All Commands

```bash
just
```

### Commit Convention

Use conventional commits for automatic versioning:

```bash
git commit -m "feat: add new feature"      # Minor version bump
git commit -m "fix: resolve bug"           # Patch version bump
git commit -m "docs: update readme"        # No version bump
git commit -m "feat!: breaking change"     # Major version bump
```

### Push and Release

```bash
git push origin main
```

On merge to `main`, the CI/CD workflow will:

1. Run tests
2. Analyze commits and determine version
3. Build production artifacts
4. Publish to configured registry
5. Create GitHub release with changelog

---

## Just Commands Reference

### Core Commands

| Command           | Description                            |
| ----------------- | -------------------------------------- |
| `just install`    | Install project dependencies           |
| `just build`      | Build the project                      |
| `just build-prod` | Build production artifacts             |
| `just test`       | Run tests                              |
| `just run`        | Run the project locally                |
| `just clean`      | Remove build artifacts                 |
| `just publish`    | Publish to registry (requires secrets) |

### Utility Commands

| Command      | Description                   |
| ------------ | ----------------------------- |
| `just setup` | Install development tools     |
| `just --list`| Show all available commands   |

### Claude Commands

| Command                     | Description                             |
| --------------------------- | --------------------------------------- |
| `/generate-release-notes`   | Generate user-friendly release notes    |
| `/validate-docs`            | Validate documentation consistency      |
| `/upgrade`                  | Upgrade to newer platform version       |

### Project Migration

| Command        | Description                       |
| -------------- | --------------------------------- |
| `just upgrade` | Upgrade to newer platform version |

---

## Customizing Versioning

Test versioning locally (dry-run):

```bash
just upversion
```

Customize semantic-release by editing `.releaserc.json`. Add language-specific plugins:

- **npm**: Add `@semantic-release/npm`
- **Python**: Use `@semantic-release/exec` with `python -m build` and `twine upload`

Install needed plugins in `scripts/setup.sh`. See [Architecture](architecture.md#scriptsupversionsh) for details.

---

## CI/CD Configuration

### GitHub Organization Secrets (Recommended)

Configure secrets **once** at the organization level. All scaffolded projects automatically inherit them.

**Setup:**

1. Go to GitHub Organization → Settings → Secrets and variables → Actions
2. Add organization secrets based on your publishing target:

**For npm:**

- `NPM_TOKEN` - npm authentication token

**For PyPI:**

- `PYPI_TOKEN` - PyPI API token

**For Docker Hub:**

- `DOCKER_USERNAME` - Docker Hub username
- `DOCKER_PASSWORD` - Docker Hub password

**For GCP Artifact Registry:**

- `GCP_SA_KEY` - Service account JSON key
- `GCP_REGISTRY_PROJECT_ID` - GCP project ID
- `GCP_REGISTRY_REGION` - Registry region (e.g., us-east1)
- `GCP_REGISTRY_NAME` - Repository name

3. Set repository access to "All repositories" or selected repositories

**This is a one-time setup** - all new projects automatically have access.

### GCP Service Account Setup

To create a service account key for GCP Artifact Registry:

```bash
# Create service account
gcloud iam service-accounts create github-actions

# Grant permissions
gcloud projects add-iam-policy-binding PROJECT_ID \
    --member="serviceAccount:github-actions@PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/artifactregistry.writer"

# Create key
gcloud iam service-accounts keys create key.json \
    --iam-account=github-actions@PROJECT_ID.iam.gserviceaccount.com
```

Copy the contents of `key.json` to the `GCP_SA_KEY` organization secret.

### Repository Secrets (Alternative)

For individual developers without organization access:

1. Go to Repository → Settings → Secrets and variables → Actions
2. Add the same secrets listed above

Note: This requires manual configuration for each project.

### Branch Protection (Recommended)

Protect the `main` branch to ensure all code is tested:

1. Repository → Settings → Branches → Add rule
2. Branch name pattern: `main`
3. Enable:
   - ✅ Require a pull request before merging
   - ✅ Require status checks to pass before merging
   - Select: `test` and `build` as required checks
   - ✅ Require branches to be up to date before merging
4. Save changes

### Workflow Triggers

The automated CI/CD workflow:

1. **Push to feature branch** → CI tests run
2. **Merge to main** → Release workflow runs:
   - semantic-release analyzes commits
   - Creates version tag and updates CHANGELOG.md
   - Builds production artifacts
   - Publishes to registry
   - Creates GitHub release

---

## Upgrading Projects

When a new platform version is released, upgrade your project:

### Using Just

```bash
just upgrade
```

This launches an interactive migration assistant that:

1. Detects your current platform version
2. Finds the migration path to the latest version
3. Applies migrations sequentially
4. Validates the upgrade

### Using Slash Command

If you have Claude Code installed:

```bash
claude /upgrade
```

### Manual Migration

1. Check your current version:

   ```bash
   grep NV_PLATFORM_VERSION .envrc
   ```

2. Find the migration guide in `docs/migrations/`:

   ```bash
   ls docs/migrations/
   # Example: 1.0.4-to-1.1.0.md
   ```

3. Follow the migration guide instructions

4. Update your platform version in `.envrc`:

   ```bash
   export NV_PLATFORM_VERSION=1.1.0
   ```

5. Test your project:
   ```bash
   just test
   ```

---

## Troubleshooting

### semantic-release fails with "ERELEASEBRANCHES"

**Cause:** Repository doesn't have a `main` branch

**Solution:**

1. Ensure your default branch is named `main`
2. Or update `.releaserc.json` to match your branch name:
   ```json
   {
     "branches": ["your-branch-name"]
   }
   ```

### Tests fail in CI but pass locally

**Cause:** Environment differences

**Solution:**

1. Check that runtime versions match CI (Node.js, Python, Go, etc.)
2. Ensure all dependencies are committed (package-lock.json, requirements.txt, etc.)
3. Review CI logs for specific errors
4. Run tests in Docker locally to match CI environment

### direnv not loading .envrc

**Cause:** direnv not configured in shell

**Solution:**

Add to your shell config (~/.bashrc, ~/.zshrc, etc.):

```bash
eval "$(direnv hook bash)"  # or zsh, fish, etc.
```

Then reload:

```bash
source ~/.bashrc
direnv allow
```

### just command not found

**Cause:** just not installed or not in PATH

**Solution:**

```bash
# macOS
brew install just

# Linux
curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | sudo bash -s -- --to /usr/local/bin

# Or run setup
bash scripts/setup.sh
```

### Publish fails with authentication error

**Cause:** Missing or invalid registry credentials

**Solution:**

1. Verify GitHub organization secrets are configured (see [CI/CD Configuration](#cicd-configuration))
2. Check that secrets are accessible to your repository
3. For GCP, ensure service account has correct permissions
4. For npm/PyPI, verify token is still valid

### Migration guide not found

**Cause:** No migration path exists for your version

**Solution:**

1. Check available migration guides:
   ```bash
   ls docs/migrations/
   ```
2. If your version is too old, migrate incrementally:
   - 1.0.4 → 1.1.0
   - 1.1.0 → 1.2.0
   - etc.
3. If no guide exists, check the CHANGELOG.md for breaking changes

---

## Getting Help

- **Documentation**: [Architecture](architecture.md) | [Design](design.md)
- **Migration Guides**: [docs/migrations/](../docs/migrations/)
- **Issues**: [GitHub Issues](https://github.com/cloudvoyant/lib/issues)
- **Changelog**: [CHANGELOG.md](../CHANGELOG.md)

---

## Next Steps

After setup:

1. ✅ Customize your `justfile` with language-specific commands
2. ✅ Write your code in `src/`
3. ✅ Add tests
4. ✅ Configure GitHub organization secrets (for CI/CD)
5. ✅ Set up branch protection on `main`
6. ✅ Make your first commit using conventional commits
7. ✅ Push and watch the automated release workflow

Happy building! 🚀
