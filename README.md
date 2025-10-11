# platform-lib

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

Create a new project from this template:

1. Use GitHub's "Use this template" button or Nedavellir CLI
2. Run scaffold script to customize for your project
3. Edit `justfile` - replace TODO placeholders with your build commands
4. Configure CI/CD secrets (optional) - See [User Guide](docs/user-guide.md#cicd-configuration)
5. Commit using conventional commit format (feat:, fix:, docs:, etc.)
6. Push - CI/CD runs automatically

**Full instructions:** See the [User Guide](docs/user-guide.md)

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

- [User Guide](docs/user-guide.md) - Complete guide for creating and managing projects
- [Design](docs/design.md) - System overview, features, and key components
- [Architecture](docs/architecture.md) - Implementation details and internals
- [Migration Guides](docs/migrations/) - Version upgrade instructions

## Requirements

- bash 3.2+
- git

Run `just setup` to install required dependencies (just, direnv).

For optional dependencies (docker, node, shellcheck, shfmt), run:

```bash
bash scripts/setup.sh --include-optional
```

## CI/CD Workflow

- Push to feature branch → Tests run
- Merge to main → Release workflow runs
  - semantic-release analyzes commits and creates version tag
  - Builds production artifacts
  - Publishes to registry (uses organization secrets)
  - Creates GitHub release

**Note:** Configure organization secrets once, and all scaffolded projects automatically work with CI/CD. See [User Guide](docs/user-guide.md#cicd-configuration).

## Development

### Platform Testing

Run platform tests:

```bash
just platform-test
```

**TODO: Migration Tests**

- Current tests don't actually test real migrations
- Need to implement proper integration tests:
  1. Clone platform to `.nv/platform-old` and checkout old git tag
  2. Scaffold project from old version
  3. Run `just upgrade` with auto-accept mode
  4. Validate migration succeeded
- See `.claude/plan.md` for detailed approach

**TODO: Platform Generalization**

- Make platform registry-agnostic by removing GCP-specific defaults
- Move GCP config from `.envrc` to optional `.env` file
- Update CI/CD workflows to support multiple registries without hardcoded defaults

## License

[Add your license here]
