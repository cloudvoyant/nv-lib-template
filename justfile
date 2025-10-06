# justfile - Command runner for project automation
# Requires: just (https://github.com/casey/just)

set shell := ["bash", "-c"]

# Color codes for output
INFO := '\033[0;34m'
SUCCESS := '\033[0;32m'
WARN := '\033[1;33m'
ERROR := '\033[0;31m'
NORMAL := '\033[0m'

# Default recipe (show help)
default:
    @just --list

# Load environment variables from .envrc
_load:
    #!/usr/bin/env bash
    if [ -f .envrc ]; then
        source .envrc
    fi

# Setup development environment
setup: _load
    @bash scripts/setup.sh

# Install dependencies
install: _load
    @echo -e "{{WARN}}TODO: Implement install{{NORMAL}}"

# Build the project
build: _load
    @echo -e "{{WARN}}TODO: Implement build{{NORMAL}}"

# Build for production
build-prod: _load
    @mkdir -p dist
    @echo "$PROJECT $VERSION - Replace with your build artifact" > dist/artifact.txt
    @echo -e "{{SUCCESS}}✓ Production artifact created: dist/artifact.txt{{NORMAL}}"

# Clean build artifacts
clean: _load
    @echo -e "{{WARN}}TODO: Implement clean{{NORMAL}}"

# Run project locally
run: build
    @echo -e "{{WARN}}TODO: Implement run{{NORMAL}}"

# Run tests
test: build
    @echo -e "{{WARN}}TODO: Implement test{{NORMAL}}"

# Publish the project
publish: test build-prod
    @gcloud artifacts generic upload \
        --project=$GCP_PROJECT_ID \
        --location=$GCP_REGION \
        --repository=$GCP_REPOSITORY \
        --package=$PROJECT \
        --version=$VERSION \
        --source=dist/artifact.txt

# Scaffold a new project
scaffold: _load
    @bash scripts/scaffold.sh

# Format code
format *PATHS: _load
    @echo "{{WARN}}TODO: Implement formatting{{NORMAL}}"

# Check code formatting (CI mode)
format-check *PATHS: _load
    @echo "{{WARN}}TODO: Implement format checking{{NORMAL}}"

# Lint code
lint *PATHS: _load
    @echo "{{WARN}}TODO: Implement linting{{NORMAL}}"

# Lint and auto-fix issues
lint-fix *PATHS: _load
    @echo "{{WARN}}TODO: Implement lint auto-fixing{{NORMAL}}"

# Get current version
version: _load
    @bash -c 'source scripts/utils.sh && get_version'

# Get next version (from semantic-release)
version-next: _load
    @bash -c 'source scripts/utils.sh && get_next_version'

# Generate release notes with Claude
release-notes: _load
    @bash scripts/release-notes.sh
