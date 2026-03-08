# test/helpers/contract.bash
# Load in bats files with: load 'helpers/contract'

# All templates must implement these tasks (either in mise.toml or .mise-tasks/)
CONTRACT_TASKS=(
    "build"
    "test"
    "lint"
    "lint-fix"
    "format"
    "format-check"
    "publish"
    "docker-build"
    "docker-run"
    "docker-test"
    "upversion"
    "version"
    "version-next"
)

# Tasks safe to actually execute in a scaffolded project (no external deps, no side effects).
# format-check depends on install in the uv template, so uv sync runs automatically.
RUNNABLE_TASKS=(
    "version"
    "format-check"
)

# Check that a task is declared in the given project directory.
# Checks [tasks.name] in mise.toml and .mise-tasks/<name> scripts.
_task_exists() {
    local project_dir="$1"
    local task="$2"
    grep -q "^\[tasks\.\"${task}\"\]\|^\[tasks\.${task}\]" "$project_dir/mise.toml" 2>/dev/null && return 0
    [[ -f "$project_dir/.mise-tasks/$task" ]] && return 0
    return 1
}

# Usage: assert_contract_tasks "$scaffolded_project_dir"
# Verifies all 13 contract tasks are declared in mise.toml or .mise-tasks/.
assert_contract_tasks() {
    local project_dir="$1"
    local missing=()

    [[ -f "$project_dir/mise.toml" ]] || { echo "FAIL: mise.toml not found in $project_dir" >&2; return 1; }

    for task in "${CONTRACT_TASKS[@]}"; do
        _task_exists "$project_dir" "$task" || missing+=("$task")
    done

    if [[ ${#missing[@]} -gt 0 ]]; then
        echo "FAIL: Missing contract tasks in $project_dir: ${missing[*]}" >&2
        return 1
    fi
    return 0
}

# Usage: assert_docker_tasks "$scaffolded_project_dir"
# Verifies docker-build, docker-run, docker-test are declared.
assert_docker_tasks() {
    local project_dir="$1"
    local docker_tasks=("docker-build" "docker-run" "docker-test")
    local missing=()

    for task in "${docker_tasks[@]}"; do
        _task_exists "$project_dir" "$task" || missing+=("$task")
    done

    if [[ ${#missing[@]} -gt 0 ]]; then
        echo "FAIL: Missing docker contract tasks: ${missing[*]}" >&2
        return 1
    fi
    return 0
}

# Usage: assert_tasks_runnable "$scaffolded_project_dir"
# Actually executes a safe subset of tasks (version, format-check) to confirm they run
# without errors. Trusts the project dir first so mise can read its config.
assert_tasks_runnable() {
    local project_dir="$1"
    local failed=()

    mise trust --yes "$project_dir" >/dev/null 2>&1

    for task in "${RUNNABLE_TASKS[@]}"; do
        if ! _task_exists "$project_dir" "$task"; then
            continue  # skip if not declared (already caught by assert_contract_tasks)
        fi
        if ! mise run --cd "$project_dir" "$task" >/dev/null 2>&1; then
            failed+=("$task")
        fi
    done

    if [[ ${#failed[@]} -gt 0 ]]; then
        echo "FAIL: Tasks failed to run in $project_dir: ${failed[*]}" >&2
        return 1
    fi
    return 0
}
