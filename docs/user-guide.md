# User Guide

nv-lib-template is a language-agnostic template for building projects with automated versioning, testing, and CI/CD workflows. GCP-forward by default, but easily adapted for npm, PyPI, Docker Hub, etc.

## Getting Started

### Quick Start

Scaffold a new project using the Nedavellir CLI or GitHub template:

```bash
# Option 1: Nedavellir CLI (automated)
nv create your-project-name --platform nv-lib-template

# Option 2: GitHub template + scaffold script
# Click "Use this template" on GitHub, then:
git clone <your-new-repo>
cd <your-new-repo>
bash scripts/scaffold.sh --src . --dest . --project your-project-name
```

Install dependencies:

```bash
just setup              # Required: bash, just, direnv
just setup --dev        # + Development tools (docker, node, shellcheck)
```

Allow direnv to load your environment:

```bash
direnv allow
```

That's it! You now have a working project with CI/CD.

### Using Dev Containers

The template includes a pre-configured devcontainer for consistent development environments across your team.

**Prerequisites on host:**

- Docker Desktop or Docker Engine
- VS Code with Remote - Containers extension
- SSH agent running with keys loaded (`ssh-add -l` to verify)
- For gcloud: Run `gcloud auth login` once on host

**To use:**

1. Open project in VS Code
2. Command Palette (Cmd/Ctrl+Shift+P) → "Dev Containers: Reopen in Container"
3. Wait for container build (first time only)

**What's included:**

- Git, GitHub CLI, and Google Cloud CLI pre-installed
- Git credentials automatically shared from host via SSH agent forwarding
- Claude CLI credentials mounted from `~/.claude`
- All VS Code extensions for shell development (shellcheck, just syntax, etc.)
- Docker-in-Docker support for building containers

**Authentication:**

- **Git/GitHub**: Automatic via SSH agent forwarding (no setup needed)
- **gcloud**: Run `gcloud auth login` inside the container on first use
- **Claude**: Automatically available if configured on host

**Cross-platform:**

The devcontainer works on macOS, Linux, and Windows. Credential mounting uses environment variable substitution (`${localEnv:HOME}${localEnv:USERPROFILE}`) to support both Unix and Windows paths.

## Usage

### Daily Commands

```bash
just install    # Install project dependencies
just build      # Build for development
just test       # Run tests
just run        # Run locally
just clean      # Clean build artifacts
```

List all available commands:

```bash
just
```

### Commit and Release

Use conventional commits for automatic versioning:

```bash
git commit -m "feat: add new feature"      # Minor bump (0.1.0 → 0.2.0)
git commit -m "fix: resolve bug"           # Patch bump (0.1.0 → 0.1.1)
git commit -m "docs: update readme"        # No bump
git commit -m "feat!: breaking change"     # Major bump (0.1.0 → 1.0.0)
```

Push to main:

```bash
git push origin main
```

CI/CD automatically runs tests, creates a release, and publishes to your configured registry.

## Adapting

### For Your Language

The `justfile` contains TODO placeholders. Run Claude's `/adapt` command for guided customization:

```bash
claude /adapt
```

Or manually replace placeholders with your language's commands:

```just
# Node.js example
install:
    npm install

build:
    npm run build

test: build
    npm test

publish: test build-prod
    npm publish
```

### For Your Registry

The `publish` recipe defaults to GCP Artifact Registry. Edit it for your registry:

```just
# npm
publish: test build-prod
    npm publish

# PyPI
publish: test build-prod
    twine upload dist/*

# Docker
publish: test build-prod
    docker push myimage:{{VERSION}}
```

Configure your `.envrc` accordingly:

```bash
# GCP (default)
export GCP_REGISTRY_PROJECT_ID="my-project"
export GCP_REGISTRY_REGION="us-east1"
export GCP_REGISTRY_NAME="my-registry"

# Or use registry-specific variables for npm, PyPI, etc.
```

### CI/CD Secrets

Configure secrets once at the organization level (Settings → Secrets → Actions):

For GCP (default):

- `GCP_SA_KEY` - Service account JSON key
- `GCP_REGISTRY_PROJECT_ID`, `GCP_REGISTRY_REGION`, `GCP_REGISTRY_NAME`

For other registries:

- npm: `NPM_TOKEN`
- PyPI: `PYPI_TOKEN`
- Docker Hub: `DOCKER_USERNAME`, `DOCKER_PASSWORD`

All projects automatically inherit organization secrets.

## Overriding CI/CD

### Customizing Behavior

Scripts in `scripts/` provide hooks for overriding CI/CD behavior:

- `scripts/upversion.sh` - Modify versioning logic
- `scripts/setup.sh` - Add custom dependencies
- `scripts/scaffold.sh` - Keep as-is (template initialization)

Edit these scripts to change how CI/CD runs, but never edit `.github/workflows/` directly.

### Example: Custom Versioning

To change how versions are calculated, edit `scripts/upversion.sh` or modify `.releaserc.json` to add semantic-release plugins.

### Example: Additional Setup Steps

To add custom dependencies during CI setup, extend `scripts/setup.sh` with your logic.

## LLM Assistance with Claude

Claude commands provide guided workflows for complex tasks.

### Available Commands

```bash
claude /adapt                   # Customize template for your language
claude /upgrade                 # Migrate to newer template version
claude /adr-new                 # Create architectural decision record
claude /adr-capture             # Capture decisions from conversation
claude /docs                    # Validate documentation
```

### Upgrading Projects

When a new template version is released:

```bash
claude /upgrade
```

This creates a comprehensive migration plan, compares files, and walks you through changes while preserving your customizations.

## Troubleshooting

### direnv not loading .envrc

Add to your shell config (~/.bashrc, ~/.zshrc):

```bash
eval "$(direnv hook bash)"  # or zsh, fish
```

Reload and allow:

```bash
source ~/.bashrc
direnv allow
```

### just command not found

Install just:

```bash
brew install just           # macOS
# Or run: bash scripts/setup.sh
```

### Tests pass locally but fail in CI

Check that:

- Runtime versions match CI (Node.js, Python, Go versions)
- Lock files are committed (package-lock.json, requirements.txt)
- All dependencies are declared

### Publish fails with authentication error

Verify GitHub organization secrets are configured:

1. Organization → Settings → Secrets → Actions
2. Check secrets exist (GCP_SA_KEY, NPM_TOKEN, etc.)
3. Ensure repository access is enabled

For GCP, verify service account has `roles/artifactregistry.writer` permission.

### semantic-release fails

Ensure:

- Default branch is named `main` (or update `.releaserc.json`)
- At least one commit uses conventional format
- GITHUB_TOKEN secret is accessible

## Next Steps

1. Customize `justfile` for your language
2. Write code in `src/`
3. Add tests
4. Configure GitHub organization secrets
5. Set up branch protection on `main`
6. Make your first conventional commit
7. Push and watch the automated release

See [Architecture](architecture.md) for implementation details.
