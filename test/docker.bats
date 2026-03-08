#!/usr/bin/env bats
# test/docker.bats
# Verifies docker task contract across all templates.

load 'helpers/contract'

TEMPLATE_SRC="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"

setup() {
    DEST="$(mktemp -d)"
}

teardown() {
    rm -rf "$DEST"
}

run_scaffold() {
    local template="${1:-}"
    local args=(--src "$TEMPLATE_SRC" --dest "$DEST" --project "my-lib" --non-interactive)
    [[ -n "$template" ]] && args+=(--template "$template")
    bash "$TEMPLATE_SRC/.mise-tasks/scaffold" "${args[@]}"
}

# ── Base repo Docker contract ─────────────────────────────────────────────────

@test "base repo has Dockerfile" {
    [ -f "$TEMPLATE_SRC/Dockerfile" ]
}

@test "base repo docker tasks defined in mise.toml" {
    assert_docker_tasks "$TEMPLATE_SRC"
}

@test "base repo: contract tasks are runnable" {
    assert_tasks_runnable "$TEMPLATE_SRC"
}

# ── Docker contract preserved after scaffold ──────────────────────────────────

@test "agnostic scaffold preserves docker task contract" {
    run_scaffold ""
    assert_docker_tasks "$DEST"
}

@test "agnostic scaffold: contract tasks are runnable" {
    run_scaffold ""
    assert_tasks_runnable "$DEST"
}

@test "uv scaffold preserves docker task contract" {
    run_scaffold "uv"
    assert_docker_tasks "$DEST"
}

@test "uv scaffold: contract tasks are runnable" {
    run_scaffold "uv"
    assert_tasks_runnable "$DEST"
}

@test "zig scaffold preserves docker task contract" {
    run_scaffold "zig"
    assert_docker_tasks "$DEST"
}

@test "zig scaffold: contract tasks are runnable" {
    run_scaffold "zig"
    assert_tasks_runnable "$DEST"
}

# ── docker-build task has a run command ───────────────────────────────────────

@test "agnostic: docker-build task has a run command" {
    run_scaffold ""
    grep -A2 '^\[tasks\.docker-build\]' "$DEST/mise.toml" | grep -q 'run'
}

@test "uv: docker-build task has a run command" {
    run_scaffold "uv"
    grep -A2 '^\[tasks\.docker-build\]' "$DEST/mise.toml" | grep -q 'run'
}

@test "zig: docker-build task has a run command" {
    run_scaffold "zig"
    grep -A2 '^\[tasks\.docker-build\]' "$DEST/mise.toml" | grep -q 'run'
}

# ── Dockerfile ships with scaffold and uses unified mise pattern ──────────────

@test "agnostic scaffold includes Dockerfile" {
    run_scaffold ""
    [ -f "$DEST/Dockerfile" ]
    grep -q 'mise run build' "$DEST/Dockerfile"
    grep -q 'mise.*run.*run' "$DEST/Dockerfile"
}

@test "uv scaffold includes Dockerfile" {
    run_scaffold "uv"
    [ -f "$DEST/Dockerfile" ]
    grep -q 'mise run build' "$DEST/Dockerfile"
    grep -q 'mise.*run.*run' "$DEST/Dockerfile"
}

@test "zig scaffold includes Dockerfile" {
    run_scaffold "zig"
    [ -f "$DEST/Dockerfile" ]
    grep -q 'mise run build' "$DEST/Dockerfile"
    grep -q 'mise.*run.*run' "$DEST/Dockerfile"
}
