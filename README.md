# mise-lib-template

![Version](https://img.shields.io/github/v/release/cloudvoyant/mise-lib-template?label=version)
![Release](https://github.com/cloudvoyant/mise-lib-template/workflows/Release/badge.svg)

`mise-lib-template` is a template for building projects with automated versioning, testing, and GitHub Action powered CI/CD workflows. It is equipped with powerfulw scaffolding capabilities that support the following use cases:

1. language agnostic libs built around mise -> adapt these as you need
2. uv based python packages
3. zig libraries and executables

## Features

Here's what this template gives you off the bat:

- A language-agnostic self-documenting task runner via `mise`. Keep all your project commands organized in `mise.toml` and `.mise-tasks/`.
- Environment variables and tool versions managed in `mise.toml` — no separate `direnv` or `.envrc` needed.
- CI/CD with GitHub Actions - run test on MR commits, tag and release on merges to main.
- Easy CI/CD customization with language-agnostic bash scripting - No need to get too deep into GitHub Actions for customization. Modify the publish recipe, set GitHub Secrets and you're good to go.
- Trunk based development and automated versioning with conventional commits - semantic-release will handle version bumping for you! Work on feature branches and merge to main for bumps.
- GCP Artifact Registry publishing (easily modified for other registries)
- Cross-platform (macOS, Linux, Windows via WSL) - run `mise install` to install dependencies, or alternately develop with Dev Containers or run tasks via Docker

## Requirements

- bash 3.2+
- [mise](https://mise.jdx.dev/getting-started.html)

Run `mise install` to install all tools, then `mise run install` for npm dependencies.

## Quick Start

Scaffold a new project:

```bash
# Click "Use this template" on GitHub, then:
git clone <your-new-repo>
cd <your-new-repo>
bash .mise-tasks/scaffold --project your-project-name [--template uv|zig]
```

Or just run the scaffold script without flags for an interactive setup!

Install dependencies and adapt the template for your needs:

```bash
mise install            # Install all tools (node, shellcheck, shfmt, gcloud, claude, etc.)
mise run install        # Install npm dependencies (semantic-release and plugins)
claude /adapt           # Guided customization for your language / package manager
```

Type `mise tasks` to see all available tasks:

```bash
❯ mise tasks
build        Build the project
clean        Clean build artifacts
install      Install dependencies
publish      Publish package to registry
run          Run project locally
test         Run tests
...
```

Build, run, and test with `mise run`. The template will show TODO messages in console prior to adapting:

```bash
❯ mise run run
TODO: Implement build for mise-lib-template@2.0.0
TODO: Implement run

❯ mise run test
TODO: Implement build for mise-lib-template@2.0.0
TODO: Implement test
```

Task dependencies run automatically — `mise run test` runs `build` first!

Commit using conventional commits (`feat:`, `fix:`, `docs:`). Merge/push to main and CI/CD will run automatically bumping your project version and publishing a package.

## Templates

This template supports three modes:

| Template | Language | Package Manager | Test Framework | Publish Target        |
| -------- | -------- | --------------- | -------------- | --------------------- |
| agnostic | (any)    | —               | —              | GCP Artifact Registry |
| uv       | Python   | uv              | pytest         | PyPI                  |
| zig      | Zig      | zig build       | zig test       | GitHub Releases       |

## Documentation

To learn more about using this template, read the docs:

- [User Guide](docs/user-guide.md) - Complete setup and usage guide
- [Architecture](docs/architecture.md) - Design and implementation details

## References

- [mise - dev tool manager](https://mise.jdx.dev/)
- [semantic-release](https://semantic-release.gitbook.io/)
- [bats-core bash testing](https://bats-core.readthedocs.io/)
- [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [GitHub Actions](https://docs.github.com/en/actions)
- [GCP Artifact Registry](https://cloud.google.com/artifact-registry/docs)
