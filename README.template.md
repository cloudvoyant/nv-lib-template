# {{PROJECT_NAME}}

![Version](https://img.shields.io/github/v/release/your-org/{{PROJECT_NAME}}?label=version)
![CI](https://github.com/your-org/{{PROJECT_NAME}}/workflows/CI/badge.svg)
![Release](https://github.com/your-org/{{PROJECT_NAME}}/workflows/Release/badge.svg)

> A new project scaffolded from the {{PLATFORM_NAME}} platform

## Overview

[Add your project description here]

## Prerequisites

- [List required tools and dependencies]

## Setup

```bash
# Install dependencies
just install

# Build the project
just build

# Run tests
just test
```

## Usage

[Add usage instructions here]

## Development

This project uses the [{{PLATFORM_NAME}}](https://github.com/your-org/{{PLATFORM_NAME}}) platform (v{{PLATFORM_VERSION}}).

### Available Commands

Run `just` to see all available commands.

### Project Structure

```
.
├── src/           # Source code
├── docs/          # Documentation
├── scripts/       # Build and utility scripts
└── justfile       # Build recipes
```

## Publishing

This project uses semantic versioning and automated releases via GitHub Actions.

### Release Process

1. **Make changes** on a feature branch
2. **Commit with conventional commits**:
   - `feat: add new feature` → minor version bump
   - `fix: resolve bug` → patch version bump
   - `feat!: breaking change` or `BREAKING CHANGE:` in footer → major version bump
3. **Push to GitHub** and create a pull request
4. **Merge to main** - the CI/CD pipeline will:
   - Run tests
   - Build artifacts
   - Generate changelog
   - Create GitHub release
   - Publish to registry (if configured)

### Manual Publishing

To publish manually:

```bash
# Ensure you're on main branch with clean working directory
just publish
```

### Registry Configuration

Publishing to artifact registries is optional. This project defaults to GCP Artifact Registry but can be configured for npm, PyPI, Docker Hub, etc.

Configure in `.envrc`:

- **GCP Artifact Registry** (default): Set `GCP_REGISTRY_PROJECT_ID`, `GCP_REGISTRY_REGION`, `GCP_REGISTRY_NAME`
- **Other registries**: Update the `publish` recipe in `justfile` and add registry-specific variables to `.envrc`

Examples:

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

See the [{{PLATFORM_NAME}} User Guide](https://github.com/your-org/{{PLATFORM_NAME}}/blob/main/docs/user-guide.md) for detailed configuration instructions.

## License

[Add license information here]
