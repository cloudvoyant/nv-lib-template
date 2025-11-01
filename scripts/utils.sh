#!/usr/bin/env bash
# Utility functions and variables for scripts

# DETECT PROJECT ROOT ----------------------------------------------------------
# Find project root by searching for .envrc with PROJECT variable
detect_project_root() {
    # Try git first
    if git rev-parse --show-toplevel &>/dev/null; then
        local git_root="$(git rev-parse --show-toplevel)"
        if [ -f "$git_root/.envrc" ]; then
            echo "$git_root"
            return 0
        fi
    fi

    # Fallback: search for .envrc with PROJECT variable
    local current_dir="$PWD"
    while [ "$current_dir" != "/" ]; do
        if [ -f "$current_dir/.envrc" ]; then
            # Verify it's the right .envrc by checking for PROJECT variable
            if grep -q "^export PROJECT=" "$current_dir/.envrc" 2>/dev/null; then
                echo "$current_dir"
                return 0
            fi
        fi
        current_dir="$(dirname "$current_dir")"
    done

    # If we get here, we couldn't find .envrc
    # This is acceptable in some contexts (e.g., Docker build, CI)
    # Only error if caller explicitly needs it
    return 1
}

# Set PROJECT_ROOT (optional - may be empty if not in a project directory)
# This allows scripts to run in contexts like Docker builds where .envrc doesn't exist
PROJECT_ROOT="$(detect_project_root 2>/dev/null || echo "")"

# COLORS -----------------------------------------------------------------------

DANGER='\033[0;31m'  # Red
SUCCESS='\033[0;32m' # Green
WARN='\033[1;33m'    # Yellow
INFO='\033[0;34m'    # Blue
DEBUG='\033[1;37m'   # White
NC='\033[0m'         # No Color

# ERROR HANDLING ---------------------------------------------------------------
# set -euo pipefail

# UTILITY FUNCTIONS ------------------------------------------------------------

# Spinner for long-running operations
spinner() {
    local pid=$1
    local message="${2:-Working...}"
    local spin='-\|/'
    local i=0

    while kill -0 $pid 2>/dev/null; do
        i=$(( (i+1) %4 ))
        printf "\r${INFO}%s${NC} %s" "${spin:$i:1}" "$message"
        sleep 0.1
    done
    printf "\r%s\r" "$(printf ' %.0s' {1..100})"
}

# Progress indicator for steps
progress_step() {
    local current=$1
    local total=$2
    local message=$3

    printf "${INFO}[%d/%d]${NC} %s\n" "$current" "$total" "$message"
}

# Log function with color support
log() {
    local level=$1
    local message=$2

    case $level in
    "DANGER" | "ERROR")
        printf "${DANGER}${message}${NC}\n" >&2
        ;;
    "SUCCESS")
        printf "${SUCCESS}${message}${NC}\n"
        ;;
    "WARN" | "WARNING")
        printf "${WARN}${message}${NC}\n"
        ;;
    "INFO")
        printf "${INFO}${message}${NC}\n"
        ;;
    "DEBUG")
        printf "${DEBUG}${message}${NC}\n"
        ;;
    *)
        printf "${message}\n"
        ;;
    esac
}

# Logging shortcut functions
log_error() {
    log "ERROR" "$1"
}

log_success() {
    log "SUCCESS" "$1"
}

log_warn() {
    log "WARN" "$1"
}

log_info() {
    log "INFO" "$1"
}

log_debug() {
    log "DEBUG" "$1"
}

# Check if command exists
command_exists() {
    command -v "$1" &>/dev/null
}

# Cross-platform sed in-place editing
# Usage: sed_inplace 's/old/new/' file
sed_inplace() {
    local expression=$1
    local file=$2

    # Use .bak extension for cross-platform compatibility (works on both macOS and Linux)
    sed -i.bak "$expression" "$file" && rm -f "${file}.bak"
}

# Prompt user for confirmation
confirm() {
    local prompt="${1:-Are you sure?}"
    local response

    read -r -p "$prompt [y/N] " response
    case "$response" in
        [yY][eE][sS]|[yY])
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Get git repository name from remote origin URL
get_git_repo_name() {
    local repo_url
    repo_url=$(git remote get-url origin 2>/dev/null)

    if [ $? -ne 0 ] || [ -z "$repo_url" ]; then
        echo ""
        return 1
    fi

    # Extract substring after last forward slash and before .git
    echo "$repo_url" | sed 's|.*/||' | sed 's|\.git.*||'
}

# Get current version from version.txt
get_version() {
    local version=""
    local version_file="${PROJECT_ROOT}/version.txt"

    # Read from version.txt if it exists
    if [ -f "$version_file" ]; then
        version=$(cat "$version_file" | tr -d '[:space:]')
        if [[ -n "$version" ]]; then
            echo "$version"
            return 0
        fi
    fi

    # Fallback: try git tags
    if command -v git &>/dev/null; then
        git fetch --tags 2>/dev/null || true
        version=$(git tag -l --sort=-v:refname | head -n1 | sed 's/^v//')
        if [[ -n "$version" ]]; then
            echo "$version"
            return 0
        fi
    fi

    # Default if nothing found
    echo "0.1.0"
    return 0
}

# Get next version from semantic-release (dry-run)
get_next_version() {
    if ! command -v npx &>/dev/null; then
        log_error "npx not found. Install Node.js to use semantic-release."
        return 1
    fi

    local next_version
    next_version=$(npx --yes semantic-release --dry-run 2>/dev/null | grep "The next release version is" | awk '{print $NF}')

    if [[ -z "$next_version" ]]; then
        log_warn "Could not determine next version from semantic-release"
        echo "TIP: Ensure you have commits following conventional commit format (feat:, fix:, etc.)" >&2
        return 1
    fi

    echo "$next_version"
    return 0
}
