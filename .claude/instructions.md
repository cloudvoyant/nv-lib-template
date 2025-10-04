# Claude Code Instructions

## Plan Maintenance

**IMPORTANT**: Please update `.claude/plan.md` whenever:
- A major task or phase is completed
- Significant architectural changes are made
- New features or scripts are added
- The implementation approach changes

**How to update**: Read the current plan, review the todo list status, and rewrite the relevant sections to reflect actual progress and any new insights.

**Reminder frequency**: Suggest updating the plan after completing 2-3 related tasks or at the end of a work session.

## Project Context

This is a generic, language-agnostic SDK scripting system designed to work with any programming language or framework. The goal is to provide a consistent set of bash scripts for common development tasks (build, test, publish, etc.) that can be easily adapted to different languages and workflows.

## Key Principles

1. **Run from anywhere** - Scripts should work when called from any directory in the repo
2. **Centralized config** - All configuration in `.envrc`, sourced by `utils.sh`
3. **Fail fast** - Use `set -euo pipefail` everywhere
4. **Self-documenting** - Every script includes usage documentation
5. **Language agnostic** - Detect and adapt to different languages/tools
6. **No external dependencies** - Pure bash with minimal tooling requirements

## Development Workflow

When working on this project:
1. Always source the plan before starting work
2. Update todo list as tasks progress
3. Test scripts work from different directories
4. Ensure all scripts use logging shortcut functions
5. Update plan.md when completing milestones
