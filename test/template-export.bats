#!/usr/bin/env bats
# Tests for GitHub template export behavior
#
# Validates that export-ignore attributes in .gitattributes correctly
# exclude platform-specific files when using "Use this template" on GitHub.
#
# GitHub uses `git archive` to create templates, which respects export-ignore.
#
# Install bats: brew install bats-core
# Run: bats test/template-export.bats

setup() {
    export ORIGINAL_DIR="$PWD"

    # Create temporary directory for testing
    export TEST_DIR="$(mktemp -d)"
    export ARCHIVE_FILE="$TEST_DIR/template.tar"
    export EXTRACT_DIR="$TEST_DIR/extracted"

    # Must be in a git repo for git archive to work
    # The test assumes we're running from the platform repo itself
    if [ ! -d ".git" ]; then
        skip "Must run from git repository root"
    fi
}

teardown() {
    # Clean up test directory
    cd "$ORIGINAL_DIR"
    rm -rf "$TEST_DIR"
}

@test "git archive command works" {
    run git archive --format=tar --output="$ARCHIVE_FILE" HEAD

    [ "$status" -eq 0 ]
    [ -f "$ARCHIVE_FILE" ]
}

@test "export-ignore excludes test/ directory from archive" {
    git archive --format=tar --output="$ARCHIVE_FILE" HEAD
    mkdir -p "$EXTRACT_DIR"
    tar -xf "$ARCHIVE_FILE" -C "$EXTRACT_DIR"

    [ ! -d "$EXTRACT_DIR/test" ]
}

@test "export-ignore excludes docs/migrations/ from archive" {
    git archive --format=tar --output="$ARCHIVE_FILE" HEAD
    mkdir -p "$EXTRACT_DIR"
    tar -xf "$ARCHIVE_FILE" -C "$EXTRACT_DIR"

    [ ! -d "$EXTRACT_DIR/docs/migrations" ]
}

@test "export-ignore excludes CHANGELOG.md from archive" {
    git archive --format=tar --output="$ARCHIVE_FILE" HEAD
    mkdir -p "$EXTRACT_DIR"
    tar -xf "$ARCHIVE_FILE" -C "$EXTRACT_DIR"

    [ ! -f "$EXTRACT_DIR/CHANGELOG.md" ]
}

@test "export-ignore excludes RELEASE_NOTES.md from archive" {
    git archive --format=tar --output="$ARCHIVE_FILE" HEAD
    mkdir -p "$EXTRACT_DIR"
    tar -xf "$ARCHIVE_FILE" -C "$EXTRACT_DIR"

    [ ! -f "$EXTRACT_DIR/RELEASE_NOTES.md" ]
}

@test "export-ignore excludes scripts/platform-install.sh from archive" {
    git archive --format=tar --output="$ARCHIVE_FILE" HEAD
    mkdir -p "$EXTRACT_DIR"
    tar -xf "$ARCHIVE_FILE" -C "$EXTRACT_DIR"

    [ ! -f "$EXTRACT_DIR/scripts/platform-install.sh" ]
}

@test "export-ignore excludes .claude/plan.md from archive" {
    git archive --format=tar --output="$ARCHIVE_FILE" HEAD
    mkdir -p "$EXTRACT_DIR"
    tar -xf "$ARCHIVE_FILE" -C "$EXTRACT_DIR"

    [ ! -f "$EXTRACT_DIR/.claude/plan.md" ]
}

@test "export-ignore excludes .claude/migrations/generate-migration-guide.md from archive" {
    git archive --format=tar --output="$ARCHIVE_FILE" HEAD
    mkdir -p "$EXTRACT_DIR"
    tar -xf "$ARCHIVE_FILE" -C "$EXTRACT_DIR"

    [ ! -f "$EXTRACT_DIR/.claude/migrations/generate-migration-guide.md" ]
}

@test "export-ignore excludes .claude/commands/new-migration.md from archive" {
    git archive --format=tar --output="$ARCHIVE_FILE" HEAD
    mkdir -p "$EXTRACT_DIR"
    tar -xf "$ARCHIVE_FILE" -C "$EXTRACT_DIR"

    [ ! -f "$EXTRACT_DIR/.claude/commands/new-migration.md" ]
}

@test "export-ignore excludes .claude/commands/new-platform.md from archive" {
    git archive --format=tar --output="$ARCHIVE_FILE" HEAD
    mkdir -p "$EXTRACT_DIR"
    tar -xf "$ARCHIVE_FILE" -C "$EXTRACT_DIR"

    [ ! -f "$EXTRACT_DIR/.claude/commands/new-platform.md" ]
}

@test "archive includes important platform files" {
    git archive --format=tar --output="$ARCHIVE_FILE" HEAD
    mkdir -p "$EXTRACT_DIR"
    tar -xf "$ARCHIVE_FILE" -C "$EXTRACT_DIR"

    # Verify essential files are present
    [ -f "$EXTRACT_DIR/README.md" ]
    [ -f "$EXTRACT_DIR/.envrc" ]
    [ -f "$EXTRACT_DIR/justfile" ]
    [ -f "$EXTRACT_DIR/scripts/scaffold.sh" ]
    [ -d "$EXTRACT_DIR/.claude" ]
}

@test "archive includes user-facing .claude files" {
    git archive --format=tar --output="$ARCHIVE_FILE" HEAD
    mkdir -p "$EXTRACT_DIR"
    tar -xf "$ARCHIVE_FILE" -C "$EXTRACT_DIR"

    # User-facing migration workflows should be included
    [ -f "$EXTRACT_DIR/.claude/migrations/detect-scaffolded-version.md" ]
    [ -f "$EXTRACT_DIR/.claude/migrations/assist-project-migration.md" ]
    [ -f "$EXTRACT_DIR/.claude/migrations/validate-project-migration.md" ]
    [ -f "$EXTRACT_DIR/.claude/commands/upgrade.md" ]
}

@test "archive includes docs/ but not docs/migrations/" {
    git archive --format=tar --output="$ARCHIVE_FILE" HEAD
    mkdir -p "$EXTRACT_DIR"
    tar -xf "$ARCHIVE_FILE" -C "$EXTRACT_DIR"

    # docs/ should exist
    [ -d "$EXTRACT_DIR/docs" ]

    # but docs/migrations/ should NOT
    [ ! -d "$EXTRACT_DIR/docs/migrations" ]
}

@test "archive includes scripts/ but not scripts/platform-install.sh" {
    git archive --format=tar --output="$ARCHIVE_FILE" HEAD
    mkdir -p "$EXTRACT_DIR"
    tar -xf "$ARCHIVE_FILE" -C "$EXTRACT_DIR"

    # scripts/ should exist
    [ -d "$EXTRACT_DIR/scripts" ]

    # scripts/scaffold.sh should be included
    [ -f "$EXTRACT_DIR/scripts/scaffold.sh" ]

    # but scripts/platform-install.sh should NOT
    [ ! -f "$EXTRACT_DIR/scripts/platform-install.sh" ]
}

@test "validates all platform-specific files are excluded in one archive" {
    git archive --format=tar --output="$ARCHIVE_FILE" HEAD
    mkdir -p "$EXTRACT_DIR"
    tar -xf "$ARCHIVE_FILE" -C "$EXTRACT_DIR"

    # All platform development files should be excluded
    [ ! -d "$EXTRACT_DIR/test" ]
    [ ! -d "$EXTRACT_DIR/docs/migrations" ]
    [ ! -f "$EXTRACT_DIR/CHANGELOG.md" ]
    [ ! -f "$EXTRACT_DIR/RELEASE_NOTES.md" ]
    [ ! -f "$EXTRACT_DIR/scripts/platform-install.sh" ]
    [ ! -f "$EXTRACT_DIR/.claude/plan.md" ]
    [ ! -f "$EXTRACT_DIR/.claude/migrations/generate-migration-guide.md" ]
    [ ! -f "$EXTRACT_DIR/.claude/commands/new-migration.md" ]
    [ ! -f "$EXTRACT_DIR/.claude/commands/new-platform.md" ]
}
