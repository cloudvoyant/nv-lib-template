# Architecture

## Overview

`mise-lib-template` is a [`mise`](https://mise.jdx.dev/)-powered [1] language-agnostic template for building projects with automated versioning, testing, and GitHub Action powered CI/CD workflows.

## Design

- mise managed environment, dev, tools, etc.
- mise is used for running tasks
- certain tasks like `build-prod`, `test`, `publish`, etc. are used by GitHub Actions
- tasks can be overridder for your specific needs
- the build system is project structure agnostic, all that matters is that mise tasks work

## Implementation

### Mise For Environment & Tasks

Mise is the environment management tool and task runner for projects based on this template. Since mise can manage a large array of languages and tools, its a sensible choice for a language agnostic build system that hooks into CI/CD, and can easily be modified for any language.

### GitHub Actions For CI/CD

At this time this template is focused on GitHub usage, but it could easily be adapted to GitLab, etc. by hooking into appropriate mise tasks.

The `ci` worflow runs on feature branch commits and publishes pre-release packages for testing. The `release` workflow runs on merge to main, and is where `semantic-release` is used to bump versions and update the changelog.

### Claude Commands For Adapting / Upgrading

Claude commands provide LLM-assisted workflows for complex tasks. This is utilized to support adapting the template to any use-case, and upgrading to newer versions since both of these tasks are hard to accomplish with simpler scripting.

- `/adapt` - Template-only command for adapting to new languages (auto-deletes after use)
- `/upgrade` - Upgrade to the latest template version

### CI/CD Secrets

Org-level secrets are utilized to avoid the need for setting up secrets for every new project. This means, setup is only needed once.

For GCP (default):

- `GCP_SA_KEY` - Service account JSON key
- `GCP_REGISTRY_PROJECT_ID`, `GCP_REGISTRY_REGION`, `GCP_REGISTRY_NAME` - Registry configuration

For other registries (see [user-guide.md](user-guide.md#cicd-secrets) for details):

- npm: `NPM_TOKEN`
- PyPI: `PYPI_TOKEN`
- Docker Hub: `DOCKER_USERNAME`, `DOCKER_PASSWORD`

### Cross-Platform Support

The template works on macOS, Linux, and Windows (via WSL) without requiring users to install platform-specific tools. This broad compatibility reduces team onboarding friction and prevents "works on my machine" issues.

Key compatibility measures:

- Mise handles installation of tools across host platforms
- Line endings enforced to LF via `.editorconfig` (prevents git diff noise on Windows)
- `sed_inplace` is used for scaffodling (text-replacement) and handles differences between macOS and GNU sed (abstracts platform quirks)
- Bash 3.2+ required (macOS ships with Bash 3.2, avoiding Bash 4+ features ensures compatibility without upgrades)

### Docker & Dev-Containers

This is supported for workflows that may require containerization or publishing containers.

## References

- [mise - the dev tool manager](https://mise.jdx.dev/)
- [semantic-release](https://semantic-release.gitbook.io/)
- [bats-core bash testing](https://bats-core.readthedocs.io/)
- [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [GitHub Actions](https://docs.github.com/en/actions)
- [GCP Artifact Registry](https://cloud.google.com/artifact-registry/docs)
