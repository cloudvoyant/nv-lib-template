# Design

## Introduction

`platform-lib` is a language-agnostic platform for building SDKs that can be forked and customized for any programming language. The system provides a common set of development workflows (build, test, run, publish) that work consistently across different languages.

## Features

- Build, test, run, and publish workflows
- Automated versioning via conventional commits
- CI/CD with GitHub Actions (test on PR, release on merge, publish on tags)
- Development container support
- Cross-platform compatibility (macOS, Linux, Windows via WSL)
- IDE configuration (VS Code, EditorConfig)
- Direct customization by editing `justfile`

## Requirements

- `bash` - Core scripting language
- `just` - Command runner
- `direnv` - Environment management
- `docker` - Containerization
- `semantic-release` - Automated versioning
- `claude` - LLM assistant
- GitHub Actions - CI/CD

## Design Principles

1. **Run from anywhere** - Scripts work when called from any directory in the repo
2. **Centralized config** - All configuration lives in `.envrc`, sourced by `utils.sh`
3. **Fail fast** - Use `set -euo pipefail` everywhere for immediate error detection
4. **Self-documenting** - Every script includes usage documentation
5. **Language agnostic** - Detect and adapt to different languages and tools
6. **No external dependencies** - Pure bash with minimal tooling requirements

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
- `just scaffold` - Initialize a forked project
- `just` - Show all available commands

Claude commands:
- `/generate-release-notes` - Generate user-friendly release notes
- `/validate-docs` - Validate documentation consistency
- `/upgrade` - Upgrade to newer platform version

Commands support task dependencies. For example, `test` depends on `build`, ensuring builds run before tests:

```bash
just test                    # Runs build, then test
just format src/             # Accepts path arguments
```

The `publish` command depends on `test` (which tests the dev build) and `build-prod` (which creates production artifacts):

Tests always run on the development build. Production builds are created for publishing but not separately tested.

Default implementation publishes to GCP Artifact Registry. Customize the `publish` recipe for your needs (npm, PyPI, Docker, etc.).

### Setup and Scaffolding

The `scripts/setup.sh` installs dependencies (bash, just, docker, direnv, node) across different platforms. It detects the OS and uses the appropriate package manager.

The `scripts/scaffold.sh` initializes a forked project by prompting for project details and replacing template strings.

### CI/CD Workflows

Two GitHub Actions workflows handle automation:

- `ci.yml` - Runs tests and builds on pull requests
- `release.yml` - Creates releases, publishes, and tags when merged to main

The release workflow is combined for simplicity - it runs semantic-release, then immediately publishes if a new version was created. No separate workflows or Personal Access Tokens required.

### Trunk Based Development With Automated Versioning

Use conventional commits (feat:, fix:, docs:, etc.) with semantic-release to automatically:

- Analyze commits since last release
- Determine next version number
- Create git tags
- Update CHANGELOG.md
- Create GitHub releases

The `VERSION` variable in `.envrc` lists the current version and is managed by `semantic-release` in CI/CD.

### Release Notes

Hybrid approach for release documentation:

- `CHANGELOG.md` - Auto-generated from commits (technical log)
- `RELEASE_NOTES.md` - Human-written, Claude-assisted (user-friendly)

Workflow:

```bash
/generate-release-notes     # Claude analyzes CHANGELOG and generates RELEASE_NOTES.md
# Review and edit RELEASE_NOTES.md
git add RELEASE_NOTES.md
git commit -m "docs: release notes for v1.2.0"
git push                    # Triggers release with both changelogs
```

Claude CLI generates user-focused descriptions explaining impact and improvements, while the automated changelog maintains a complete technical record.

### Publishing

The `publish` recipe handles publishing artifacts. Default implementation uploads to GCP Artifact Registry.

Customize for your language/registry by editing the `publish` recipe directly:

**npm:**

```just
publish: test build-prod
    npm publish
```

Configure registry variables in `.envrc`:

```bash
export GCP_PROJECT_ID="your-project-id"
export GCP_REGION="us-central1"
export GCP_REPOSITORY="your-repository"
```
