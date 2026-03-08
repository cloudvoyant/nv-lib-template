# mise-lib-template Style Guide

<!-- @context: build, tools, shell -->

## Build System

**CRITICAL:** This project uses mise for all task execution.

**Before running any bash/npm command:**

1. Check available tasks: `mise tasks`
2. Use `mise run <task>` if a task exists
3. Only use direct commands if no task covers it

**Common tasks:**

- `mise run test` - Run project tests
- `mise run test-template` - Run template bats tests
- `mise run build` - Build project
- `mise run install` - Install npm dependencies (semantic-release)

---

<!-- @context: shell, bash, mise-tasks -->

## Bash Script Conventions (.mise-tasks/)

New scripts in `.mise-tasks/` must follow this header pattern:

```bash
#!/usr/bin/env bash
#MISE description="Short description of what this task does"
# Use #MISE hide=true instead of description for internal-only scripts
set -euo pipefail

source "$(dirname "$0")/utils"
```

**Rules:**

- Always `set -euo pipefail` — fail fast, no silent errors
- Source `.mise-tasks/utils` for shared logging (`log_info`, `log_error`, `log_warn`)
- Use `#MISE hide=true` for internal utilities not meant for direct invocation
- Use `: <<DOCUMENTATION ... DOCUMENTATION` heredoc for complex script documentation

---

<!-- @context: git, commit -->

## Git Commit Messages

Use Conventional Commits. No Claude attributions.

**Types and version impact:**

- `feat:` → MINOR bump (1.x.0)
- `fix:` → PATCH bump (1.0.x)
- `feat!:` / `fix!:` → MAJOR bump (x.0.0)
- `docs:`, `refactor:`, `test:` → changelog only, no bump
- `chore:` → hidden from changelog, no bump

**Rules:**

- Subject max 72 chars, imperative mood, no trailing period
- No "Co-Authored-By: Claude" or similar AI attributions

---

<!-- @context: test, bats -->

## Testing

Tests live in `test/` and use bats-core.

- Run with: `mise run test-template`
- Test files: `test/*.bats`
- Tests cover scaffold behavior, mise.toml handling, case replacements, template cleanup
- Add `--exclude='node_modules'` to any `rsync` calls in test setup

---

<!-- @context: docs -->

## Documentation

- `docs/architecture.md` — system design, component descriptions (keep current)
- `docs/user-guide.md` — how to use the project
- `docs/decisions/` — ADRs for significant architectural choices
- Use `/adr:new` command for major architectural decisions
- Delete `.claude/plan.md` when work is complete
- **Always verify task names against `mise.toml`** before documenting them

---

<!-- @context: code, tools -->

## File Operations

- Use **Edit** tool for modifications, **Write** only for new files
- Use **Grep** for content search, **Glob** for file discovery
- Read files before editing them

---

<!-- @context: templates, scaffold -->

## Template Development (templates/ directory)

**Adding a new template:**
1. Create `templates/<name>/` directory
2. Add only files that differ from the agnostic base
3. Implement ALL contract tasks: build, test, lint, lint-fix, format, format-check,
   publish, docker-build, docker-run, docker-test, upversion, version, version-next
4. Create `templates/<name>/CLAUDE.md.append` with language-specific conventions
5. Do NOT add `.github/workflows/` — base workflows work via mise-action
6. Add bats tests in `test/scaffold-templates.bats` and `test/docker.bats`
7. Register in `templates/README.md`

**Template file restrictions (must NOT override):**
- `.mise-tasks/scaffold` — scaffold logic is universal
- `.mise-tasks/utils` — shared utilities
- `.mise-tasks/upversion` — versioning is universal
- `version.txt` — single source of truth for base template version
- `README.template.md` — base README template

**CLAUDE.md.append rules:**
- Do NOT include `<!-- @context: test, bats -->` — scaffold strips sections with that marker
- Append only language-specific conventions (commands, code style, testing patterns)
- A `---` separator is added automatically before the appended content

**Why no template-specific GitHub Actions:**
`jdx/mise-action@v2` reads `mise.toml` and installs all declared tools (uv, zig, etc.)
automatically. Base workflows call `mise run test`, `mise run publish`, etc. — these
resolve to template-specific implementations via `mise.toml` task definitions.

**Template-only scripts** (removed from scaffolded projects by scaffold cleanup):
- `.mise-tasks/template-utils` — template discovery helpers
- `.mise-tasks/publish-templates` — publishes template packages
- `.mise-tasks/publish-templates-rc` — publishes RC template packages
