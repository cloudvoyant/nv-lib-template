# User Guide

`mise-lib-template` is a language-agnostic [`mise`](https://mise.jdx.dev/)-powered [1] template for building library/executable projects. It uses GCP Artifact Registry for publishing generic packages by default, but can be easily adapted for npm, PyPI, NuGet, CodeArtifact, etc.

## Features

Here's what this template gives you off the bat:

- A language-agnostic self-documenting command interface via `mise` — keep all your project tasks, tool versions, and environment config in one `mise.toml`!
- Cross-platform environment management - mise installs any dev-tools your project defines
- CI/CD with GitHub Actions - run test on MR commits, tag and release on merges to main.
- Easy CI/CD customization - simply modify mise tasks that hook into actions
- Trunk-based development and automated versioning with conventional commits - just on feature branches and merge to main for bumps, semantic-release will handle version bumping for you!
- GCP Artifact Registry publishing (easily modified for other registries)

## Requirements

- bash 3.2+
- [mise](https://mise.jdx.dev/) — manages tools, tasks, and environment

To install mise, run:

```bash
❯ curl https://mise.jdx.dev/install.sh | sh
```

## Quick Start

Scaffold a new project:

```bash
# Click "Use this template" on GitHub, then:
❯ git clone <your-new-repo>
❯ cd <your-new-repo>
❯ bash .mise-tasks/scaffold --project your-project-name
```

Install dependencies and scaffold the template for your needs:

```bash
# Install project tools
❯ mise install

# Scaffold project for your language
❯ mise run scaffold
```

Type `mise tasks` to see all the tasks at your disposal:

```bash
❯ mise tasks
```

Build, run and test with `mise run`. The template will show TODO messages in console prior to adapting.

```bash
❯ mise run run
TODO: Implement build for mise-lib-template@2.x
TODO: Implement run

❯ mise run test
TODO: Implement build for mise-lib-template@2.x
TODO: Implement test
```

Mise runs the necessary task dependencies automatically!

Commit using conventional commits (`feat:`, `fix:`, `docs:`). Merge/push to main and CI/CD will run automatically bumping your project version and publishing a package.

### Using Docker

The template includes Docker support for running tasks in isolated containers without installing dependencies on your host machine.

Prerequisites:

- Docker Desktop or Docker Engine

Available Docker commands:

```bash
❯ mise run docker-build    # Build the Docker image
❯ mise run docker-run      # Run the project in a container
❯ mise run docker-test     # Run tests in a container
```

The `Dockerfile` and `docker-compose.yml` are configured to install all required dependencies automatically. This is useful for:

- Running tasks without installing tools locally
- Ensuring consistency across different development machines
- Testing in a clean environment

### Using Dev Containers

The template includes a pre-configured devcontainer for consistent cross-platform development environments across your team.

Prerequisites on host:

- Docker Desktop or Docker Engine
- An editor with Dev Containers support (e.g. VS Code, Zed, WebStorm, etc.)

Open the project in your editor and select "Reopen in Container". In your terminal you will find everything pre-installed including mise, gcloud and more:

- Git, GitHub CLI, and Google Cloud CLI pre-installed
- Git credentials automatically shared from host via SSH agent forwarding
- Claude CLI credentials mounted from `~/.claude`
- Docker-in-Docker support for building containers

Authentication:

- Git/GitHub: Automatic via SSH agent forwarding (no setup needed)
- gcloud: Run `gcloud auth login` inside the container on first use
- Claude: Automatically available if configured on host

## The Basics

### Development

```bash
mise run install    # Install project dependencies
mise run build      # Build for development
mise run test       # Run tests
mise run run        # Run locally
mise run clean      # Clean build artifacts
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

## Customizing The Template For Your Needs

### For Your Language

The `mise.toml` tasks contain TODO placeholders. Run Claude's `/adapt` command for guided customization:

```bash
claude /adapt
```

Or manually replace placeholders with your language's commands:

```toml
# Node.js example
[tasks.install]
run = "npm install"

[tasks.build]
run = "npm run build"

[tasks.test]
depends = ["build"]
run = "npm test"

[tasks.publish]
depends = ["test", "build-prod"]
run = "npm publish"
```

### For Your Registry

The `publish` task defaults to GCP Artifact Registry. Edit it in `mise.toml` for your registry:

```toml
# npm
[tasks.publish]
depends = ["test", "build-prod"]
run = "npm publish"

# PyPI
[tasks.publish]
depends = ["test", "build-prod"]
run = "twine upload dist/*"

# Docker
[tasks.publish]
depends = ["test", "build-prod"]
run = "docker push myimage:$VERSION"
```

Configure your `mise.toml` `[env]` section accordingly:

```toml
# GCP (default)
GCP_REGISTRY_PROJECT_ID = "my-project"
GCP_REGISTRY_REGION     = "us-east1"
GCP_REGISTRY_NAME       = "my-registry"

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

`mise` tasks provide hooks for overriding CI/CD behavior:

- **build-prod**: specifies how to create production builds in CI
- **test**: specifies hot to test your build
- **publish**: specifies how to publish to your artifact regiistry

Edit these tasks to change how CI/CD runs, but avoid editing `.github/workflows/` directly.

To modify semantic versioning behavior or to deviate fromt trunk-based development, modify your .releaserc.json to modify semantic-versioning CLI's behavior.

## LLM Assistance with Claude

Claude commands provide guided workflows for complex tasks. The template includes two custom commands, while most workflow commands come from the [Claudevoyant plugin](https://github.com/cloudvoyant/claudevoyant) (installed via `mise run install-claude-plugins`).

### Template Commands

```bash
claude /adapt                   # Customize template for your language (auto-deletes after use)
claude /upgrade                 # Migrate to newer template version
```

### Plugin Commands (from Claudevoyant)

```bash
claude /spec:new                # Create a new project plan
claude /spec:go                 # Execute the plan with spec-driven development
claude /dev:docs                # Validate documentation
claude /dev:commit              # Create conventional commit
claude /dev:review              # Perform code review
```

### Upgrading Projects

When a new template version is released:

```bash
claude /upgrade
```

This creates a comprehensive migration plan, compares files, and walks you through changes while preserving your customizations.

## Next Steps

1. Customize `mise.toml` tasks for your language
2. Write code in `src/`
3. Add tests
4. Configure GitHub organization secrets
5. Set up branch protection on `main`
6. Make your first conventional commit
7. Push and watch the automated release

Or just run `claude /adapt`.

See [Architecture](architecture.md) for implementation details.
