# Assist Project Migration

Use this workflow to guide a user through migrating their scaffolded project to a newer platform version.

## Prerequisites

- Platform and version detected via `detect-scaffolded-version.md`
- Target version determined

## Steps

### 1. Find Migration Path

Look for migration guides between current and target version:

```bash
# List all migration guides
ls docs/migrations/*.md | grep -v TEMPLATE

# Check for direct migration
ls docs/migrations/<current>-to-<target>.md

# If not found, look for intermediate migrations
ls docs/migrations/<current>-to-*.md
```

**Example scenarios:**

**Direct migration exists:**
- Current: 1.0.4, Target: 1.1.0
- Found: `1.0.4-to-1.1.0.md`
- Path: Single migration

**Sequential migrations needed:**
- Current: 1.0.4, Target: 1.3.0
- Found: `1.0.4-to-1.1.0.md`, `1.1.0-to-1.2.0.md`, `1.2.0-to-1.3.0.md`
- Path: Three sequential migrations

**Gap in migration guides:**
- Current: 1.0.4, Target: 1.3.0
- Found: `1.0.4-to-1.1.0.md`, `1.2.0-to-1.3.0.md`
- Missing: `1.1.0-to-1.2.0.md`
- Action: Warn user about missing guide

### 2. Build Migration Sequence

Create ordered list of migrations to apply:

```
Migration Path:
1. 1.0.4 → 1.1.0 (docs/migrations/1.0.4-to-1.1.0.md)
2. 1.1.0 → 1.2.0 (docs/migrations/1.1.0-to-1.2.0.md)
3. 1.2.0 → 1.3.0 (docs/migrations/1.2.0-to-1.3.0.md)
```

### 3. Present Migration Plan

Show user the complete migration path:

```
📋 Migration Plan
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Current: 1.0.4
Target:  1.3.0

Required migrations:
  1. 1.0.4 → 1.1.0 ✓ (guide available)
  2. 1.1.0 → 1.2.0 ✓ (guide available)
  3. 1.2.0 → 1.3.0 ✓ (guide available)

Total steps: 3
Estimated time: Review each guide

⚠️  Note: Migrations must be applied sequentially.
   You cannot skip intermediate versions.
```

### 4. Confirm Migration

Ask user if they want to proceed with all migrations.

**If yes** → Continue to step 5
**If no** → Stop, explain they can migrate later

### 5. Create Backup

Ensure project is backed up:

```bash
# Check git status
git status

# If uncommitted changes, warn user
# If clean, create a backup branch
git branch backup-pre-migration-$(date +%Y%m%d)
git tag pre-migration-backup
```

### 6. Execute Migrations Sequentially

For each migration in the sequence:

#### a. Read Migration Guide

```bash
cat docs/migrations/<current>-to-<next>.md
```

#### b. Present Summary

Show breaking changes, new features, required actions

#### c. Execute Steps

Follow guide's migration steps (automatic + manual)

#### d. Update Version

```bash
sed -i 's/^export NV_PLATFORM_VERSION=.*/export NV_PLATFORM_VERSION=<next-version>/' .envrc
direnv allow
```

#### e. Verify

Quick verification before moving to next migration

#### f. Repeat

Move to next migration in sequence

### 7. Final Validation

After all migrations complete, use `validate-project-migration.md` workflow.

## Example: Sequential Migration

```
📋 Migration Plan
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Current: 1.0.4
Target:  1.3.0

Required migrations:
  1. 1.0.4 → 1.1.0 ✓
  2. 1.1.0 → 1.2.0 ✓
  3. 1.2.0 → 1.3.0 ✓

Would you like to proceed? [y/N]

> y

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Step 1/3: Migrating 1.0.4 → 1.1.0
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Reading migration guide...
✓ No breaking changes
✓ New features: scaffold implementation

Updating platform version...
✓ NV_PLATFORM_VERSION: 1.0.4 → 1.1.0

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Step 2/3: Migrating 1.1.0 → 1.2.0
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Reading migration guide...
⚠️  Breaking change: justfile recipe renamed

Manual action required:
  Update .github/workflows/release.yml
  Change: just build-prod → just build --release

Continue? [y/N]

> y

Updating platform version...
✓ NV_PLATFORM_VERSION: 1.1.0 → 1.2.0

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Step 3/3: Migrating 1.2.0 → 1.3.0
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Reading migration guide...
✓ No breaking changes
✓ New features: multi-registry support

Updating platform version...
✓ NV_PLATFORM_VERSION: 1.2.0 → 1.3.0

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
All migrations complete! 🎉
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Final version: 1.3.0
Migrations applied: 3

Running final validation...
```

## Edge Cases

### Missing Intermediate Migration

```
⚠️  Incomplete migration path

Current: 1.0.4
Target:  1.3.0

Available migrations:
  ✓ 1.0.4 → 1.1.0
  ✗ 1.1.0 → 1.2.0 (MISSING)
  ✓ 1.2.0 → 1.3.0

Cannot proceed without 1.1.0-to-1.2.0.md guide.

Options:
1. Migrate to 1.1.0 (stop there)
2. Check platform repository for missing guide
3. Review CHANGELOG for manual migration steps
```

### Failed Intermediate Migration

```
✗ Migration failed at step 2/3 (1.1.0 → 1.2.0)

Current state: 1.1.0 (partially migrated)

Rollback options:
1. Restore from backup: git reset --hard pre-migration-backup
2. Stay at 1.1.0 and investigate issue
3. Manual rollback to 1.0.4

What would you like to do?
```

### Uncommitted Changes

```
⚠️  You have uncommitted changes

Please commit or stash changes before migrating:
  git add . && git commit -m "Pre-migration commit"
  # or
  git stash

Sequential migrations require a clean working directory.
```

## Best Practices

- **One version at a time** - Apply migrations sequentially
- **No version skipping** - Follow the migration path
- **Always backup** - Create branch before starting
- **Test between migrations** - Verify after each step
- **Read all guides first** - Understand full migration path before starting
- **Keep backup** - Don't delete backup branch until confident
