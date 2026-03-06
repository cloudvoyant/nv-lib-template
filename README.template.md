# {{PROJECT_NAME}}

> A new project scaffolded from {{TEMPLATE_NAME}} (v{{TEMPLATE_VERSION}})

## Overview

[Add your project description here]

### Project Structure

```
.
├── docs/          # Documentation
├── .mise-tasks/   # Mise tasks and CI/CD hooks
└── .../           # [ SPECIFY PROJECT SPECIFIC DIRS ]
└── mise.toml      # Tool versions, tasks, and env vars
└── version.txt    # Project version
└── ...            # [ SPECIFY PROJECT SPECIFIC FILES ]
```

## Prerequisites

- bash 3.2+
- [mise](https://mise.jdx.dev/)
- [List other required tools and dependencies]

## Setup

```bash
# Install mise (if not already installed)
curl https://mise.jdx.dev/install.sh | sh

# Install project tools
mise install

```


## Quick Start

Type `mise tasks` to see all the tasks at your disposal:

```bash
mise tasks
```

Build, run and test with `mise run`:

```bash
mise run run

mise run test
```

Mise runs the necessary task dependencies automatically!

## Publishing

Commit using conventional commits (`feat:`, `fix:`, `docs:`). Merge/push to main and CI/CD will run automatically bumping your project version and publishing a package.

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
mise run publish
```

This will publish a pre-release package version.

### Registry Configuration

Publishing to artifact registries is optional. This project defaults to GCP Artifact Registry but can be configured for npm, PyPI, Docker Hub, etc.

Configure in `mise.toml` `[env]` section:

- **GCP Artifact Registry** (default): Set `GCP_REGISTRY_PROJECT_ID`, `GCP_REGISTRY_REGION`, `GCP_REGISTRY_NAME`
- **Other registries**: Update the `publish` task in `mise.toml` and add registry-specific variables to `[env]`

Examples:

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

See the [{{TEMPLATE_NAME}} User Guide](https://github.com/your-org/{{TEMPLATE_NAME}}/blob/main/docs/user-guide.md) for detailed configuration instructions.

## Documentation

To learn more about using this template, read the docs:

- [User Guide](docs/user-guide.md) - Complete setup and usage guide
- [Architecture](docs/architecture.md) - Design and implementation details

## References

- [mise - the dev tool manager](https://mise.jdx.dev/)
- [semantic-release](https://semantic-release.gitbook.io/)
- [bats-core bash testing](https://bats-core.readthedocs.io/)
- [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [GitHub Actions](https://docs.github.com/en/actions)
- [GCP Artifact Registry](https://cloud.google.com/artifact-registry/docs)
