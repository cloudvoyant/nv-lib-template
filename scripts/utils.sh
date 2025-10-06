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

    echo "ERROR: Could not find project root (.envrc with PROJECT variable not found)" >&2
    echo "TIP: Run 'just setup' to initialize the project or ensure you're in the project directory" >&2
    return 1
}

# Set PROJECT_ROOT
PROJECT_ROOT="$(detect_project_root)"

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
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    case $level in
    "DANGER" | "ERROR")
        printf "[${timestamp}]: ${DANGER}${message}${NC}\n" >&2
        ;;
    "SUCCESS")
        printf "[${timestamp}]: ${SUCCESS}${message}${NC}\n"
        ;;
    "WARN" | "WARNING")
        printf "[${timestamp}]: ${WARN}${message}${NC}\n"
        ;;
    "INFO")
        printf "[${timestamp}]: ${INFO}${message}${NC}\n"
        ;;
    "DEBUG")
        printf "[${timestamp}]: ${DEBUG}${message}${NC}\n"
        ;;
    *)
        printf "[${timestamp}] ${message}\n"
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

# Find repository root by looking for .git directory
find_repo_root() {
    local current_dir="$PWD"

    while [ "$current_dir" != "/" ]; do
        if [ -d "$current_dir/.git" ] || [ -f "$current_dir/.git" ]; then
            echo "$current_dir"
            return 0
        fi
        current_dir="$(dirname "$current_dir")"
    done

    log_error "Not in a git repository"
    echo "TIP: Initialize a git repository with 'git init' or ensure you're in the project directory" >&2
    return 1
}

# Change to repository root
goto_repo_root() {
    local repo_root
    repo_root=$(find_repo_root)

    if [ $? -ne 0 ]; then
        return 1
    fi

    cd "$repo_root" || {
        log_error "Failed to change to repository root: $repo_root (permission denied or directory missing)"
        return 1
    }

    return 0
}

# Check if running from repository root (for backwards compatibility)
check_repo_root() {
    if [ ! -d ".git" ] && [ ! -f ".git" ]; then
        log_error "Must run from repository root"
        echo "TIP: Run 'cd \$(git rev-parse --show-toplevel)' to navigate to the repository root" >&2
        return 1
    fi
    return 0
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

# Require command exists with optional version check
require_command() {
    local cmd=$1
    local min_version=${2:-}

    if ! command_exists "$cmd"; then
        log_error "$cmd is not installed"
        echo "TIP: Install $cmd or run 'just setup' to install all dependencies" >&2
        return 1
    fi

    # TODO: Add version comparison if min_version is provided
    return 0
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

# Retry a command with exponential backoff
retry() {
    local max_attempts=${1:-3}
    local delay=${2:-2}
    local attempt=1
    shift 2
    local cmd="$@"

    while [ $attempt -le $max_attempts ]; do
        if eval "$cmd"; then
            return 0
        fi

        if [ $attempt -lt $max_attempts ]; then
            log_warn "Command failed (attempt $attempt/$max_attempts). Retrying in ${delay}s..."
            sleep $delay
            delay=$((delay * 2))
        fi

        attempt=$((attempt + 1))
    done

    log_error "Command failed after $max_attempts attempts"
    return 1
}

# Create lock file to prevent concurrent runs
create_lock_file() {
    local lock_file="${1:-.script.lock}"

    if [ -f "$lock_file" ]; then
        log_error "Script is already running (lock file exists: $lock_file)"
        echo "TIP: If the script is not actually running, remove the stale lock file with 'rm $lock_file'" >&2
        return 1
    fi

    echo $$ > "$lock_file"
    return 0
}

# Release lock file
release_lock_file() {
    local lock_file="${1:-.script.lock}"
    rm -f "$lock_file"
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

# Get current version using semantic-release
get_version() {
    local version=""

    # Get latest git tag
    if command -v git &>/dev/null; then
        # Fetch tags from remote first
        git fetch --tags 2>/dev/null || true

        # Get latest tag sorted by version
        version=$(git tag -l --sort=-v:refname | head -n1 | sed 's/^v//')
        if [[ -n "$version" ]]; then
            echo "$version"
            return 0
        fi
    fi

    # Default if nothing found
    echo "0.0.1"
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

# TRAP HANDLERS ----------------------------------------------------------------

# Default error handler - scripts can override with their own trap
default_error_handler() {
    local line_num=$1
    log_error "Script failed at line $line_num"
    exit 1
}

# SCRIPT LIFECYCLE SETUP -------------------------------------------------------

# Initialize script lifecycle (error handling, traps, etc.)
# Call this at the start of every script after sourcing utils.sh
# Options:
#   --lock <file>    Create and manage a lock file for this script
setup_script_lifecycle() {
    local lock_file=""

    while [[ $# -gt 0 ]]; do
        case $1 in
            --lock)
                lock_file="$2"
                shift 2
                ;;
            *)
                shift
                ;;
        esac
    done

    set -euo pipefail
    trap 'log_error "Script failed at line $LINENO"; exit 1' ERR

    # Set up lock file if requested
    if [[ -n "$lock_file" ]]; then
        if ! create_lock_file "$lock_file"; then
            log_error "Failed to acquire lock file: $lock_file"
            exit 1
        fi
        trap "release_lock_file '$lock_file'" EXIT
    else
        trap 'release_lock_file' EXIT
    fi
}
