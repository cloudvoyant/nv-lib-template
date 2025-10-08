#!/usr/bin/env bash
: <<DOCUMENTATION
Scaffolds a new project from this platform

Called by Nedavellir CLI after copying platform files to destination.
Updates project-specific configuration in the destination directory.

Usage:
  bash scripts/scaffold.sh --src /path/to/platform --dest /path/to/project
  bash scripts/scaffold.sh --src /path/to/platform --dest /path/to/project --non-interactive
  bash scripts/scaffold.sh --src /path/to/platform --dest /path/to/project --project myapp

Options:
  --src PATH           Path to platform source directory (required)
  --dest PATH          Path to destination project directory (required)
  --non-interactive    Skip prompts, use defaults
  --project NAME       Project name (default: destination directory name)
  --keep-claude        Keep .claude/ directory for AI workflows
DOCUMENTATION

# IMPORTS ----------------------------------------------------------------------
source "$(dirname "$0")/utils.sh"
setup_script_lifecycle

# CONFIGURATION ----------------------------------------------------------------
# Platform name will be read from source .envrc PROJECT variable

# Track if we've started making changes (for cleanup on error)
SCAFFOLD_STARTED=false
BACKUP_DIR=""

# Cleanup function for failed scaffolds
cleanup_on_error() {
    local exit_code=$?
    if [ "$exit_code" -ne 0 ] && [ "$SCAFFOLD_STARTED" = true ]; then
        log_error "Scaffolding failed. Restoring original files..."

        if [ -n "$BACKUP_DIR" ] && [ -d "$BACKUP_DIR" ]; then
            # Restore backed up files
            if [ -f "$BACKUP_DIR/.envrc" ]; then
                cp "$BACKUP_DIR/.envrc" "$DEST_DIR/.envrc"
            fi
            if [ -f "$BACKUP_DIR/justfile" ]; then
                cp "$BACKUP_DIR/justfile" "$DEST_DIR/justfile"
            fi

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
    echo "Usage: bash scripts/scaffold.sh --src /path/to/platform --dest /path/to/project" >&2
    exit 1
fi

if [ ! -d "$SRC_DIR" ]; then
    log_error "Source directory does not exist: $SRC_DIR"
    exit 1
fi

if [ ! -d "$DEST_DIR" ]; then
    log_error "Destination directory does not exist: $DEST_DIR"
    exit 1
fi

validate_project_name() {
    local name=$1
    # Allow alphanumeric, hyphens, underscores
    if [[ ! "$name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        return 1
    fi
    return 0
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

# Read platform name and version from source .envrc
PLATFORM_NAME=$(grep "^export PROJECT=" "$SRC_DIR/.envrc" | cut -d= -f2)
PLATFORM_VERSION=$(grep "^export VERSION=" "$SRC_DIR/.envrc" | cut -d= -f2)

# Fallback to git tag if VERSION not in .envrc
if [ -z "$PLATFORM_VERSION" ]; then
    cd "$SRC_DIR"
    PLATFORM_VERSION=$(get_version)
    cd - > /dev/null
fi

log_info "Platform: $PLATFORM_NAME v$PLATFORM_VERSION"

# BACKUP CRITICAL FILES -------------------------------------------------------
log_info "Creating backup of original files..."

BACKUP_DIR="$DEST_DIR/.nv/.scaffold-backup"
mkdir -p "$BACKUP_DIR"

# Backup files that will be modified
if [ -f "$DEST_DIR/.envrc" ]; then
    cp "$DEST_DIR/.envrc" "$BACKUP_DIR/.envrc"
fi
if [ -f "$DEST_DIR/justfile" ]; then
    cp "$DEST_DIR/justfile" "$BACKUP_DIR/justfile"
fi

# Mark that we've started making changes
SCAFFOLD_STARTED=true

# UPDATE .ENVRC ----------------------------------------------------------------
log_info "Configuring .envrc..."

ENVRC_FILE="$DEST_DIR/.envrc"

# Update PROJECT name and reset VERSION for new project
sed_inplace "s/export PROJECT=.*/export PROJECT=$PROJECT_NAME/" "$ENVRC_FILE"
sed_inplace "s/export VERSION=.*/export VERSION=0.1.0/" "$ENVRC_FILE"

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

# Configure GCP if requested
if [ "$CONFIGURE_GCP" = true ]; then
    # Uncomment and update GCP vars
    sed_inplace "s/# export GCP_PROJECT_ID=.*/export GCP_PROJECT_ID=\"$gcp_project_id\"/" "$ENVRC_FILE"
    sed_inplace "s/# export GCP_REGION=.*/export GCP_REGION=\"$gcp_region\"/" "$ENVRC_FILE"
    sed_inplace "s/# export GCP_REPOSITORY=.*/export GCP_REPOSITORY=\"$gcp_repository\"/" "$ENVRC_FILE"
    log_success "GCP registry configured"
fi

log_success "Updated .envrc"

# CLEAN UP .CLAUDE/ DIRECTORY --------------------------------------------------
if [ "$KEEP_CLAUDE" = false ]; then
    log_info "Cleaning .claude/ directory..."

    # Remove implementation plan
    rm -f "$DEST_DIR/.claude/plan.md"

    # Remove migration docs/workflows (will be added in Phase 10)
    rm -rf "$DEST_DIR/.claude/migrations/"

    # Keep workflows.md and tasks.md for user reference
    log_success "Removed .claude/plan.md"
else
    log_info "Keeping .claude/ directory"
fi

# CLEAN UP PLATFORM DEVELOPMENT FILES ------------------------------------------
log_info "Cleaning platform development files..."

# Remove platform-specific scripts
rm -f "$DEST_DIR/scripts/platform-install.sh"

# Remove platform tests
rm -rf "$DEST_DIR/test/"

# Remove platform development section from justfile
JUSTFILE="$DEST_DIR/justfile"
if [ -f "$JUSTFILE" ]; then
    # Remove everything from "# PLATFORM DEVELOPMENT" to end of file
    sed_inplace '/# PLATFORM DEVELOPMENT/,$d' "$JUSTFILE"
fi

# Remove platform-specific documentation
rm -f "$DEST_DIR/CHANGELOG.md"
rm -f "$DEST_DIR/RELEASE_NOTES.md"

# Replace README.md with template
if [ -f "$SRC_DIR/README.template.md" ]; then
    log_info "Creating README from template..."

    # Copy template and substitute variables
    sed "s/{{PROJECT_NAME}}/$PROJECT_NAME/g; \
         s/{{PLATFORM_NAME}}/$PLATFORM_NAME/g; \
         s/{{PLATFORM_VERSION}}/$PLATFORM_VERSION/g" \
        "$SRC_DIR/README.template.md" > "$DEST_DIR/README.md"

    log_success "Created README.md from template"
else
    log_warning "README.template.md not found, keeping original README.md"
fi

log_success "Removed platform development files"

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
echo "  4. Configure GitHub organization secrets (see docs/setup.md)"
echo "  5. Initialize git and commit: git init && git add . && git commit -m 'Initial commit'"
echo ""

# Mark successful completion (prevents cleanup on exit)
SCAFFOLD_STARTED=false
