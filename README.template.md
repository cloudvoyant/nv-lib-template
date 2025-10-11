# {{PROJECT_NAME}}

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

Publishing to artifact registries is optional. Configure in `.envrc`:

- **GCP Artifact Registry**: Uncomment and set `GCP_PROJECT_ID`, `GCP_REGION`, `GCP_REPOSITORY`
- **Other registries**: Update the `publish` recipe in `justfile`

See [docs/user-guide.md](docs/user-guide.md) for detailed setup and usage instructions.

## License

[Add license information here]
