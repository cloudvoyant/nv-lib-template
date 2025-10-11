#!/usr/bin/env bats

# Test that user-facing just commands are preserved in scaffolded projects

bats_require_minimum_version 1.5.0

setup() {
    # Create temp directories
    export TEST_PLATFORM_DIR="$(mktemp -d)"
    export TEST_PROJECT_DIR="$(mktemp -d)"

    # Copy platform to test location
    rsync -a \
        --exclude='.git' \
        --exclude='.nv' \
        --exclude='test/' \
        "${BATS_TEST_DIRNAME}/../" "$TEST_PLATFORM_DIR/"

    # Create a scaffolded project
    cd "$TEST_PLATFORM_DIR"
    bash scripts/scaffold.sh \
        --src "$TEST_PLATFORM_DIR" \
        --dest "$TEST_PROJECT_DIR" \
        --project test-project \
        --non-interactive
}

teardown() {
    # Clean up temp directories
    rm -rf "$TEST_PLATFORM_DIR"
    rm -rf "$TEST_PROJECT_DIR"
}

@test "scaffolded project has correct justfile commands" {
    cd "$TEST_PROJECT_DIR"

    # Should have upgrade command
    grep -q "^upgrade: _load" justfile

    # Upgrade command should call claude /upgrade
    grep -A 10 "^upgrade: _load" justfile | grep -q "claude /upgrade"

    # Should NOT have platform development commands
    run ! grep -q "^new-migration: _load" justfile

    # Should NOT have PLATFORM DEVELOPMENT section
    run ! grep -q "# PLATFORM DEVELOPMENT" justfile
}

@test "platform repository has all commands" {
    cd "$TEST_PLATFORM_DIR"

    # User-facing commands
    grep -q "^upgrade: _load" justfile

    # Platform development commands
    grep -q "^new-migration: _load" justfile

    # PLATFORM DEVELOPMENT section
    grep -q "# PLATFORM DEVELOPMENT" justfile
}
