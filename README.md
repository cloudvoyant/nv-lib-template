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

1. Run `just scaffold` to initialize
2. Edit `justfile` - replace TODO placeholders with your build commands
3. Configure GitHub Secrets for publishing (optional)
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

- [Design](docs/design.md) - System overview, features, and key components
- [Architecture](docs/architecture.md) - Implementation details and internals

## Requirements

- bash 3.2+
- git

Run `just setup` to install remaining dependencies (just, docker, direnv, node).

## CI/CD Workflow

- Push to feature branch → Tests run
- Merge to main → Release created (semantic-release analyzes commits)
- Version tag created → Package published

## License

[Add your license here]
