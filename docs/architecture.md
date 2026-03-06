# Architecture

## Overview

`nv-lib-template` is a language-agnostic template for building projects with automated versioning, testing, and GitHub Action powered CI/CD workflows. Customize for any language by editing `mise.toml` tasks.

GCP-forward by default (uses GCP Artifact Registry), but easily modified for npm, PyPI, Docker Hub, etc.

## How It Works

The template follows a simple flow:

```
┌──────┐    ┌──────────────┐    ┌────────────────┐
│ mise │ -> │ mise tasks   │ -> │ GitHub Actions │
│ env  │    │ (.mise-tasks)│    └────────────────┘
└──────┘    └──────────────┘
              │
              v
         ┌───────────┐
         │  Claude   │
         │ (optional)│
         └───────────┘
```

When you run `mise run build`, here's what happens:

1. mise loads `mise.toml` from project root, populating environment with PROJECT, VERSION, and registry configuration
2. mise executes the task you specified (`mise run build`, `mise run test`, `mise run publish`)
3. Complex tasks are implemented as file-based scripts in `.mise-tasks/` (`scaffold`, `upversion`, `registry-login`, etc.)
4. GitHub Actions workflows trigger on PRs and merges, calling `mise run` commands
5. Claude commands provide optional LLM assistance for complex workflows like template migrations, project adaptations, and documenting architectural decisions

## Design / Basic Usage

### Getting Started

For detailed setup instructions, see the [User Guide](user-guide.md#quick-start).

After scaffolding a project from this template, run `/adapt` to customize it for your language (Python, Node.js, Go, Docker). Then interact with your project via `mise run` commands:

```bash
mise run install    # Install project dependencies
mise run build      # Build for development
mise run test       # Run tests
mise run publish    # Build prod + publish to registry
```

To customize CI/CD behavior, edit tasks in `.mise-tasks/` rather than modifying workflows directly.

### Customization Points

The `mise.toml` is where you define language-specific commands. Replace the TODO placeholders with your language's build/test/publish commands:

```toml
[tasks.build]
run = "npm run build"  # or python -m build, go build, cargo build

[tasks.test]
depends = ["build"]
run = "npm test"  # or pytest, go test ./..., cargo test

[tasks.publish]
depends = ["test", "build-prod"]
run = "npm publish"  # or twine upload, gcloud artifacts upload
```

Tasks in `.mise-tasks/` provide hooks for overriding CI/CD behavior:

- Modify `.mise-tasks/upversion` to change versioning logic
- Keep `.mise-tasks/scaffold` as-is for template initialization

The key principle: customize mise tasks, never edit workflows directly. This separation keeps your CI/CD logic portable and testable locally, while workflows remain stable across template upgrades.

## Project Structure

### Template (This Repo)

For template maintainers. Includes testing infrastructure:

```
lib/
├── mise.toml                # Tasks, tools, and env vars
├── Dockerfile               # Docker image definition
├── docker-compose.yml       # Docker services configuration
├── .mise-tasks/             # File-based mise tasks
│   ├── scaffold             # Project scaffolding
│   ├── upversion            # Semantic versioning
│   └── ...                  # Other tasks + internal utils
├── src/                     # Sample code
├── test/                    # bats tests (for template)
├── docs/                    # architecture.md, user-guide.md
├── .claude/                 # AI workflows + all commands
├── .github/workflows/       # ci.yml, release.yml
└── .devcontainer/           # VS Code container
```

### Scaffolded Projects

For end users. Template development files removed:

```
myproject/
├── mise.toml                # Your project config (no TEMPLATE section)
├── Dockerfile               # Docker image definition
├── docker-compose.yml       # Docker services configuration
├── .mise-tasks/             # Bash tasks (override as needed)
├── src/                     # Your code here
├── docs/                    # Your docs
├── .claude/                 # User-facing commands only
├── .github/workflows/       # ci.yml, release.yml
└── .devcontainer/           # VS Code container
```

Key difference: The main README.md documents template architecture and is kept in the template repository. During scaffolding, `README.template.md` is renamed to `README.md` in the new project and customized with project-specific information. Template development files (`test/`, `.claude/commands/upgrade.md`, etc.) are removed.

## Implementation Details

This section is for template maintainers and advanced users who need to understand how components work internally.

### Component: mise.toml

`mise.toml` is the central configuration file serving three roles:

1. **Tool management** (`[tools]`): declares tool versions (node, shellcheck,
   shfmt). Run `mise install` to install them. GitHub Actions uses `jdx/mise-action`
   to install mise and run `mise install` automatically.

2. **Environment** (`[env]`): static env vars (PROJECT, GCP_*) and dynamic
   VERSION via `{{exec(command='cat version.txt ...')}}`. All tasks automatically
   have access to these env vars without manual sourcing.

3. **Tasks** (`[tasks]`): runnable commands for build, test, publish, and
   utilities. Run tasks with `mise run <task>` or list all with `mise tasks`.

Task dependencies are declared with `depends = ["other-task"]`. This enforces
quality gates automatically (e.g., `publish` requires `test` and `build-prod`).

### Component: .mise-tasks/

The `.mise-tasks/` directory contains file-based mise tasks — executable bash scripts that implement complex automation. This keeps `mise.toml` clean while keeping tasks directly runnable via `mise run <task>`.

- `scaffold` - Initializes new projects from the template, handling case variant replacements (PascalCase, camelCase, etc.), template cleanup, and backup/restore on failure to ensure safe initialization
- `upversion` - Wraps semantic-release with a consistent interface (local dry-run mode vs CI mode), enabling developers to preview version bumps before pushing
- `registry-login` - Handles GCP authentication for both local (interactive) and CI (service account) modes
- `publish` - Uploads build artifacts to GCP Artifact Registry
- `upgrade` - Runs the Claude `/upgrade` command for template migrations
- `utils` *(internal)* - Shared functions for logging, version reading, and cross-platform compatibility
- `toggle-files` *(internal)* - VS Code file visibility logic, called by `hide`/`show` tasks

All tasks use `set -euo pipefail` for fail-fast behavior, catching errors immediately rather than continuing with invalid state.

### Component: GitHub Actions

Two workflows handle CI/CD with minimal configuration: `ci.yml` runs `mise run test` and `mise run test-template` on pull requests, while `release.yml` runs semantic-release on main branch and then `mise run publish` if a new version was created.

The workflows use `jdx/mise-action@v2` to install mise and all tools declared in `mise.toml`. The release workflow uses `google-github-actions/auth@v2` + `setup-gcloud@v2` for GCP authentication.

The workflows call your mise tasks rather than duplicating logic, creating a single source of truth. Customization happens in familiar territory (bash scripts and mise tasks) rather than GitHub Actions YAML.

### Component: Claude Commands

Claude commands provide LLM-assisted workflows for complex tasks.

This template provides two custom commands:

- `/adapt` - Template-only command for adapting to new languages (auto-deletes after use)
- `/upgrade` - Upgrade to the latest template version

All other workflow commands (`/spec:new/go/pause`, `/dev:commit`, `/dev:review`, `/adr:new`, etc.) are provided by the [Claudevoyant plugin](https://github.com/cloudvoyant/claudevoyant). The plugin is automatically configured during scaffolding and provides a comprehensive set of development workflow commands.

### Component: Dockerfile (Multi-Stage)

The `Dockerfile` uses a multi-stage build to support both minimal runtime environments and full development environments from a single file:

**Base Stage** (`target: base`):

- Used by docker-compose for `mise run docker-run` and `mise run docker-test`
- Installs mise globally and pre-installs tools from `mise.toml`
- Fast build time (~1-2 minutes)
- Minimal image size for quick iteration

**Dev Stage** (`target: dev`):

- Used by VS Code DevContainers
- Builds on top of base stage
- Adds development tools: claudevoyant plugin, starship config (binaries already in base via mise)
- Slower build (~10 minutes), but cached after first build

Configuration:

- `docker-compose.yml` services specify `target: base` for fast builds
- `.devcontainer/devcontainer.json` specifies `target: dev` for full environment
- Both share the same base layers, maximizing Docker layer cache efficiency

### Component: docker-compose.yml

Provides containerized services for running and testing without installing dependencies locally:

- `runner` service: Executes `mise run run` in isolated container
- `tester` service: Executes `mise run test` in isolated container
- Both use `target: base` for minimal, fast builds
- Mount project directory to `/workspace` for live code updates

### Component: .devcontainer/

The `.devcontainer/` directory provides VS Code Dev Containers configuration for consistent development environments across teams. The devcontainer uses the root-level `Dockerfile` with `target: dev` to build a full development environment.

Features:

- `git:1` - Git installed from source (credentials auto-shared by VS Code via SSH agent forwarding)
- `docker-outside-of-docker:1` - Docker CLI that connects to host's Docker daemon

Credential Mounting:

- Claude CLI credentials mounted from `~/.claude` directory
- Uses cross-platform path resolution: `${localEnv:HOME}${localEnv:USERPROFILE}` expands to HOME on Unix or USERPROFILE on Windows
- Git/GitHub credentials automatically forwarded via SSH agent (requires `ssh-add` on host)
- gcloud requires manual `gcloud auth login` inside container (credentials persist via Docker volumes)

VS Code Extensions:

- `timonwong.shellcheck` and `foxundermoon.shell-format` - Shell script linting and formatting
- `ms-azuretools.vscode-docker` - Docker support

Cross-Platform Considerations:

- Works on macOS, Linux, and Windows (via Docker Desktop or WSL)
- Credential paths use environment variable fallback pattern for platform compatibility
- On Windows, if `~/.claude` doesn't exist at `%USERPROFILE%\.claude`, mount will fail gracefully (container starts without Claude credentials)

### Tool Installation

All binary tools are declared in `mise.toml [tools]` and installed with a single `mise install`:

```bash
mise install                        # node, shellcheck, shfmt, bats, taplo, gcloud, starship, claude, docker-cli
mise run install-claude-plugins     # claudevoyant plugin (Claude CLI plugin, not a binary)
```

### Publishing

The template defaults to GCP Artifact Registry but is easily customized for other registries. Just edit the `publish` task in `mise.toml`:

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

### CI/CD Secrets

Configure secrets once at the organization level (Settings → Secrets → Actions). All repositories inherit organization secrets automatically.

For GCP (default):

- `GCP_SA_KEY` - Service account JSON key
- `GCP_REGISTRY_PROJECT_ID`, `GCP_REGISTRY_REGION`, `GCP_REGISTRY_NAME` - Registry configuration

For other registries (see [user-guide.md](user-guide.md#cicd-secrets) for details):

- npm: `NPM_TOKEN`
- PyPI: `PYPI_TOKEN`
- Docker Hub: `DOCKER_USERNAME`, `DOCKER_PASSWORD`

See comments in `.github/workflows/release.yml` for additional registry options (AWS ECR, Azure ACR).

### Cross-Platform Support

The template works on macOS, Linux, and Windows (via WSL) without requiring users to install platform-specific tools. This broad compatibility reduces team onboarding friction and prevents "works on my machine" issues.

Key compatibility measures:

- Line endings enforced to LF via `.editorconfig` (prevents git diff noise on Windows)
- `sed_inplace` helper handles differences between macOS and GNU sed (abstracts platform quirks)
- Bash 3.2+ required (macOS ships with Bash 3.2, avoiding Bash 4+ features ensures compatibility without upgrades)
- Package manager detection for Homebrew (macOS), apt/yum/pacman (Linux), with fallback to curl (installs tools automatically based on available package managers)

### Security

Secrets belong in GitHub Secrets, never in `mise.toml` or committed code, following the principle of separating configuration from credentials. The `.gitignore` includes comprehensive patterns for keys, certificates, credentials, and .env files to prevent accidental commits.

All scripts use `set -euo pipefail` for fail-fast behavior, ensuring errors don't silently propagate. Error traps handle cleanup on failure, preventing partial state. Lock files prevent concurrent script execution, avoiding race conditions during critical operations like scaffolding or version bumping.

### Testing

For user projects, customize `mise run test` for your language (pytest for Python, npm test for Node.js, go test for Go, cargo test for Rust).

For template development, use bats-core for bash script testing:

```bash
mise run test-template         # Run template tests
```

Tests cover scaffold.sh validation, mise.toml handling, case variant replacements, and template file cleanup.

## References

- [mise - the dev tool manager](https://mise.jdx.dev/)
- [semantic-release](https://semantic-release.gitbook.io/)
- [bats-core bash testing](https://bats-core.readthedocs.io/)
- [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [GitHub Actions](https://docs.github.com/en/actions)
- [GCP Artifact Registry](https://cloud.google.com/artifact-registry/docs)
