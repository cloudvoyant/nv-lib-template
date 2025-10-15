#!/usr/bin/env bash
: <<DOCUMENTATION
Scaffolds a new project from this platform

Called by Nedavellir CLI after copying platform files to destination.
Updates project-specific configuration in the destination directory.

Usage:
  bash scripts/scaffold.sh --src /path/to/template --dest /path/to/project
  bash scripts/scaffold.sh --src /path/to/template --dest /path/to/project --non-interactive
  bash scripts/scaffold.sh --src /path/to/template --dest /path/to/project --project myapp

Options:
  --src PATH           Path to template source directory (required)
  --dest PATH          Path to destination project directory (required)
  --non-interactive    Skip prompts, use defaults
  --project NAME       Project name (default: destination directory name)
  --keep-claude        Keep .claude/ directory for AI workflows
DOCUMENTATION

# IMPORTS ----------------------------------------------------------------------
source "$(dirname "$0")/utils.sh"
set -euo pipefail

# Unset PROJECT and VERSION to force fresh read from .envrc
unset PROJECT VERSION

# Source .envrc to get PROJECT and VERSION
if [ -f ".envrc" ]; then
    source ".envrc"
fi

# CONFIGURATION ----------------------------------------------------------------
# Platform name will be read from source .envrc PROJECT variable

# Track if we've started making changes (for cleanup on error)
SCAFFOLD_STARTED=false
BACKUP_DIR=""

# Cleanup function for failed scaffolds
cleanup_on_error() {
    local exit_code=$?
    if [ "$exit_code" -ne 0 ] && [ "$SCAFFOLD_STARTED" = true ]; then
        log_error "Scaffolding failed. Restoring original directory..."

        if [ -n "$BACKUP_DIR" ] && [ -d "$BACKUP_DIR" ]; then
            # Ensure destination and all contents are writable for cleanup
            chmod u+w "$DEST_DIR" 2>/dev/null || true
            chmod -R u+w "$DEST_DIR" 2>/dev/null || true

            # Remove all files from destination (except .nv backup)
            find "$DEST_DIR" -mindepth 1 -maxdepth 1 ! -name '.nv' -exec rm -rf {} + 2>/dev/null || true

            # Restore entire directory from backup
            rsync -a "$BACKUP_DIR/" "$DEST_DIR/"

            # Remove backup
            rm -rf "$BACKUP_DIR"
        fi

        log_error "Destination directory has been restored to its original state"
    fi
}

trap cleanup_on_error EXIT

# PARSE OPTIONS ----------------------------------------------------------------
NON_INTERACTIVE=false
KEEP_CLAUDE=false
PROJECT_NAME=""
SRC_DIR=""
DEST_DIR=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --src)
            SRC_DIR="$2"
            shift 2
            ;;
        --dest)
            DEST_DIR="$2"
            shift 2
            ;;
        --non-interactive)
            NON_INTERACTIVE=true
            shift
            ;;
        --project)
            PROJECT_NAME="$2"
            shift 2
            ;;
        --keep-claude)
            KEEP_CLAUDE=true
            shift
            ;;
        *)
            log_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

# VALIDATION -------------------------------------------------------------------
if [ -z "$SRC_DIR" ] || [ -z "$DEST_DIR" ]; then
    log_error "Both --src and --dest are required"
    echo "Usage: bash scripts/scaffold.sh --src /path/to/template --dest /path/to/project" >&2
    exit 1
fi

# Convert to absolute paths
SRC_DIR=$(cd "$SRC_DIR" 2>/dev/null && pwd) || {
    log_error "Source directory does not exist: $SRC_DIR"
    exit 1
}

DEST_DIR=$(cd "$DEST_DIR" 2>/dev/null && pwd) || {
    log_error "Destination directory does not exist: $DEST_DIR"
    exit 1
}

validate_project_name() {
    local name=$1
    # Allow alphanumeric, hyphens, underscores
    if [[ ! "$name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        return 1
    fi
    return 0
}

# Convert string to word array (split on _ - or camelCase boundaries)
string_to_words() {
    local input=$1
    # First, insert underscores before capital letters (for camelCase/PascalCase)
    input=$(echo "$input" | sed 's/\([A-Z]\)/_\1/g' | sed 's/^_//')
    # Replace hyphens with underscores
    input=$(echo "$input" | tr '-' '_')
    # Convert to lowercase and split on underscores, output one word per line
    echo "$input" | tr '[:upper:]' '[:lower:]' | tr '_' '\n' | grep -v '^$'
}

# Convert word array to snake_case
words_to_snake() {
    echo "$1" | tr '\n' '_' | sed 's/_$//'
}

# Convert word array to kebab-case
words_to_kebab() {
    echo "$1" | tr '\n' '-' | sed 's/-$//'
}

# Convert word array to PascalCase
words_to_pascal() {
    echo "$1" | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1' | tr -d '\n'
}

# Convert word array to camelCase
words_to_camel() {
    local words="$1"
    local first=$(echo "$words" | head -1)
    local rest=$(echo "$words" | tail -n +2)
    if [ -n "$rest" ]; then
        echo -n "$first"
        echo "$rest" | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1' | tr -d '\n'
    else
        echo -n "$first"
    fi
}

# Convert word array to flatcase (no separators)
words_to_flat() {
    echo "$1" | tr -d '\n'
}

# DEFAULT PROJECT NAME ---------------------------------------------------------
DEFAULT_PROJECT=$(basename "$DEST_DIR")

# INTERACTIVE PROMPTS ----------------------------------------------------------
if [ "$NON_INTERACTIVE" = false ]; then
    log_info "Scaffolding new project from $PLATFORM_NAME platform"
    echo ""

    # Prompt for project name
    while true; do
        read -p "Project name [$DEFAULT_PROJECT]: " input_name
        PROJECT_NAME="${input_name:-$DEFAULT_PROJECT}"

        if validate_project_name "$PROJECT_NAME"; then
            break
        else
            log_error "Invalid project name. Use only letters, numbers, hyphens, and underscores."
        fi
    done

    # Prompt for GCP registry configuration
    read -p "Configure GCP Artifact Registry? (y/N): " configure_gcp
    if [[ "$configure_gcp" =~ ^[Yy]$ ]]; then
        read -p "GCP Project ID: " gcp_project_id
        read -p "GCP Region [us-east1]: " gcp_region
        gcp_region="${gcp_region:-us-east1}"
        read -p "GCP Repository: " gcp_repository
        CONFIGURE_GCP=true
    else
        CONFIGURE_GCP=false
    fi

    # Prompt for .claude/ directory
    read -p "Keep .claude/ directory for AI workflows? (y/N): " keep_claude_input
    if [[ "$keep_claude_input" =~ ^[Yy]$ ]]; then
        KEEP_CLAUDE=true
    fi

    echo ""
else
    # Non-interactive mode: use defaults
    PROJECT_NAME="${PROJECT_NAME:-$DEFAULT_PROJECT}"
    CONFIGURE_GCP=false

    if ! validate_project_name "$PROJECT_NAME"; then
        log_error "Invalid project name: $PROJECT_NAME"
        exit 1
    fi

    log_info "Non-interactive mode: project=$PROJECT_NAME"
fi

# GET PLATFORM NAME AND VERSION -----------------------------------------------
log_info "Detecting platform name and version..."

# Use environment variables from sourced .envrc
PLATFORM_NAME="$PROJECT"
PLATFORM_VERSION="$VERSION"

# Validate we have the required values
if [ -z "$PLATFORM_NAME" ]; then
    log_error "Could not determine platform name (PROJECT not set)"
    exit 1
fi

if [ -z "$PLATFORM_VERSION" ]; then
    log_error "Could not determine platform version (VERSION not set)"
    exit 1
fi

log_info "Platform: $PLATFORM_NAME v$PLATFORM_VERSION"

# BACKUP DESTINATION DIRECTORY ------------------------------------------------
log_info "Creating backup of destination directory..."

BACKUP_DIR="$DEST_DIR/.nv/.scaffold-backup"
mkdir -p "$BACKUP_DIR"

# Backup entire destination directory (excluding .nv to avoid recursion)
rsync -a \
    --exclude='.nv' \
    "$DEST_DIR/" "$BACKUP_DIR/"

# Mark that we've started making changes
SCAFFOLD_STARTED=true

log_success "Backup created"

# COPY PLATFORM FILES TO DESTINATION -------------------------------------------
log_info "Copying platform files to destination..."

# Copy all files from source to destination
# Exclude: .git, .nv, test/, docs/migrations/, docs/decisions/, CHANGELOG.md, RELEASE_NOTES.md
rsync -a \
    --exclude='.git' \
    --exclude='.nv' \
    --exclude='test/' \
    --exclude='docs/migrations/' \
    --exclude='docs/decisions/' \
    --exclude='CHANGELOG.md' \
    --exclude='RELEASE_NOTES.md' \
    "$SRC_DIR/" "$DEST_DIR/"

log_success "Platform files copied"

# REPLACE PLATFORM NAME WITH PROJECT NAME IN ALL VARIANTS ---------------------
log_info "Replacing platform name with project name..."

# Generate all variants of platform name and project name
PLATFORM_WORDS=$(string_to_words "$PLATFORM_NAME")
PROJECT_WORDS=$(string_to_words "$PROJECT_NAME")

# Platform name variants
PLATFORM_SNAKE=$(words_to_snake "$PLATFORM_WORDS")
PLATFORM_KEBAB=$(words_to_kebab "$PLATFORM_WORDS")
PLATFORM_PASCAL=$(words_to_pascal "$PLATFORM_WORDS")
PLATFORM_CAMEL=$(words_to_camel "$PLATFORM_WORDS")
PLATFORM_FLAT=$(words_to_flat "$PLATFORM_WORDS")

# Project name variants
PROJECT_SNAKE=$(words_to_snake "$PROJECT_WORDS")
PROJECT_KEBAB=$(words_to_kebab "$PROJECT_WORDS")
PROJECT_PASCAL=$(words_to_pascal "$PROJECT_WORDS")
PROJECT_CAMEL=$(words_to_camel "$PROJECT_WORDS")
PROJECT_FLAT=$(words_to_flat "$PROJECT_WORDS")

# Replace in all text files (excluding binary files and .git)
find "$DEST_DIR" -type f ! -path "*/.git/*" ! -path "$DEST_DIR/.nv/*" 2>/dev/null | while IFS= read -r file; do
    # Replace all variants (order matters: longer strings first to avoid partial replacements)
    sed_inplace "s/${PLATFORM_PASCAL}/${PROJECT_PASCAL}/g" "$file" || true
    sed_inplace "s/${PLATFORM_CAMEL}/${PROJECT_CAMEL}/g" "$file" || true
    sed_inplace "s/${PLATFORM_SNAKE}/${PROJECT_SNAKE}/g" "$file" || true
    sed_inplace "s/${PLATFORM_KEBAB}/${PROJECT_KEBAB}/g" "$file" || true
    sed_inplace "s/${PLATFORM_FLAT}/${PROJECT_FLAT}/g" "$file" || true
done

log_success "Replaced platform name with project name"

# UPDATE .ENVRC ----------------------------------------------------------------
log_info "Configuring .envrc..."

ENVRC_TEMPLATE="$SRC_DIR/.envrc.template"
ENVRC_FILE="$DEST_DIR/.envrc"

if [ ! -f "$ENVRC_TEMPLATE" ]; then
    log_error ".envrc.template not found in source directory"
    exit 1
fi

# Copy template to destination
cp "$ENVRC_TEMPLATE" "$ENVRC_FILE"

# Create version.txt with initial version
echo "0.1.0" > "$DEST_DIR/version.txt"

# Update PROJECT name
sed_inplace "s/__PROJECT_NAME__/$PROJECT_NAME/" "$ENVRC_FILE"

# Configure GCP if requested
if [ "$CONFIGURE_GCP" = true ]; then
    sed_inplace "s/export GCP_REGISTRY_PROJECT_ID=.*/export GCP_REGISTRY_PROJECT_ID=$gcp_project_id/" "$ENVRC_FILE"
    sed_inplace "s/export GCP_REGISTRY_REGION=.*/export GCP_REGISTRY_REGION=$gcp_region/" "$ENVRC_FILE"
    sed_inplace "s/export GCP_REGISTRY_NAME=.*/export GCP_REGISTRY_NAME=$gcp_repository/" "$ENVRC_FILE"
    log_success "GCP registry configured in .envrc"
fi

# Add platform tracking variables after VERSION line
if ! grep -q "NV_PLATFORM" "$ENVRC_FILE"; then
    # Find line with VERSION and add NV_PLATFORM vars after it
    awk -v platform="$PLATFORM_NAME" -v version="$PLATFORM_VERSION" '
    /^export VERSION=/ {
        print $0
        print ""
        print "# Nedavellir platform tracking"
        print "export NV_PLATFORM=" platform
        print "export NV_PLATFORM_VERSION=" version
        next
    }
    { print }
    ' "$ENVRC_FILE" > "$ENVRC_FILE.tmp" && mv "$ENVRC_FILE.tmp" "$ENVRC_FILE"
fi

log_success "Created and configured .envrc from template"

# CLEAN UP .CLAUDE/ DIRECTORY --------------------------------------------------
if [ "$KEEP_CLAUDE" = false ]; then
    log_info "Cleaning .claude/ directory..."

    # Remove instance-specific files
    rm -f "$DEST_DIR/.claude/plan.md"
    rm -f "$DEST_DIR/.claude/tasks.md"

    # Keep user-facing files:
    # - instructions.md, style.md, workflows.md
    # - commands: upgrade.md, adapt.md, docs.md, adr-new.md, adr-capture.md

    log_success "Removed template development files from .claude/"
else
    log_info "Keeping .claude/ directory"
fi

# CLEAN UP TEMPLATE FILES ------------------------------------------------------
log_info "Cleaning template files..."

# Remove template section from justfile
JUSTFILE="$DEST_DIR/justfile"
if [ -f "$JUSTFILE" ]; then
    # Remove everything from "# TEMPLATE" comment to end of file
    sed_inplace '/# TEMPLATE$/,$ {/# TEMPLATE$/d; d;}' "$JUSTFILE"
fi

# Replace README.md with template
if [ -f "$SRC_DIR/README.template.md" ]; then
    log_info "Creating README from template..."

    # Copy template and substitute variables
    sed "s/{{PROJECT_NAME}}/$PROJECT_NAME/g; \
         s/{{TEMPLATE_NAME}}/$PLATFORM_NAME/g; \
         s/{{TEMPLATE_VERSION}}/$PLATFORM_VERSION/g" \
        "$SRC_DIR/README.template.md" > "$DEST_DIR/README.md"

    log_success "Created README.md from template"
else
    log_warning "README.template.md not found, keeping original README.md"
fi

log_success "Removed template development files"

# CLEANUP BACKUP ---------------------------------------------------------------
# Remove backup on success
if [ -n "$BACKUP_DIR" ] && [ -d "$BACKUP_DIR" ]; then
    rm -rf "$BACKUP_DIR"
fi

# SUMMARY ----------------------------------------------------------------------
echo ""
log_success "✓ Scaffolding complete!"
echo ""
echo "Project: $PROJECT_NAME"
echo "Platform: $PLATFORM_NAME v$PLATFORM_VERSION"
echo ""
log_info "Next steps:"
echo "  1. Review .envrc for project configuration"
echo "  2. Edit justfile to implement build/test/publish recipes"
echo "  3. Add your source code to src/"
echo "  4. Configure GitHub organization secrets (see docs/user-guide.md)"
echo "  5. Initialize git and commit: git init && git add . && git commit -m 'Initial commit'"
echo ""

# Mark successful completion (prevents cleanup on exit)
SCAFFOLD_STARTED=false
