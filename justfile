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
# Flags: --dev (development tools), --ci (CI essentials), --platform (platform dev)
setup *ARGS: _load
    @bash scripts/setup.sh {{ARGS}}

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
    @echo -e "{{SUCCESS}}Production artifact created: dist/artifact.txt{{NORMAL}}"

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
    @echo "{{INFO}}Publishing package $PROJECT@$VERSION...{{NORMAL}}"
    @gcloud artifacts generic upload \
        --project=$GCP_REGISTRY_PROJECT_ID \
        --location=$GCP_REGISTRY_REGION \
        --repository=$GCP_REGISTRY_NAME \
        --package=$PROJECT \
        --version=$VERSION \
        --source=dist/artifact.txt
    @echo "{{SUCCESS}}Published.{{NORMAL}}"

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

# Create new version based on commits (semantic-release)
upversion: _load
    @bash scripts/upversion.sh

# Authenticate with GCP (local: gcloud login, CI: service account)
registry-login *ARGS: _load
    #!/usr/bin/env bash
    set -euo pipefail
    if [[ " {{ARGS}} " =~ " --ci " ]]; then
        echo -e "{{INFO}}CI mode - authenticating with service account{{NORMAL}}"
        KEY_FILE=$(mktemp)
        echo "$GCP_SA_KEY" > "$KEY_FILE"
        gcloud auth activate-service-account --key-file="$KEY_FILE"
        rm -f "$KEY_FILE"
        gcloud config set project "$GCP_REGISTRY_PROJECT_ID"
    else
        echo -e "{{INFO}}Local mode - interactive GCP login{{NORMAL}}"
        gcloud auth login
        gcloud config set project "$GCP_REGISTRY_PROJECT_ID"
    fi

# Upgrade to newer platform version (requires Claude Code)
upgrade: _load
    @if command -v claude >/dev/null 2>&1; then \
        if grep -q "NV_PLATFORM=" .envrc 2>/dev/null; then \
            claude /upgrade; \
        else \
            echo -e "{{ERROR}}This project is not based on a platform{{NORMAL}}"; \
            echo ""; \
            echo "To adopt a platform, use the nv CLI:"; \
            echo "  nv scaffold <platform>"; \
            exit 1; \
        fi; \
    else \
        echo -e "{{ERROR}}Claude Code CLI not found{{NORMAL}}"; \
        echo "Install Claude Code or run: /upgrade"; \
        exit 1; \
    fi

# ==============================================================================
# PLATFORM DEVELOPMENT (Remove after scaffolding)
# ==============================================================================

# Run platform tests
[group('platform')]
platform-test: _load
    @if command -v bats >/dev/null 2>&1; then \
        echo -e "{{INFO}}Running platform tests...{{NORMAL}}"; \
        bats test/; \
    else \
        echo -e "{{ERROR}}bats not installed. Run: just setup --platform{{NORMAL}}"; \
        exit 1; \
    fi

# Create a new migration guide (requires Claude Code)
[group('platform')]
new-migration: _load
    @if command -v claude >/dev/null 2>&1; then \
        claude /new-migration; \
    else \
        echo -e "{{ERROR}}Claude Code CLI not found{{NORMAL}}"; \
        echo "Install Claude Code or run: /new-migration"; \
        exit 1; \
    fi
