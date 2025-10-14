# Architecture

## Overview

nv-lib-template is a language-agnostic template providing consistent build/test/publish workflows. Customize for any language by editing `justfile` recipes.

GCP-forward by default (uses GCP Artifact Registry), but easily modified for npm, PyPI, Docker Hub, etc.

## How It Works

The template follows a simple flow:

```
direnv → just → scripts → GitHub Actions
                ↓
              Claude (for complex workflows)
```

When you run a command like `just build`, here's what happens:

1. direnv automatically loads `.envrc` to populate your environment with PROJECT, VERSION, and registry configuration
2. just executes the command you specified (`just build`, `just test`, `just publish`) using recipes defined in the `justfile`
3. The justfile recipes call bash scripts in `scripts/` for language-agnostic automation (setup.sh, scaffold.sh, upversion.sh) that you can override or extend
4. GitHub Actions workflows trigger on PRs and merges, calling your just commands to run tests and publish releases
5. Claude commands provide optional LLM assistance for complex workflows like template migrations, project adaptations, and documenting architectural decisions

## Design / Basic Usage

### Getting Started

After scaffolding a project from this template, run `/adapt` to customize it for your language (Python, Node.js, Go, Docker). Then interact with your project via `just` commands:

```bash
just install    # Install project dependencies
just build      # Build for development
just test       # Run tests
just publish    # Build prod + publish to registry
```

To customize CI/CD behavior, edit scripts in the `scripts/` directory rather than modifying workflows directly.

### Customization Points

The `justfile` is where you define language-specific commands. Replace the TODO placeholders with your language's build/test/publish commands:

```just
build:
    npm run build  # or python -m build, go build, cargo build

test: build
    npm test  # or pytest, go test ./..., cargo test

publish: test build-prod
    npm publish  # or twine upload, gcloud artifacts upload
```

Scripts in `scripts/` provide hooks for overriding CI/CD behavior:
- Modify `scripts/upversion.sh` to change versioning logic
- Extend `scripts/setup.sh` to add custom dependencies
- Keep `scripts/scaffold.sh` as-is for template initialization

The key principle: customize just recipes and scripts, never edit workflows directly.

## Project Structure

### Template (This Repo)

For template maintainers. Includes testing infrastructure:

```
lib/
├── .envrc                   # Environment variables
├── justfile                 # Commands + TEMPLATE section
├── scripts/                 # Bash framework
│   ├── setup.sh
│   ├── scaffold.sh
│   └── upversion.sh
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
├── .envrc                   # Your project config
├── justfile                 # Clean commands (no TEMPLATE section)
├── scripts/                 # Bash framework (override as needed)
├── src/                     # Your code here
├── docs/                    # Your docs
├── .claude/                 # User-facing commands only
├── .github/workflows/       # ci.yml, release.yml
└── .devcontainer/           # VS Code container
```

Key difference: Main README documents template architecture. README.template.md becomes scaffolded project README.

## Implementation Details

This section is for template maintainers and advanced users who need to understand how components work internally.

### Component: justfile

The `justfile` serves as the command runner interface. It uses bash as the shell interpreter and defines color variables (INFO, SUCCESS, WARN, ERROR) for pretty output. The `_load` recipe sources `.envrc` to load environment variables, and all other recipes depend on it. Recipe dependencies create a build chain: `test` depends on `build`, and `publish` depends on both `test` and `build-prod`.

### Component: scripts/

The `scripts/` directory contains language-agnostic bash automation:

- `setup.sh` - Installs dependencies using semantic flags (`--dev`, `--ci`, `--template`) that indicate what level of tooling to install
- `scaffold.sh` - Initializes new projects from the template, handling case variant replacements (PascalCase, camelCase, etc.), template cleanup, and backup/restore on failure
- `upversion.sh` - Wraps semantic-release with a consistent interface (local dry-run mode vs CI mode)
- `utils.sh` - Provides shared functions for logging, version reading, and cross-platform compatibility

All scripts use `set -euo pipefail` for consistent error handling.

### Component: .envrc

The `.envrc` file holds environment configuration that direnv loads automatically. Keep it simple with just `export` statements - no bash logic. Secrets belong in GitHub Secrets, not `.envrc`. Each project commits its own `.envrc` file. The `.envrc.template` file provides a starting point for scaffolded projects with placeholders that scaffold.sh replaces.

### Component: GitHub Actions

Two workflows handle CI/CD: `ci.yml` runs `just build` and `just test` on pull requests, while `release.yml` runs semantic-release on main branch and then `just publish` if a new version was created. The workflows call your just commands, so you customize behavior by editing recipes and scripts rather than workflows.

### Component: Claude Commands

Claude commands provide LLM-assisted workflows for complex tasks:

- `/upgrade` - Migrates projects to newer template versions using a spec-driven approach with comprehensive plans
- `/adapt` - Customizes the template for your language/framework with examples for Python, Node.js, Go, Docker
- `/adr-new`, `/adr-capture` - Documents architectural decisions in `docs/decisions/`
- `/docs` - Validates documentation completeness and consistency

### Component: .devcontainer/

The `.devcontainer/` directory provides VS Code Dev Containers configuration for consistent development environments across teams. It includes:

**Features:**
- `git:1` - Git installed from source (credentials auto-shared by VS Code via SSH agent forwarding)
- `github-cli:1` - GitHub CLI with automatic authentication
- `google-cloud-cli:1` - gcloud CLI tools
- `docker-in-docker:2` - Docker daemon for building containers

**Credential Mounting:**
- Claude CLI credentials mounted from `~/.claude` directory
- Uses cross-platform path resolution: `${localEnv:HOME}${localEnv:USERPROFILE}` expands to HOME on Unix or USERPROFILE on Windows
- Git/GitHub credentials automatically forwarded via SSH agent (requires `ssh-add` on host)
- gcloud requires manual `gcloud auth login` inside container (credentials persist via Docker volumes)

**VS Code Extensions:**
- `mkhl.direnv` - direnv support
- `skellock.just` and `nefrob.vscode-just-syntax` - justfile syntax highlighting
- `timonwong.shellcheck` and `foxundermoon.shell-format` - Shell script linting and formatting
- `ms-azuretools.vscode-docker` - Docker support

**Cross-Platform Considerations:**
- Works on macOS, Linux, and Windows (via Docker Desktop or WSL)
- Credential paths use environment variable fallback pattern for platform compatibility
- On Windows, if `~/.claude` doesn't exist at `%USERPROFILE%\.claude`, mount will fail gracefully (container starts without Claude credentials)

### Setup Flags

The `setup.sh` script uses semantic flags to indicate what level of tooling to install:

```bash
just setup              # Required: bash, just, direnv
just setup --dev        # + docker, node/npx, gcloud, shellcheck, shfmt
just setup --ci         # + docker, node/npx, gcloud (minimal)
just setup --template   # + bats-core (template testing)
```

This approach makes it clear what dependencies are needed for different contexts (local development, CI environments, or template maintenance).

### Publishing

The template defaults to GCP Artifact Registry but is easily customized for other registries. Just edit the `publish` recipe:

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

### CI/CD Secrets

For GCP (the default), configure these secrets once at the organization level:
- `GCP_SA_KEY` - Service account JSON key
- `GCP_REGISTRY_PROJECT_ID`, `GCP_REGISTRY_REGION`, `GCP_REGISTRY_NAME` - Registry configuration

All repositories inherit organization secrets automatically. For other registries, see comments in `release.yml` that explain what to change for npm, PyPI, Docker Hub, AWS ECR, or Azure ACR.

### Cross-Platform Support

The template works on macOS, Linux, and Windows (via WSL). Key compatibility measures:
- Line endings enforced to LF via `.editorconfig`
- `sed_inplace` helper handles differences between macOS and GNU sed
- Bash 3.2+ required (avoids Bash 4+ features like associative arrays)
- Package manager detection for Homebrew (macOS), apt/yum/pacman (Linux), with fallback to curl

### Security

Secrets belong in GitHub Secrets, never in `.envrc` or committed code. The `.gitignore` includes comprehensive patterns for keys, certificates, credentials, and .env files. All scripts use `set -euo pipefail` for fail-fast behavior and error traps for cleanup. Lock files prevent concurrent script execution.

### Testing

For user projects, customize `just test` for your language (pytest for Python, npm test for Node.js, go test for Go, cargo test for Rust).

For template development, use bats-core for bash script testing:
```bash
just setup --template  # Install bats
just template-test     # Run template tests
```

Tests cover scaffold.sh validation, .envrc handling, case variant replacements, and template file cleanup.

## References

- [just command runner](https://github.com/casey/just)
- [direnv environment management](https://direnv.net/)
- [semantic-release](https://semantic-release.gitbook.io/)
- [bats-core bash testing](https://bats-core.readthedocs.io/)
- [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [GitHub Actions](https://docs.github.com/en/actions)
- [GCP Artifact Registry](https://cloud.google.com/artifact-registry/docs)
