# nv-lib

![Version](https://img.shields.io/github/v/release/cloudvoyant/nv-lib?label=version)
![CI](https://github.com/cloudvoyant/nv-lib/workflows/CI/badge.svg)
![Release](https://github.com/cloudvoyant/nv-lib/workflows/Release/badge.svg)

Language-agnostic template for building projects with automated versioning, testing, and CI/CD workflows. GCP-forward by default, but easily adapted for npm, PyPI, Docker Hub, etc.

## Features

- Language-agnostic command interface via `justfile`
- Auto-load environment variables with `direnv` for simplified scripting and CLI tool usage
- Easy CI/CD customization with platform agnostic bash scripting
- Automated versioning with conventional commits
- CI/CD with GitHub Actions (test on PR, tag and release on merge)
- GCP Artifact Registry publishing (easily modified for other registries)
- Dev container support
- Cross-platform (macOS, Linux, Windows via WSL)

## Quick Start

Scaffold a new project:

```bash
# Option 1: Nedavellir CLI (automated)
nv create your-project-name --platform nv-lib

# Option 2: GitHub template + scaffold script
# Click "Use this template" on GitHub, then:
git clone <your-new-repo>
cd <your-new-repo>
bash scripts/scaffold.sh --src . --dest . --project your-project-name
```

Install dependencies and adapt:

```bash
just setup              # Required: bash, just, direnv
direnv allow            # Load environment
claude /adapt           # Guided customization
```

## How It Works

The template follows a simple flow:

```
direnv → just → scripts → GitHub Actions
                ↓
              Claude (for complex workflows)
```

Customize by editing `justfile` recipes for your language. Override CI/CD behavior by editing scripts in `scripts/`, never workflows directly.

## Getting Started

1. Scaffold from template (see Quick Start above)
2. Edit `justfile` - replace TODO placeholders with language-specific commands
3. Configure `.envrc` for your registry (GCP by default, or npm/PyPI/Docker)
4. Commit using conventional commits (`feat:`, `fix:`, `docs:`)
5. Push to main - CI/CD runs automatically

Example justfile customization:

```just
# Node.js
install:
    npm install

build:
    npm run build

test: build
    npm test

publish: test build-prod
    npm publish
```

Use `/adapt` command for guided setup with examples for Python, Node.js, Go, Docker, etc.

## Documentation

- [User Guide](docs/user-guide.md) - Complete setup and usage guide
- [Architecture](docs/architecture.md) - Design and implementation details

## Requirements

- bash 3.2+
- git

Run `just setup` to install remaining dependencies (just, direnv).

Optional: `just setup --dev` for development tools, `just setup --template` for template testing.

## License

[Add your license here]
