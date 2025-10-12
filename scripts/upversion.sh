#!/usr/bin/env bash
: <<DOCUMENTATION
Analyzes commits and creates a new version using semantic-release.

This script wraps semantic-release to provide a consistent interface for
version management across local and CI environments.

Usage:
  bash scripts/upversion.sh

Behavior:
- Analyzes commits since last release
- Determines next version based on conventional commits
- Updates CHANGELOG.md
- Creates git tag
- Pushes tag to remote (in CI only)

Outputs (for CI):
- new_release_published: true/false
- new_release_version: X.Y.Z

LANGUAGE-SPECIFIC PLUGINS:
Configure in .releaserc.json or package.json

Python: Update version in setup.py/pyproject.toml
  npm install --save-dev @semantic-release/exec
  Add to .releaserc.json:
    "plugins": [
      ["@semantic-release/exec", {
        "prepareCmd": "sed -i 's/version=\".*\"/version=\"\${nextRelease.version}\"/' setup.py"
      }]
    ]

Go: Update version in go.mod or version file
  Similar @semantic-release/exec configuration

Rust: Update Cargo.toml version
  Similar @semantic-release/exec configuration

Node: Uses @semantic-release/npm by default
DOCUMENTATION

# IMPORTS ----------------------------------------------------------------------
source "$(dirname "$0")/utils.sh"
setup_script_lifecycle

# MAIN -------------------------------------------------------------------------

log_info "Running semantic-release..."

# Check if npx is available
if ! command_exists npx; then
    log_error "npx not found. Install Node.js: just setup --ci"
    exit 1
fi

# Run semantic-release
# Note: Outputs are captured by semantic-release GitHub Action in CI
# For local runs, this will just show the dry-run results
if [ -n "$CI" ]; then
    log_info "Running in CI mode - will create release and push"
    npx semantic-release
else
    log_info "Running in local mode - dry-run only (no tags will be created)"
    npx semantic-release --dry-run
fi

# Capture exit code
EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    log_success "Semantic-release completed successfully"
else
    log_error "Semantic-release failed with exit code $EXIT_CODE"
    exit $EXIT_CODE
fi

# In CI, semantic-release outputs are handled by the GitHub Action
# The GitHub Action (cycjimmy/semantic-release-action) automatically sets:
# - steps.semantic_release.outputs.new_release_published
# - steps.semantic_release.outputs.new_release_version

log_info "Version update complete"
