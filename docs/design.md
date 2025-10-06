# Design

## Introduction

A language-agnostic build system that can be forked and customized for any programming language or SDK project. The system provides a common set of development workflows (build, test, run, publish) that work consistently across different languages.

## Features

- Build, test, run, and publish workflows
- Automated versioning via conventional commits
- CI/CD with GitHub Actions (test on PR, release on merge, publish on tags)
- Development container support
- Cross-platform compatibility (macOS, Linux, Windows via WSL)
- IDE configuration (VS Code, EditorConfig)
- Direct customization by editing `justfile`

## Technology Stack

- `bash` - Core scripting language
- `just` - Command runner
- `direnv` - Environment management
- `docker` - Containerization
- `semantic-release` - Automated versioning
- GitHub Actions - CI/CD

## Key Components

### Command Interface

The `justfile` is the primary interface. Users customize it by replacing TODO placeholders with their language-specific commands:

```just
build: _load
    npm run build  # Replace with your build command

test *ARGS: build
    npm test {{ARGS}}  # Replace with your test command
```

All recipes depend on `_load` which sources `.envrc` to load environment variables.

Key commands available:

- `just setup` - Install system dependencies (bash, just, docker, direnv, node)
- `just install` - Install project dependencies (customize for your language)
- `just build` - Build the project for development
- `just build-prod` - Build for production with optimizations
- `just clean` - Clean build artifacts
- `just test` - Run tests on development build
- `just run` - Run the project locally
- `just publish` - Test dev build, create prod build, and publish to registry
- `just format` - Format code with your formatter
- `just lint` - Lint code with your linter
- `just version` - Get current version from git tags
- `just version-next` - Get next version from semantic-release
- `just release-notes` - Generate release notes with Claude
- `just scaffold` - Initialize a forked project
- `just --list` - Show all available commands

Commands support dependencies. For example, `test` depends on `build`, ensuring builds run before tests:

```bash
just test                    # Runs build, then test
just format src/             # Accepts path arguments
```

The `publish` command depends on `test` (which tests the dev build) and `build-prod` (which creates production artifacts):

```just
build-prod: _load
    NODE_ENV=production npm run build

publish: test build-prod
    gcloud artifacts generic upload \
        --project={{REGISTRY_PROJECT_ID}} \
        --location={{REGISTRY_REGION}} \
        --repository={{REGISTRY_NAME}} \
        --package={{PROJECT}} \
        --version={{VERSION}} \
        --source=dist/artifact.tar.gz
```

Tests always run on the development build. Production builds are created for publishing but not separately tested.

Default implementation publishes to GCP Artifact Registry. Customize the `publish` recipe for your needs (npm, PyPI, Docker, etc.).

### Reusable Utilities

The `scripts/utils.sh` file provides shared functions:

- Logging with colors (`log_info`, `log_error`, `log_warn`)
- Version management (`get_version`, `get_next_version`)
- Progress indicators (`spinner`, `progress_step`)
- Cross-platform helpers (`sed_inplace`, `command_exists`)

Scripts source `utils.sh` to use these functions:

```bash
#!/usr/bin/env bash
source "$(dirname "$0")/utils.sh"
setup_script_lifecycle

log_info "Starting build..."
```

### Environment Management

The `.envrc` file defines environment variables:

```bash
export PROJECT=yin
export VERSION=$(get_version)
```

When using `direnv`, variables load automatically on directory entry. Otherwise, the `_load` recipe sources `.envrc` manually.

### Setup and Scaffolding

The `scripts/setup.sh` installs dependencies (bash, just, docker, direnv, node) across different platforms. It detects the OS and uses the appropriate package manager.

The `scripts/scaffold.sh` initializes a forked project by prompting for project details and replacing template strings.

### CI/CD Workflows

Two GitHub Actions workflows handle automation:

- `ci.yml` - Runs tests and builds on pull requests
- `release.yml` - Creates releases, publishes, and tags when merged to main

The release workflow is combined for simplicity - it runs semantic-release, then immediately publishes if a new version was created. No separate workflows or Personal Access Tokens required.

### Versioning

Uses conventional commits (feat:, fix:, docs:, etc.) with semantic-release to automatically:

- Analyze commits since last release
- Determine next version number
- Create git tags
- Update CHANGELOG.md
- Create GitHub releases

The `get_version` function reads the current version from git tags.

### Release Notes

Hybrid approach for release documentation:

- `CHANGELOG.md` - Auto-generated from commits (technical log)
- `RELEASE_NOTES.md` - Human-written, Claude-assisted (user-friendly)

Workflow:

```bash
just release-notes          # Claude analyzes commits and generates RELEASE_NOTES.md
# Review and edit RELEASE_NOTES.md
git add RELEASE_NOTES.md
git commit -m "docs: release notes for v1.2.0"
git push                    # Triggers release with both changelogs
```

Claude CLI generates user-focused descriptions explaining impact and improvements, while the automated changelog maintains a complete technical record.

### Publishing

The `publish` recipe handles publishing artifacts. Default implementation uploads to GCP Artifact Registry:

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

Customize for your language/registry by editing the `publish` recipe directly:

**npm:**
```just
publish: test build-prod
    npm publish
```

**PyPI:**
```just
publish: test build-prod
    python -m twine upload dist/*
```

**Docker Hub:**
```just
publish: test build-prod
    docker tag myimage:latest username/myimage:{{VERSION}}
    docker push username/myimage:{{VERSION}}
```

Configure registry variables in `.envrc`:
```bash
export GCP_PROJECT_ID="your-project-id"
export GCP_REGION="us-central1"
export GCP_REPOSITORY="your-repository"
```

See [Setup Guide](setup.md) for detailed configuration.

## Usage Patterns

### Daily Development

```bash
just setup    # First time setup
just build    # Build the project
just test     # Run tests
just run      # Run locally
```

### Forking for Your Project

1. Fork the repository
2. Run `just scaffold` to initialize
3. Edit `justfile` - replace TODOs with your commands
4. Configure GitHub Secrets if publishing
5. Commit using conventional commit format
6. Push - CI/CD runs automatically

### Customization Examples

Node.js (with GCP Artifact Registry):
```just
install: _load
    npm install

build: _load
    npm run build

build-prod: _load
    NODE_ENV=production npm run build
    tar -czf dist/package.tar.gz dist/

test: build
    npm test

publish: test build-prod
    npm publish
    gcloud artifacts generic upload \
        --project={{GCP_PROJECT_ID}} \
        --location={{GCP_REGION}} \
        --repository={{GCP_REPOSITORY}} \
        --package={{PROJECT}} \
        --version={{VERSION}} \
        --source=dist/package.tar.gz

clean: _load
    rm -rf dist/ node_modules/
```

Python (with PyPI):
```just
install: _load
    pip install -r requirements.txt

build: _load
    python -m build

build-prod: _load
    python -m build

test: build
    pytest

publish: test build-prod
    python -m twine upload dist/*

clean: _load
    rm -rf dist/ build/ *.egg-info/
```

Go (with Docker):
```just
install: _load
    go mod download

build: _load
    go build -o bin/app

build-prod: _load
    go build -ldflags="-s -w" -o bin/app

test: build
    go test ./...

publish: test build-prod
    docker build -t myapp:{{VERSION}} .
    docker push myapp:{{VERSION}}

clean: _load
    rm -rf bin/
```

Rust (with crates.io):
```just
install: _load
    cargo fetch

build: _load
    cargo build

build-prod: _load
    cargo build --release

test: build
    cargo test

publish: test build-prod
    cargo publish

clean: _load
    cargo clean
```

## Documentation Style Guide

- Be concise and scannable
- Use backticks for files, commands, and code
- Avoid excessive bold formatting
- Structure: introduction → features → design → details
- Save implementation details for `architecture.md`
