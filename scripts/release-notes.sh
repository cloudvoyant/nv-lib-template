#!/usr/bin/env bash
: <<DOCUMENTATION
Generate release notes using Claude CLI

Requirements:
- Claude CLI installed (https://github.com/anthropics/claude-cli)
- Git repository with commits

Usage:
  bash scripts/release-notes.sh
DOCUMENTATION

# IMPORTS ----------------------------------------------------------------------
source "$(dirname "$0")/utils.sh"
setup_script_lifecycle

# CONFIGURATION ----------------------------------------------------------------
NOTES_FILE="RELEASE_NOTES.md"

# CHECK DEPENDENCIES -----------------------------------------------------------
if ! command_exists claude; then
    log_error "Claude CLI not found"
    echo "Install: npm install -g @anthropic-ai/claude-cli" >&2
    echo "Or: brew install anthropics/claude/claude" >&2
    exit 1
fi

# GET VERSION INFO -------------------------------------------------------------
log_info "Getting version information..."
next_version=$(get_next_version)

if [ -z "$next_version" ]; then
    log_warn "No new version detected"
    echo "Make commits with conventional format (feat:, fix:, etc.)" >&2
    exit 0
fi

log_info "Next version will be: $next_version"

# GET COMMITS ------------------------------------------------------------------
log_info "Analyzing commits since last release..."

last_tag=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
if [ -n "$last_tag" ]; then
    commits=$(git log "$last_tag"..HEAD --pretty=format:"%s%n%b%n---" --no-merges)
    log_info "Found commits since $last_tag"
else
    commits=$(git log --pretty=format:"%s%n%b%n---" --no-merges)
    log_info "No previous tags found, analyzing all commits"
fi

if [ -z "$commits" ]; then
    log_warn "No commits found"
    exit 0
fi

# GENERATE RELEASE NOTES -------------------------------------------------------
log_info "Generating release notes with Claude..."

claude_prompt="Analyze these git commits and generate user-friendly release notes for version $next_version.

Commits:
$commits

Generate a RELEASE_NOTES.md file with this structure:

# Release v$next_version

[1-2 sentence summary of this release]

## Highlights
- [Key user-facing changes]

## Breaking Changes
- [List breaking changes, or omit this section if none]

## New Features
- [Features from user perspective]

## Improvements
- [Enhancements and optimizations]

## Bug Fixes
- [Issues resolved]

Guidelines:
- Focus on user impact, not implementation details
- Group related changes together
- Use clear, accessible language
- Explain 'why' not just 'what'
- Omit sections if empty
- Be concise but informative

Generate only the markdown content, no other commentary."

# Call Claude CLI and save output
if echo "$claude_prompt" | claude > "$NOTES_FILE" 2>/dev/null; then
    log_success "Release notes generated: $NOTES_FILE"
    echo ""
    cat "$NOTES_FILE"
    echo ""
    log_info "Next steps:"
    echo "  1. Review $NOTES_FILE"
    echo "  2. Edit if needed"
    echo "  3. Commit: git add $NOTES_FILE && git commit -m 'docs: release notes for v$next_version'"
    echo "  4. Push and merge - release will include these notes"
else
    log_error "Failed to generate release notes"
    exit 1
fi
