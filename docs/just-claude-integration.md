# Just + Claude Code Integration

This platform integrates `just` commands with Claude Code slash commands for AI-assisted workflows.

## Overview

Certain platform operations benefit from AI assistance. These operations can be triggered via:
1. **Just commands** - `just upgrade`, `just new-migration`, etc.
2. **Claude slash commands** - `/upgrade`, `/new-migration`, etc.

Just commands invoke Claude Code CLI when available, providing a seamless developer experience.

## Available Commands

### For Scaffolded Projects (Users)

#### `just upgrade`
Upgrade project to newer platform version.

**What it does:**
- Checks if project is platform-based (has `NV_PLATFORM` in `.envrc`)
- Invokes `claude /upgrade` to start upgrade workflow
- Falls back to manual instructions if Claude CLI not available

**Example:**
```bash
$ just upgrade
# Calls: claude /upgrade
```

**Claude workflow:**
- Detects current platform version
- Finds migration path to target version
- Guides through sequential migrations
- Validates successful migration

---

### For Platform Development

#### `just new-migration`
Create migration guide for new platform version.

**What it does:**
- Invokes `claude /new-migration` to generate migration guide
- Analyzes git history since last version
- Creates structured migration documentation

**Example:**
```bash
$ just new-migration
# Calls: claude /new-migration
```

**Claude workflow:**
- Determines version range (previous → current)
- Analyzes git commits and diffs
- Identifies breaking changes and new features
- Creates migration guide from template

---

#### `just new-platform`
Create new platform repository.

**What it does:**
- Invokes `claude /new-platform` to create platform
- Guides through platform setup

**Example:**
```bash
$ just new-platform
# Calls: claude /new-platform
```

**Claude workflow:**
- Gathers platform information (name, version, description)
- Clones template and customizes
- Configures platform identity
- Sets up GitHub Template

---

## How It Works

### Just Command Layer

```just
migrate: _load
    @if command -v claude >/dev/null 2>&1; then
        if grep -q "NV_PLATFORM=" .envrc 2>/dev/null; then
            claude /upgrade
        else
            echo "This project is not based on a platform"
            exit 1
        fi
    else
        echo "Claude Code CLI not found"
        echo "Install Claude Code or run: /upgrade"
        exit 1
    fi
```

### Claude Slash Command Layer

`.claude/commands/upgrade.md`:
```markdown
Follow the workflow in `.claude/migrations/assist-project-migration.md` to help me migrate this project to a newer platform version.
```

### Workflow Layer

`.claude/migrations/assist-project-migration.md`:
- Detailed step-by-step workflow
- AI reads and executes migration logic
- Interacts with user for decisions
- Validates and verifies results

## When to Use What

### Use Just Commands When:
✅ You want a simple, one-command experience
✅ You're in a terminal workflow
✅ You want automatic Claude CLI invocation
✅ You need validation before starting (e.g., checking `NV_PLATFORM`)

### Use Claude Slash Commands When:
✅ You're already in Claude Code
✅ Claude CLI is not available
✅ You want to invoke workflow directly
✅ You're troubleshooting or debugging

## Installation

### Claude Code CLI

Install Claude Code to enable just command integration:

```bash
# Install Claude Code (follow official instructions)
# The CLI should be available as `claude`

# Verify installation
claude --version
```

### Without Claude Code CLI

If Claude CLI is not available, just commands will show:

```
ERROR: Claude Code CLI not found
Install Claude Code or run: /upgrade
```

You can then run the slash command manually in Claude Code:
```
/upgrade
```

## Command Reference

| Just Command | Claude Command | Purpose | Context |
|--------------|----------------|---------|---------|
| `just upgrade` | `/upgrade` | Upgrade project to newer version | Scaffolded projects |
| `just new-migration` | `/new-migration` | Create migration guide | Platform development |
| `just new-platform` | `/new-platform` | Create new platform | Platform creation |

**Note:** Platform adoption is handled via the nv CLI (`nv scaffold <platform>`), not just commands.

## Best Practices

1. **Version Control**: Always commit changes before running migrations
2. **Backups**: Workflows create backup branches automatically
3. **Sequential**: Migrations must be applied in order (no version skipping)
4. **Testing**: Test migrations on a branch first
5. **Validation**: Always validate after migration completes

## Troubleshooting

### Claude CLI Not Found

```bash
# Check if Claude CLI is installed
command -v claude

# If not found, install Claude Code
# Then verify: claude --version
```

### Just Command Fails

```bash
# Run slash command directly in Claude Code
/upgrade
```

### Migration Fails

```bash
# Restore from backup branch
git reset --hard pre-migration-backup

# Or rollback manually
git checkout pre-migration-backup
```

## Examples

### Upgrading a Project

```bash
# In scaffolded project directory
$ just upgrade

# Claude detects current version
Current platform: yin
Current version: 1.0.4

# Claude finds migration path
Migration Path:
  1. 1.0.4 → 1.1.0 ✓
  2. 1.1.0 → 1.2.0 ✓

# Claude guides through each migration
[Migration proceeds with AI assistance]

# Validation
✅ All migrations complete!
Final version: 1.2.0
```

### Creating Migration Guide

```bash
# In platform repository
$ just new-migration

# Claude analyzes git history
Reading commits from v1.0.4 to HEAD...

# Claude identifies changes
Breaking changes: None
New features:
  - Enhanced scaffold script
  - Case conversion support

# Claude creates guide
✓ Created: docs/migrations/1.0.4-to-1.1.0.md
```

### Creating New Platform

```bash
# In new directory
$ just new-platform

# Claude gathers information
Platform name: nova
Initial version: 0.1.0
Description: Multi-cloud deployment platform

# Claude sets up platform
✓ Cloned template
✓ Configured platform identity
✓ Created GitHub repository
✓ Enabled GitHub Template
```
