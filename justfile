# justfile - Command runner for project automation
# Requires: just (https://github.com/casey/just)

set shell   := ["bash", "-c"]

# Dependencies
bash        := require("bash")
direnv      := require("direnv")

# Color codes for output
INFO        := '\033[0;34m'
SUCCESS     := '\033[0;32m'
WARN        := '\033[1;33m'
ERROR       := '\033[0;31m'
NORMAL      := '\033[0m'

# ==============================================================================
# CORE DEVELOPMENT
# ==============================================================================

# Default recipe (show help)
_default:
    @just --list --unsorted

# Load environment
[group('dev')]
load:
    @direnv allow

# Install dependencies
[group('dev')]
install:
    @echo -e "{{WARN}}TODO: Implement install{{NORMAL}}"

# Build the project
[group('dev')]
build:
    @echo -e "{{WARN}}TODO: Implement build for $PROJECT@$VERSION{{NORMAL}}"

# Run project locally
[group('dev')]
run: build
    @echo -e "{{WARN}}TODO: Implement run{{NORMAL}}"

# Run tests
[group('dev')]
test: build
    @echo -e "{{WARN}}TODO: Implement test{{NORMAL}}"

# Clean build artifacts
[group('dev')]
clean:
    @echo -e "{{WARN}}TODO: Implement clean{{NORMAL}}"

# ==============================================================================
# UTILITIES
# ==============================================================================

# Setup development environment
[group('utils')]
setup *ARGS:
    @bash scripts/setup.sh {{ARGS}}

# Format code
[group('utils')]
format *PATHS:
    @echo -e "{{WARN}}TODO: Implement formatting{{NORMAL}}"

# Check code formatting (CI mode)
[group('utils')]
format-check *PATHS:
    @echo -e "{{WARN}}TODO: Implement format checking{{NORMAL}}"

# Lint code
[group('utils')]
lint *PATHS:
    @echo -e "{{WARN}}TODO: Implement linting{{NORMAL}}"

# Lint and auto-fix issues
[group('utils')]
lint-fix *PATHS:
    @echo -e "{{WARN}}TODO: Implement lint auto-fixing{{NORMAL}}"

# Upgrade to newer template version (requires Claude Code)
[group('utils')]
upgrade:
    #!/usr/bin/env bash
    if command -v claude >/dev/null 2>&1; then
        if grep -q "NV_PLATFORM=" .envrc 2>/dev/null; then
            claude /upgrade;
        else
            echo -e "{{ERROR}}This project is not based on a template{{NORMAL}}";
            echo "";
            echo "To adopt a template, use the nv CLI:";
            echo "  nv scaffold <template>";
            exit 1;
        fi;
    else
        echo -e "{{ERROR}}Claude Code CLI not found{{NORMAL}}";
        echo "Install Claude Code or run: /upgrade";
        exit 1;
    fi

# Authenticate with GCP (local: gcloud login, CI: service account)
[group('utils')]
registry-login *ARGS:
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

# ==============================================================================
# CI/CD
# ==============================================================================

# Build for production
[group('ci')]
build-prod:
    @mkdir -p dist
    @echo "$PROJECT $VERSION - Replace with your build artifact" > dist/artifact.txt
    @echo -e "{{SUCCESS}}Production artifact created: dist/artifact.txt{{NORMAL}}"

# Get current version
[group('ci')]
version:
    @echo "$VERSION"

# Get next version (from semantic-release)
[group('ci')]
version-next:
    @bash -c 'source scripts/utils.sh && get_next_version'

# Create new version based on commits (semantic-release)
[group('ci')]
upversion *ARGS:
    @bash -c scripts/upversion.sh {{ARGS}}

# Publish the project
[group('ci')]
publish: test build-prod
    #!/usr/bin/env bash
    set -euo pipefail

    # Load environment variables
    if [ -f .envrc ]; then
        source .envrc
    fi

    echo -e "{{INFO}}Publishing package $PROJECT@$VERSION...{{NORMAL}}"
    gcloud artifacts generic upload \
        --project=$GCP_REGISTRY_PROJECT_ID \
        --location=$GCP_REGISTRY_REGION \
        --repository=$GCP_REGISTRY_NAME \
        --package=$PROJECT \
        --version=$VERSION \
        --source=dist/artifact.txt
    echo -e "{{SUCCESS}}Published.{{NORMAL}}"

# ==============================================================================
# TEMPLATE
# ==============================================================================

# Scaffold a new project
[group('template')]
scaffold:
    @bash scripts/scaffold.sh

# Run template tests
[group('template')]
template-test:
    #!/usr/bin/env bash
    if command -v bats >/dev/null 2>&1; then
        echo -e "{{INFO}}Running template tests...{{NORMAL}}";
        bats test/;
    else
        echo -e "{{ERROR}}bats not installed. Run: just setup --template{{NORMAL}}";
        exit 1;
    fi
