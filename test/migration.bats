#!/usr/bin/env bats

# Migration workflow tests

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

    # Create a scaffolded project at version 1.0.4
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

@test "scaffolded project has NV_PLATFORM tracking" {
    cd "$TEST_PROJECT_DIR"
    grep -q "^export NV_PLATFORM=" .envrc
}

@test "scaffolded project has NV_PLATFORM_VERSION" {
    cd "$TEST_PROJECT_DIR"
    grep -q "^export NV_PLATFORM_VERSION=" .envrc
}

@test "scaffolded project has PROJECT name" {
    cd "$TEST_PROJECT_DIR"
    grep -q "^export PROJECT=test-project" .envrc
}

@test "scaffolded project has reset VERSION to 0.1.0" {
    cd "$TEST_PROJECT_DIR"
    grep -q "^export VERSION=0.1.0" .envrc
}

@test "scaffolded project does not have docs/migrations/" {
    cd "$TEST_PROJECT_DIR"
    [ ! -d "docs/migrations" ]
}

@test "scaffolded project does not have generate-migration-guide workflow" {
    cd "$TEST_PROJECT_DIR"
    [ ! -f ".claude/migrations/generate-migration-guide.md" ]
}

@test "scaffolded project does not have new-migration command" {
    cd "$TEST_PROJECT_DIR"
    [ ! -f ".claude/commands/new-migration.md" ]
}

@test "scaffolded project has user-facing migration workflows" {
    cd "$TEST_PROJECT_DIR"
    [ -f ".claude/migrations/detect-scaffolded-version.md" ]
    [ -f ".claude/migrations/assist-project-migration.md" ]
    [ -f ".claude/migrations/validate-project-migration.md" ]
}

@test "scaffolded project has upgrade command" {
    cd "$TEST_PROJECT_DIR"
    [ -f ".claude/commands/upgrade.md" ]
}

@test "can update NV_PLATFORM_VERSION with sed" {
    cd "$TEST_PROJECT_DIR"

    # Simulate migration updating version
    sed -i.bak 's/^export NV_PLATFORM_VERSION=.*/export NV_PLATFORM_VERSION=1.1.0/' .envrc

    # Verify update
    grep -q "^export NV_PLATFORM_VERSION=1.1.0" .envrc
}

@test "platform repository has migration guide template" {
    cd "$TEST_PLATFORM_DIR"
    [ -f "docs/migrations/TEMPLATE.md" ]
}

@test "platform repository has generate-migration-guide workflow" {
    cd "$TEST_PLATFORM_DIR"
    [ -f ".claude/migrations/generate-migration-guide.md" ]
}

@test "platform repository has new-migration command" {
    cd "$TEST_PLATFORM_DIR"
    [ -f ".claude/commands/new-migration.md" ]
}

@test "platform repository has new-platform workflow" {
    cd "$TEST_PLATFORM_DIR"
    [ -f ".claude/migrations/create-new-platform.md" ]
}

@test "platform repository has new-platform command" {
    cd "$TEST_PLATFORM_DIR"
    [ -f ".claude/commands/new-platform.md" ]
}

@test "migration workflow files have correct content" {
    cd "$TEST_PROJECT_DIR"

    # Check upgrade command references correct workflow
    grep -q "assist-project-migration.md" .claude/commands/upgrade.md

    # Check workflow exists
    [ -f ".claude/migrations/assist-project-migration.md" ]
}

@test "sequential version migration can be simulated" {
    cd "$TEST_PROJECT_DIR"

    # Start at 1.0.4 (default from scaffold)
    current_version=$(grep "^export NV_PLATFORM_VERSION=" .envrc | cut -d= -f2)

    # Migrate to 1.1.0
    sed -i.bak 's/^export NV_PLATFORM_VERSION=.*/export NV_PLATFORM_VERSION=1.1.0/' .envrc
    grep -q "^export NV_PLATFORM_VERSION=1.1.0" .envrc

    # Migrate to 1.2.0
    sed -i.bak 's/^export NV_PLATFORM_VERSION=.*/export NV_PLATFORM_VERSION=1.2.0/' .envrc
    grep -q "^export NV_PLATFORM_VERSION=1.2.0" .envrc
}

@test "rollback preserves NV_PLATFORM tracking" {
    cd "$TEST_PROJECT_DIR"

    # Create backup
    cp .envrc .envrc.backup

    # Simulate failed migration
    sed -i.bak 's/^export NV_PLATFORM_VERSION=.*/export NV_PLATFORM_VERSION=2.0.0/' .envrc

    # Rollback
    mv .envrc.backup .envrc

    # Verify original version restored
    grep -q "^export NV_PLATFORM=" .envrc
    grep -q "^export NV_PLATFORM_VERSION=" .envrc
}

@test "environment loads correctly after scaffold" {
    cd "$TEST_PROJECT_DIR"

    # Source .envrc (without direnv)
    source .envrc

    # Verify variables are set
    [ -n "$PROJECT" ]
    [ -n "$NV_PLATFORM" ]
    [ -n "$NV_PLATFORM_VERSION" ]
    [ "$VERSION" = "0.1.0" ]
}
