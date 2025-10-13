# AI Workflow Instructions

## Project Overview

Get project overview from README.md

## Spec-Driven Workflow

**Always follow this pattern:**

1. **Read plan.md first** - Understand current phase and tasks
2. **Implement in order** - Work through tasks sequentially, add sub-checkboxes for complex tasks
3. **Mark complete immediately** - Check off items as you finish
4. **Use TodoWrite within phases** - Track progress for user visibility
5. **Pause between phases** - Inform user when phase completes, wait for confirmation, ask to commit
6. **Update docs when done** - Sync architecture.md and user-guide.md with reality
7. **Delete plan.md** - Clean up when complete

See `/upgrade` command for reference implementation of this pattern.

## Key Principles

- **Language-agnostic**: Framework scripts in `scripts/`, language-specific in `justfile`
- **Direct customization**: Users edit `justfile`, not hooks
- **Minimal dependencies**: bash, direnv, just, docker, node (for semantic-release)
- **Trunk-based development**: Single main branch, PRs for features

## When Implementing Features

**Language-agnostic features** → `scripts/` (bash)

- setup.sh, utils.sh, scaffold.sh, release-notes.sh
- Generic automation, tooling
- Cross-platform compatibility

**Language-specific features** → `justfile` (user customizes)

- build, test, run, publish commands
- User replaces TODO placeholders
- Keep examples in docs

## File Patterns

**Bash scripts**:

- Include DOCUMENTATION heredoc at top
- Source utils.sh for shared functions
- Use `set -euo pipefail` for error handling
- Make executable with `chmod +x`

**Justfile recipes**:

- Keep placeholder TODOs for language-agnostic template
- Maintain dependencies (e.g., `test: build`)
- Use `_load` to source environment
- No arguments unless needed (test doesn't need args)

**Documentation**:

- Be concise and scannable
- Use backticks for files, commands, code
- Avoid excessive bold formatting
- Structure: introduction → features → design → details

## Phase Completion Workflow

When completing a phase:

1. Mark all tasks complete in `plan.md`
2. Add ✅ to phase heading
3. Inform user: "Phase X complete. Ready to proceed to Phase Y?"
4. **WAIT for user confirmation** before starting next phase
5. Do not assume user wants to continue immediately

## Release Notes Generation

When user runs `just release-notes`, help generate user-friendly release notes:

1. Get commits since last release:

   ```bash
   git log $(git describe --tags --abbrev=0)..HEAD --pretty=format:"%s%n%b" --no-merges
   ```

2. Analyze commits and create `RELEASE_NOTES.md`:

   - Focus on user impact, not implementation
   - Group related changes logically
   - Highlight breaking changes
   - Explain "why" not just "what"
   - Use clear, accessible language
   - Include version from semantic-release

3. Format structure:

   ```markdown
   # Release v{version}

   Brief 1-2 sentence summary of this release.

   ## Highlights

   - Key changes users will notice

   ## Breaking Changes (if any)

   - What broke and how to migrate

   ## New Features

   - Features from user perspective

   ## Improvements

   - Enhancements and optimizations

   ## Bug Fixes

   - Issues resolved
   ```

4. After generating:
   - Tell user to review RELEASE_NOTES.md
   - Commit: `git add RELEASE_NOTES.md && git commit -m "docs: release notes for v{version}"`
   - This file gets included in GitHub release
