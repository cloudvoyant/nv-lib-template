# Language-Agnostic Build System

A fork-friendly build system that works with any programming language. Provides common development workflows (build, test, run, publish) with automated versioning and CI/CD.

## Quick Start

Clone and setup:

```bash
git clone <your-fork>
cd lib
just setup
```

Daily development:

```bash
just install  # Install project dependencies
just build    # Build the project
just test     # Run tests
just run      # Run locally
just clean    # Clean build artifacts
```

List all commands:

```bash
just --list
```

## Features

- Language-agnostic command interface via `justfile`
- Automated versioning with conventional commits
- CI/CD with GitHub Actions
- Development container support
- Cross-platform (macOS, Linux, Windows via WSL)

## Customization

Fork this repository for your project:

1. **One-time organization setup** (optional) - See [Setup Guide](docs/setup.md)
   - Configure organization secrets for publishing (GCP_SA_KEY, NPM_TOKEN, etc.)
   - All scaffolded projects automatically inherit these secrets
   - Only needed if publishing to external registries
2. Run `just scaffold` to initialize
3. Edit `justfile` - replace TODO placeholders with your build commands
4. Commit using conventional commit format (feat:, fix:, docs:, etc.)
5. Push - CI/CD runs automatically

Example for Node.js:

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

Example for Python:

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
```

## Documentation

- [Setup Guide](docs/setup.md) - GitHub secrets, PAT configuration, and troubleshooting
- [Design](docs/design.md) - System overview, features, and key components
- [Architecture](docs/architecture.md) - Implementation details and internals

## Requirements

- bash 3.2+
- git

Run `just setup` to install remaining dependencies (just, docker, direnv, node).

## CI/CD Workflow

- Push to feature branch → Tests run
- Merge to main → Release workflow runs
  - semantic-release analyzes commits and creates version tag
  - Builds production artifacts
  - Publishes to registry (uses organization secrets)
  - Creates GitHub release

**Note:** Configure organization secrets once, and all scaffolded projects automatically work with CI/CD. See [Setup Guide](docs/setup.md).

## License

[Add your license here]
