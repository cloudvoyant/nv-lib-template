# Claude Code Instructions

## Plan Maintenance

**IMPORTANT**: Please update `.claude/plan.md` whenever:

- A major task or phase is completed
- Significant architectural changes are made
- New features or scripts are added
- The implementation approach changes

**How to update**: Read the current plan, review the todo list status, and rewrite the relevant sections to reflect actual progress and any new insights.

**Format requirements**:
- Use markdown checkboxes (`- [ ]` for incomplete, `- [x]` for completed)
- Keep completed items visible with checked boxes
- Update success criteria with checkboxes
- Mark implementation steps as completed as work progresses

**Reminder frequency**: Suggest updating the plan after completing 2-3 related tasks or at the end of a work session.

## Project Context

The following files MUST be respected:

**User-facing documentation** (in `docs/`):
- `docs/design.md` captures the project's design principles and philosophy - this is effectively the prime directive that must be respected at all times
- `docs/architecture.md` captures architecture and important implementation details. The architecture outlined in this doc must be respected, and implementation details must be kept up to date as development proceeds.
- `docs/user-guide.md` is a user guide for the project, and must similarly be kept up to date.
- `docs/decisions/` contains Architectural Decision Records (ADRs) documenting important design choices. When making significant architectural changes:
  - Create a new ADR file: `docs/decisions/NNN-short-title.md`
  - Follow the ADR template in `.claude/style.md`
  - Update the index in `docs/decisions/README.md`
  - Update relevant documentation (design.md, architecture.md)
  - Reference ADRs when explaining architectural choices

## Git Commit Guidelines

**FORBIDDEN**: Do NOT add Claude Code attributions to git commit messages.

- ❌ NO "🤖 Generated with [Claude Code]" lines
- ❌ NO "Co-Authored-By: Claude <noreply@anthropic.com>" lines
- ❌ NO self-attributions of any kind
- ❌ NO emojis in commit messages

Git commits should be clean, professional, and contain only the commit message itself.

## Testing Guidelines

**CRITICAL**: Always run tests using `just platform-test` (not direct bats commands).

When encountering unexpected test failures:

1. **First**, run `direnv allow` to ensure .envrc is loaded
2. **Then**, run tests via `just platform-test` (which ensures proper environment setup)
3. If tests still fail, investigate the specific failure

**Why this matters:**
- Tests depend on environment variables (VERSION, PROJECT, etc.) from .envrc
- Running tests without direnv loaded causes cryptic failures
- `just platform-test` ensures the environment is properly configured

**Never:**
- Run bats tests directly without checking environment is loaded
- Debug test failures without first verifying `direnv allow` was run
- Assume environment variables are set without checking

## Development Workflow

When working on this project:

1. Always source the plan before starting work
2. Update todo list as tasks progress
3. Test scripts work from different directories
4. Ensure all scripts use logging shortcut functions
5. Update plan.md when completing milestones
6. When plan.md is completed, review project docs and ensure they are up-to-date
7. Delete plan.md
