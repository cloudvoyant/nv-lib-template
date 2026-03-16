#!/usr/bin/env bats
# test/scaffold-templates.bats
# Parameterized tests for --template [uv|zig] and agnostic (no template).
# Run with: bats test/scaffold-templates.bats

load 'helpers/contract'

TEMPLATE_SRC="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"

setup() {
    DEST="$(mktemp -d)"
}

teardown() {
    rm -rf "$DEST"
}

# Helper: run scaffold for a given template (or agnostic if empty)
run_scaffold() {
    local template="${1:-}"
    local project="${2:-my-lib}"
    local args=(
        --src "$TEMPLATE_SRC"
        --dest "$DEST"
        --project "$project"
        --non-interactive
    )
    [[ -n "$template" ]] && args+=(--template "$template")
    bash "$TEMPLATE_SRC/.mise-tasks/scaffold" "${args[@]}"
}

# ── Agnostic (no template) ────────────────────────────────────────────────────

@test "agnostic: scaffold succeeds" {
    run run_scaffold ""
    [ "$status" -eq 0 ]
}

@test "agnostic: honors base task contract" {
    # The agnostic base provides the infrastructure tasks; language tasks (lint, format, etc.)
    # are intentionally left as stubs for the user to fill in. Test only guaranteed tasks.
    run_scaffold ""
    local base_tasks=("build" "test" "docker-build" "docker-run" "docker-test" "upversion" "version" "version-next")
    for task in "${base_tasks[@]}"; do
        _task_exists "$DEST" "$task" || { echo "FAIL: base task '$task' missing"; false; }
    done
}

@test "agnostic: contract tasks are runnable" {
    run_scaffold ""
    assert_tasks_runnable "$DEST"
}

@test "agnostic: TEMPLATE is mise-lib-template" {
    run_scaffold ""
    grep -q 'TEMPLATE.*"mise-lib-template"' "$DEST/mise.toml"
}

@test "agnostic: src/sample-code.txt retained" {
    run_scaffold ""
    [ -f "$DEST/src/sample-code.txt" ]
}

@test "agnostic: no pyproject.toml created" {
    run_scaffold ""
    [ ! -f "$DEST/pyproject.toml" ]
}

@test "agnostic: no build.zig created" {
    run_scaffold ""
    [ ! -f "$DEST/build.zig" ]
}

# ── uv template ───────────────────────────────────────────────────────────────

@test "uv: scaffold succeeds" {
    run run_scaffold "uv"
    [ "$status" -eq 0 ]
}

@test "uv: honors full task contract" {
    run_scaffold "uv"
    assert_contract_tasks "$DEST"
}

@test "uv: contract tasks are runnable" {
    run_scaffold "uv"
    assert_tasks_runnable "$DEST"
}

@test "uv: docker tasks present" {
    run_scaffold "uv"
    assert_docker_tasks "$DEST"
}

@test "uv: pyproject.toml created with project name" {
    run_scaffold "uv" "my-lib"
    [ -f "$DEST/pyproject.toml" ]
    grep -q 'name = "my-lib"' "$DEST/pyproject.toml"
}

@test "uv: Python package directory created with project snake_case name" {
    run_scaffold "uv" "my-lib"
    [ -d "$DEST/src/my_lib" ]
    [ -f "$DEST/src/my_lib/__init__.py" ]
    [ -f "$DEST/src/my_lib/sample.py" ]
}

@test "uv: tests/ directory created" {
    run_scaffold "uv"
    [ -d "$DEST/tests" ]
    [ -f "$DEST/tests/test_sample.py" ]
}

@test "uv: TEMPLATE is mise-uv-template" {
    run_scaffold "uv"
    grep -q 'TEMPLATE.*"mise-uv-template"' "$DEST/mise.toml"
}

@test "uv: CLAUDE.md contains uv/ruff conventions" {
    run_scaffold "uv"
    grep -q "uv run" "$DEST/CLAUDE.md"
    grep -q "ruff" "$DEST/CLAUDE.md"
}

@test "uv: sample-code.txt removed" {
    run_scaffold "uv"
    [ ! -f "$DEST/src/sample-code.txt" ]
}

@test "uv: .mise-tasks/ scripts are executable" {
    run_scaffold "uv"
    [ -x "$DEST/.mise-tasks/publish-rc" ]
}

@test "uv: no build.zig created" {
    run_scaffold "uv"
    [ ! -f "$DEST/build.zig" ]
}

@test "uv: project name replaced in pyproject.toml script entry" {
    run_scaffold "uv" "cool-tool"
    grep -q 'cool-tool' "$DEST/pyproject.toml"
    grep -q 'cool_tool' "$DEST/pyproject.toml"
}

# ── zig template ──────────────────────────────────────────────────────────────

@test "zig: scaffold succeeds" {
    run run_scaffold "zig"
    [ "$status" -eq 0 ]
}

@test "zig: honors full task contract" {
    run_scaffold "zig"
    assert_contract_tasks "$DEST"
}

@test "zig: contract tasks are runnable" {
    run_scaffold "zig"
    assert_tasks_runnable "$DEST"
}

@test "zig: docker tasks present" {
    run_scaffold "zig"
    assert_docker_tasks "$DEST"
}

@test "zig: build.zig created" {
    run_scaffold "zig"
    [ -f "$DEST/build.zig" ]
}

@test "zig: build.zig.zon created with project name" {
    run_scaffold "zig" "my-lib"
    [ -f "$DEST/build.zig.zon" ]
    grep -q '.my_lib' "$DEST/build.zig.zon"
}

@test "zig: src/lib.zig and src/main.zig created" {
    run_scaffold "zig"
    [ -f "$DEST/src/lib.zig" ]
    [ -f "$DEST/src/main.zig" ]
}

@test "zig: TEMPLATE is mise-zig-template" {
    run_scaffold "zig"
    grep -q 'TEMPLATE.*"mise-zig-template"' "$DEST/mise.toml"
}

@test "zig: CLAUDE.md contains Zig conventions" {
    run_scaffold "zig"
    grep -q "zig build" "$DEST/CLAUDE.md"
    grep -q "zig fmt" "$DEST/CLAUDE.md"
}

@test "zig: sample-code.txt removed" {
    run_scaffold "zig"
    [ ! -f "$DEST/src/sample-code.txt" ]
}

@test "zig: .mise-tasks/ scripts are executable" {
    run_scaffold "zig"
    [ -x "$DEST/.mise-tasks/publish" ]
    [ -x "$DEST/.mise-tasks/build-all-platforms" ]
}

@test "zig: no pyproject.toml created" {
    run_scaffold "zig"
    [ ! -f "$DEST/pyproject.toml" ]
}

@test "zig: project name replaced in src/lib.zig" {
    run_scaffold "zig" "my-lib"
    grep -q 'my_lib' "$DEST/src/lib.zig"
}

# ── pnpm template ─────────────────────────────────────────────────────────────

@test "pnpm: scaffold succeeds" {
    run run_scaffold "pnpm"
    [ "$status" -eq 0 ]
}

@test "pnpm: honors full task contract" {
    run_scaffold "pnpm"
    assert_contract_tasks "$DEST"
}

@test "pnpm: contract tasks are runnable" {
    run_scaffold "pnpm"
    assert_tasks_runnable "$DEST"
}

@test "pnpm: docker tasks present" {
    run_scaffold "pnpm"
    assert_docker_tasks "$DEST"
}

@test "pnpm: package.json created with project name" {
    run_scaffold "pnpm" "my-lib"
    [ -f "$DEST/package.json" ]
    grep -q '"name": "my-lib"' "$DEST/package.json"
}

@test "pnpm: src/index.ts and src/lib.ts created" {
    run_scaffold "pnpm"
    [ -f "$DEST/src/index.ts" ]
    [ -f "$DEST/src/lib.ts" ]
}

@test "pnpm: tests/lib.test.ts created" {
    run_scaffold "pnpm"
    [ -f "$DEST/tests/lib.test.ts" ]
}

@test "pnpm: TEMPLATE is mise-pnpm-template" {
    run_scaffold "pnpm"
    grep -q 'TEMPLATE.*"mise-pnpm-template"' "$DEST/mise.toml"
}

@test "pnpm: CLAUDE.md contains pnpm conventions" {
    run_scaffold "pnpm"
    grep -q "pnpm" "$DEST/CLAUDE.md"
}

@test "pnpm: sample-code.txt removed" {
    run_scaffold "pnpm"
    [ ! -f "$DEST/src/sample-code.txt" ]
}

@test "pnpm: no pyproject.toml created" {
    run_scaffold "pnpm"
    [ ! -f "$DEST/pyproject.toml" ]
}

@test "pnpm: no build.zig created" {
    run_scaffold "pnpm"
    [ ! -f "$DEST/build.zig" ]
}

@test "pnpm: .mise-tasks/publish-rc is executable" {
    run_scaffold "pnpm"
    [ -x "$DEST/.mise-tasks/publish-rc" ]
}

@test "pnpm: ci.yml has publish-rc job calling publish-rc task" {
    run_scaffold "pnpm"
    grep -q 'mise run publish-rc' "$DEST/.github/workflows/ci.yml"
}

@test "pnpm: ci.yml has no template-only tasks" {
    run_scaffold "pnpm"
    ! grep -q 'publish-templates-rc\|test-template' "$DEST/.github/workflows/ci.yml"
}

@test "pnpm: scaffolded project passes lint (ESLint + tsc)" {
    run_scaffold "pnpm"
    mise trust --yes "$DEST" >/dev/null 2>&1
    mise run --cd "$DEST" lint
}

@test "pnpm: scaffolded project passes format-check" {
    run_scaffold "pnpm"
    mise trust --yes "$DEST" >/dev/null 2>&1
    mise run --cd "$DEST" format-check
}

# ── CI workflow cleanup ───────────────────────────────────────────────────────

@test "agnostic: ci.yml has publish-rc job calling publish-rc task" {
    run_scaffold ""
    grep -q 'mise run publish-rc' "$DEST/.github/workflows/ci.yml"
}

@test "agnostic: ci.yml has no template-only tasks" {
    run_scaffold ""
    ! grep -q 'publish-templates-rc\|test-template' "$DEST/.github/workflows/ci.yml"
}

@test "agnostic: release.yml has no template-only tasks" {
    run_scaffold ""
    ! grep -q 'publish-templates\|test-template' "$DEST/.github/workflows/release.yml"
}

@test "uv: ci.yml has publish-rc job calling publish-rc task" {
    run_scaffold "uv"
    grep -q 'mise run publish-rc' "$DEST/.github/workflows/ci.yml"
}

@test "uv: ci.yml has no template-only tasks" {
    run_scaffold "uv"
    ! grep -q 'publish-templates-rc\|test-template' "$DEST/.github/workflows/ci.yml"
}

@test "zig: ci.yml has publish-rc job calling publish-rc task" {
    run_scaffold "zig"
    grep -q 'mise run publish-rc' "$DEST/.github/workflows/ci.yml"
}

@test "zig: ci.yml has no template-only tasks" {
    run_scaffold "zig"
    ! grep -q 'publish-templates-rc\|test-template' "$DEST/.github/workflows/ci.yml"
}

@test "uv: .mise-tasks/publish-rc is executable" {
    run_scaffold "uv"
    [ -x "$DEST/.mise-tasks/publish-rc" ]
}

@test "zig: .mise-tasks/publish-rc is executable" {
    run_scaffold "zig"
    [ -x "$DEST/.mise-tasks/publish-rc" ]
}

# ── Invalid template ──────────────────────────────────────────────────────────

@test "invalid template name exits with error" {
    run bash "$TEMPLATE_SRC/.mise-tasks/scaffold" \
        --src "$TEMPLATE_SRC" --dest "$DEST" \
        --project "my-lib" --template python --non-interactive
    [ "$status" -ne 0 ]
    echo "$output" | grep -q -i "unknown template\|valid"
}
