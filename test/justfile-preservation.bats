#!/usr/bin/env bats

# Test that user-facing just commands are preserved in scaffolded projects

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

@test "scaffolded project has 'just upgrade' command" {
    cd "$TEST_PROJECT_DIR"
    grep -q "^upgrade: _load" justfile
}

@test "scaffolded project does NOT have 'just new-migration' command" {
    cd "$TEST_PROJECT_DIR"
    ! grep -q "^new-migration: _load" justfile
}

@test "scaffolded project does NOT have 'just new-platform' command" {
    cd "$TEST_PROJECT_DIR"
    ! grep -q "^new-platform: _load" justfile
}

@test "scaffolded project does NOT have PLATFORM DEVELOPMENT section" {
    cd "$TEST_PROJECT_DIR"
    ! grep -q "# PLATFORM DEVELOPMENT" justfile
}

@test "just upgrade command calls claude /upgrade" {
    cd "$TEST_PROJECT_DIR"
    grep -A 10 "^upgrade: _load" justfile | grep -q "claude /upgrade"
}

@test "platform repository has all commands" {
    cd "$TEST_PLATFORM_DIR"

    # User-facing commands
    grep -q "^upgrade: _load" justfile

    # Platform development commands
    grep -q "^new-migration: _load" justfile
    grep -q "^new-platform: _load" justfile
}

@test "platform repository has PLATFORM DEVELOPMENT section" {
    cd "$TEST_PLATFORM_DIR"
    grep -q "# PLATFORM DEVELOPMENT" justfile
}
