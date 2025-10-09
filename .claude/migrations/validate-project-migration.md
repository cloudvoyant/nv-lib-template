# Validate Project Migration

Use this workflow to verify a project migration completed successfully.

## When to Use

- After completing a migration with `assist-project-migration.md`
- User wants to verify their project is properly updated
- Troubleshooting migration issues

## Validation Checks

### 1. Verify Platform Version

Check `.envrc` has correct version:

```bash
grep "^export NV_PLATFORM_VERSION=" .envrc
```

Expected: `export NV_PLATFORM_VERSION=<target-version>`

### 2. Verify Environment Loads

```bash
direnv allow
source .envrc
echo $NV_PLATFORM_VERSION
```

Should output target version without errors.

### 3. Check Git Status

```bash
git status
```

Should show any expected changes from migration.

### 4. Test Build

```bash
just build
```

Should complete without errors.

### 5. Test Commands

Try key justfile commands:

```bash
just --list
just test
```

All commands should work as expected.

### 6. Check for Breaking Changes

Review migration guide's breaking changes section and verify:
- Any renamed commands work correctly
- Configuration changes applied
- Dependencies updated if needed

## Validation Report

Present results to user:

```
✅ Validation Results
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Platform Version
  ✓ NV_PLATFORM_VERSION: <target>
  ✓ Environment loads correctly

Build & Test
  ✓ Build succeeds
  ✓ Tests pass (or skip if not applicable)

Configuration
  ✓ All required changes applied
  ✓ No deprecated patterns found

Git
  ✓ Clean working directory (or expected changes)
  ✓ Backup branch available

Migration Status: SUCCESS ✓
```

## Common Issues

### Version Not Updated

```
✗ NV_PLATFORM_VERSION still shows old version

Fix:
  sed -i 's/^export NV_PLATFORM_VERSION=.*/export NV_PLATFORM_VERSION=<target>/' .envrc
  direnv allow
```

### Environment Won't Load

```
✗ direnv: error loading .envrc

Fix:
  Check syntax errors in .envrc
  Run: bash -n .envrc
```

### Build Fails

```
✗ just build failed

Check:
  1. Review migration guide for required changes
  2. Check for breaking changes you may have missed
  3. Review error message for specific issue
```

### Commands Don't Work

```
✗ just <command> not found

Check:
  1. Renamed commands (check migration guide)
  2. Run: just --list to see available commands
  3. Update scripts/workflows using old command names
```

## Rollback if Validation Fails

If validation fails and cannot be fixed:

```bash
# Option 1: Restore from backup branch
git reset --hard pre-migration-backup

# Option 2: Restore from tag
git reset --hard pre-migration-backup

# Option 3: Manually revert .envrc
sed -i 's/^export NV_PLATFORM_VERSION=<target>/NV_PLATFORM_VERSION=<original>/' .envrc

direnv allow
```

## Example Output

```
Running validation checks...

✅ Platform version: 1.1.0
✅ Environment loads successfully
✅ Build completes: just build
✅ Tests pass: just test
✅ Git status: clean
✅ Backup available: pre-migration-backup

All checks passed! Migration successful. 🎉

Next steps:
  - Test your project thoroughly
  - Deploy to staging environment
  - Update documentation if needed
  - Delete backup after confidence: git branch -d pre-migration-backup
```
