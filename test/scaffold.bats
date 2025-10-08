#!/usr/bin/env bats
# Tests for scripts/scaffold.sh
#
# Install bats: brew install bats-core
# Run: bats test/scaffold.bats

setup() {
    export ORIGINAL_DIR="$PWD"

    # Create temporary project directory with test name for easier debugging
    # BATS encodes special chars as -XX (hex), decode them using perl
    TEST_NAME_DECODED=$(printf '%s' "$BATS_TEST_NAME" | perl -pe 's/-([0-9a-f]{2})/chr(hex($1))/gie')
    TEST_NAME_SANITIZED=$(printf '%s' "$TEST_NAME_DECODED" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/-\+/-/g')
    export PROJECT_DIR="$ORIGINAL_DIR/.nv/$TEST_NAME_SANITIZED"
    mkdir -p "$PROJECT_DIR"

    # Clone platform repo to project/.nv/$PROJECT (simulating nv CLI behavior)
    export PLATFORM_CLONE="$PROJECT_DIR/.nv/$PROJECT"
    mkdir -p "$PLATFORM_CLONE"

    # Copy all files except .git and gitignored directories to platform clone
    rsync -a \
        --exclude='.git' \
        --exclude='.nv' \
        "$ORIGINAL_DIR/" "$PLATFORM_CLONE/"

    # Set up test variables
    export DEST_DIR="$PROJECT_DIR"
    export SRC_DIR="$PLATFORM_CLONE"

    # Change to the platform clone directory (where scaffold will be called from)
    cd "$PLATFORM_CLONE"
}

teardown() {
    # Clean up test directories
    cd "$ORIGINAL_DIR"
    rm -rf "$PROJECT_DIR"
}

@test "scaffold.sh requires --src and --dest" {
    run bash ./scripts/scaffold.sh

    [ "$status" -eq 1 ]
    [[ "$output" == *"--src and --dest are required"* ]]
}

@test "scaffold.sh validates source directory exists" {
    run bash ./scripts/scaffold.sh --src /nonexistent --dest ../..

    [ "$status" -eq 1 ]
    [[ "$output" == *"Source directory does not exist"* ]]
}

@test "scaffold.sh validates destination directory exists" {
    run bash ./scripts/scaffold.sh --src . --dest /nonexistent

    [ "$status" -eq 1 ]
    [[ "$output" == *"Destination directory does not exist"* ]]
}

@test "non-interactive mode with custom project name" {
    run bash ./scripts/scaffold.sh \
        --src . \
        --dest ../.. \
        --non-interactive \
        --project myproject

    [ "$status" -eq 0 ]
    [[ "$output" == *"project=myproject"* ]]
}

@test "validates project name - rejects invalid characters" {
    run bash ./scripts/scaffold.sh \
        --src . \
        --dest ../.. \
        --non-interactive \
        --project "my project"

    [ "$status" -eq 1 ]
    [[ "$output" == *"Invalid project name"* ]]
}

@test "validates project name - accepts valid characters" {
    run bash ./scripts/scaffold.sh \
        --src . \
        --dest ../.. \
        --non-interactive \
        --project "my-valid_project123"

    [ "$status" -eq 0 ]
}

@test "updates .envrc with project name in destination" {
    bash ./scripts/scaffold.sh \
        --src . \
        --dest ../.. \
        --non-interactive \
        --project testproject

    run grep "export PROJECT=testproject" "$DEST_DIR/.envrc"
    [ "$status" -eq 0 ]
}

@test "adds NV_PLATFORM to destination .envrc" {
    bash ./scripts/scaffold.sh \
        --src . \
        --dest ../.. \
        --non-interactive \
        --project testproject

    run grep "NV_PLATFORM=" "$DEST_DIR/.envrc"
    [ "$status" -eq 0 ]
    [[ "$output" == *"$PROJECT"* ]]
}

@test "adds NV_PLATFORM_VERSION to destination .envrc" {
    bash ./scripts/scaffold.sh \
        --src . \
        --dest ../.. \
        --non-interactive \
        --project testproject

    run grep "NV_PLATFORM_VERSION=" "$DEST_DIR/.envrc"
    [ "$status" -eq 0 ]
    [[ "$output" == *"$VERSION"* ]]
}

@test "resets VERSION to 0.1.0 in destination .envrc" {
    bash ./scripts/scaffold.sh \
        --src . \
        --dest ../.. \
        --non-interactive \
        --project testproject

    run grep "^export VERSION=" "$DEST_DIR/.envrc"
    [ "$status" -eq 0 ]
    [[ "$output" == *"0.1.0"* ]]
}

@test "does not add duplicate NV_PLATFORM on second run" {
    bash ./scripts/scaffold.sh \
        --src . \
        --dest ../.. \
        --non-interactive \
        --project testproject

    bash ./scripts/scaffold.sh \
        --src . \
        --dest ../.. \
        --non-interactive \
        --project testproject

    count=$(grep -c "NV_PLATFORM=" "$DEST_DIR/.envrc")
    [ "$count" -eq 1 ]
}

@test "keeps .claude/ directory when --keep-claude is set" {
    mkdir -p "$DEST_DIR/.claude"
    touch "$DEST_DIR/.claude/plan.md" "$DEST_DIR/.claude/workflows.md" "$DEST_DIR/.claude/tasks.md"

    bash ./scripts/scaffold.sh \
        --src . \
        --dest ../.. \
        --non-interactive \
        --project testproject \
        --keep-claude

    [ -f "$DEST_DIR/.claude/plan.md" ]
    [ -f "$DEST_DIR/.claude/workflows.md" ]
    [ -f "$DEST_DIR/.claude/tasks.md" ]
}

@test "removes .claude/plan.md by default" {
    mkdir -p "$DEST_DIR/.claude"
    touch "$DEST_DIR/.claude/plan.md" "$DEST_DIR/.claude/workflows.md" "$DEST_DIR/.claude/tasks.md"

    bash ./scripts/scaffold.sh \
        --src . \
        --dest ../.. \
        --non-interactive \
        --project testproject

    [ ! -f "$DEST_DIR/.claude/plan.md" ]
    [ -f "$DEST_DIR/.claude/workflows.md" ]
    [ -f "$DEST_DIR/.claude/tasks.md" ]
}

@test "reads platform name and version from source .envrc" {
    bash ./scripts/scaffold.sh \
        --src . \
        --dest ../.. \
        --non-interactive \
        --project testproject

    # Should use values from source .envrc
    run grep "NV_PLATFORM=" "$DEST_DIR/.envrc"
    [[ "$output" == *"$PROJECT"* ]]

    run grep "NV_PLATFORM_VERSION=" "$DEST_DIR/.envrc"
    [[ "$output" == *"$VERSION"* ]]
}

@test "removes platform-install.sh from destination" {
    bash ./scripts/scaffold.sh \
        --src . \
        --dest ../.. \
        --non-interactive \
        --project testproject

    [ ! -f "$DEST_DIR/scripts/platform-install.sh" ]
}

@test "removes test/ directory from destination" {
    bash ./scripts/scaffold.sh \
        --src . \
        --dest ../.. \
        --non-interactive \
        --project testproject

    [ ! -d "$DEST_DIR/test" ]
}

@test "removes platform development section from justfile" {
    bash ./scripts/scaffold.sh \
        --src . \
        --dest ../.. \
        --non-interactive \
        --project testproject

    run grep "# PLATFORM DEVELOPMENT" "$DEST_DIR/justfile"
    [ "$status" -eq 1 ]
}

@test "removes CHANGELOG.md from destination" {
    bash ./scripts/scaffold.sh \
        --src . \
        --dest ../.. \
        --non-interactive \
        --project testproject

    [ ! -f "$DEST_DIR/CHANGELOG.md" ]
}

@test "removes RELEASE_NOTES.md from destination" {
    bash ./scripts/scaffold.sh \
        --src . \
        --dest ../.. \
        --non-interactive \
        --project testproject

    [ ! -f "$DEST_DIR/RELEASE_NOTES.md" ]
}

@test "replaces README.md with template" {
    bash ./scripts/scaffold.sh \
        --src . \
        --dest ../.. \
        --non-interactive \
        --project myproject

    # README should exist
    [ -f "$DEST_DIR/README.md" ]

    # Should contain project name
    run grep "# myproject" "$DEST_DIR/README.md"
    [ "$status" -eq 0 ]

    # Should contain platform name
    run grep "$PROJECT" "$DEST_DIR/README.md"
    [ "$status" -eq 0 ]

    # Should contain platform version
    run grep "v$VERSION" "$DEST_DIR/README.md"
    [ "$status" -eq 0 ]

    # Should not contain template placeholders
    run grep "{{PROJECT_NAME}}" "$DEST_DIR/README.md"
    [ "$status" -eq 1 ]
}

@test "shows success message on completion" {
    run bash ./scripts/scaffold.sh \
        --src . \
        --dest ../.. \
        --non-interactive \
        --project myproject

    [ "$status" -eq 0 ]
    [[ "$output" == *"Scaffolding complete"* ]]
    [[ "$output" == *"Project: myproject"* ]]
}

@test "uses destination directory name as default project name" {
    # Create a properly named destination directory
    NEW_DEST="$ORIGINAL_DIR/.nv/my-awesome-project"
    mkdir -p "$NEW_DEST"

    # Copy platform files to the new destination
    rsync -a \
        --exclude='.git' \
        --exclude='.nv' \
        . "$NEW_DEST/"

    run bash ./scripts/scaffold.sh \
        --src . \
        --dest "$NEW_DEST" \
        --non-interactive

    [ "$status" -eq 0 ]
    [[ "$output" == *"project=my-awesome-project"* ]]

    cd "$ORIGINAL_DIR"
    rm -rf "$NEW_DEST"
}

@test "restores original directory on failure" {
    # Destination starts empty (only .nv directory from setup)
    INITIAL_FILE_COUNT=$(find "$DEST_DIR" -mindepth 1 -maxdepth 1 ! -name '.nv' | wc -l)
    [ "$INITIAL_FILE_COUNT" -eq 0 ]

    # Make README.template.md unreadable to cause failure during template substitution
    chmod 000 "$SRC_DIR/README.template.md"

    # Try to run scaffold (should fail during README template substitution)
    run bash ./scripts/scaffold.sh \
        --src . \
        --dest ../.. \
        --non-interactive \
        --project testproject

    # Restore permissions
    chmod 644 "$SRC_DIR/README.template.md"

    # Should have failed
    [ "$status" -ne 0 ]
    [[ "$output" == *"Restoring original directory"* ]]

    # Should be restored to empty (only .nv directory should exist)
    FILE_COUNT=$(find "$DEST_DIR" -mindepth 1 -maxdepth 1 ! -name '.nv' | wc -l)
    [ "$FILE_COUNT" -eq 0 ]
}

@test "removes backup directory on success" {
    bash ./scripts/scaffold.sh \
        --src . \
        --dest ../.. \
        --non-interactive \
        --project testproject

    # Backup directory should not exist after successful scaffold
    [ ! -d "$DEST_DIR/.nv/.scaffold-backup" ]
}
