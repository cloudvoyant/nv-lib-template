# Migration Guide: vX.Y.Z to vA.B.C

> **Platform:** yin
> **From Version:** X.Y.Z
> **To Version:** A.B.C
> **Date:** YYYY-MM-DD

## Overview

Brief description of what changed in this version and why users need to migrate.

## Breaking Changes

List all breaking changes that require manual intervention:

1. **Change 1**: Description
   - **Impact**: Who/what is affected
   - **Action Required**: What users need to do

2. **Change 2**: Description
   - **Impact**: Who/what is affected
   - **Action Required**: What users need to do

## New Features

List significant new features added in this version:

- Feature 1: Description
- Feature 2: Description

## Migration Steps

### Automatic Migration

The `just migrate` command will automatically:

1. Update `NV_PLATFORM_VERSION` in `.envrc`
2. Apply automated fixes (if any)
3. Update configuration files (if needed)

### Manual Steps

If there are manual steps required:

#### Step 1: Update Configuration

```bash
# Example commands
sed -i 's/old_pattern/new_pattern/' file.txt
```

#### Step 2: Test Changes

```bash
just build
just test
```

#### Step 3: Verify Migration

```bash
# Verification steps
grep "NV_PLATFORM_VERSION" .envrc
# Should show: export NV_PLATFORM_VERSION=A.B.C
```

## Rollback

If you need to rollback:

```bash
# Restore from backup
cp .nv/.scaffold-backup/.envrc .envrc

# Or manually update version
sed -i 's/NV_PLATFORM_VERSION=A.B.C/NV_PLATFORM_VERSION=X.Y.Z/' .envrc
```

## Troubleshooting

### Common Issues

**Issue 1**: Description
- **Solution**: How to fix

**Issue 2**: Description
- **Solution**: How to fix

## Support

For questions or issues:
- Check the [platform documentation](../README.md)
- Review [architecture docs](../architecture.md)
- Open an issue on GitHub

## Changelog

Full changelog: [CHANGELOG.md](../../CHANGELOG.md#ABC)
