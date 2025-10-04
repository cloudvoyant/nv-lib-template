# justfile - Command runner for project automation
# Requires: just (https://github.com/casey/just)

set shell := ["bash", "-c"]

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
    @echo "{{YELLOW}}TODO: Implement install{{NORMAL}}"

# Build the project
build: _load
    @echo "{{YELLOW}}TODO: Implement build{{NORMAL}}"

# Build for production
build-prod: _load
    @echo "{{YELLOW}}TODO: Implement production build{{NORMAL}}"

# Clean build artifacts
clean: _load
    @echo "{{YELLOW}}TODO: Implement clean{{NORMAL}}"

# Run project locally
run: build
    @echo "{{YELLOW}}TODO: Implement run{{NORMAL}}"

# Run tests
test: build
    @echo "{{YELLOW}}TODO: Implement test{{NORMAL}}"

# Publish the project
publish: test build-prod
    @echo "{{YELLOW}}TODO: Implement publish{{NORMAL}}"

# Scaffold a new project
scaffold: _load
    @bash scripts/scaffold.sh

# Format code
format *PATHS: _load
    @echo "{{YELLOW}}TODO: Implement formatting{{NORMAL}}"

# Check code formatting (CI mode)
format-check *PATHS: _load
    @echo "{{YELLOW}}TODO: Implement format checking{{NORMAL}}"

# Lint code
lint *PATHS: _load
    @echo "{{YELLOW}}TODO: Implement linting{{NORMAL}}"

# Lint and auto-fix issues
lint-fix *PATHS: _load
    @echo "{{YELLOW}}TODO: Implement lint auto-fixing{{NORMAL}}"

# Get current version
version: _load
    @bash -c 'source scripts/utils.sh && get_version'

# Get next version (from semantic-release)
version-next: _load
    @bash -c 'source scripts/utils.sh && get_next_version'

# Generate release notes with Claude
release-notes: _load
    @bash scripts/release-notes.sh
