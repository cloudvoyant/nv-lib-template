# Migration Guide: vX.Y.Z to vA.B.C

## Overview

- **Summary**: Brief description of what changed in this version and why users need to migrate.
- **Platform**: platform-lib
- **From Version**: X.Y.Z
- **To Version**: A.B.C
- **Date**: YYYY-MM-DD

## Breaking Changes

List all breaking changes that require manual intervention:

1. **Change 1**: Description

   - **Impact**: Who/what is affected (scaffolded projects, platforms, or both)
   - **Action Required**: What users need to do

2. **Change 2**: Description

   - **Impact**: Who/what is affected (scaffolded projects, platforms, or both)
   - **Action Required**: What users need to do

## New Features

List significant new features added in this version:

- Feature 1: Description
- Feature 2: Description

## Migration Steps

### For Scaffolded Projects

Projects scaffolded from this platform (regular applications).

#### Automatic Migration

The `just upgrade` command will automatically:

1. Detect current platform version from `.envrc`
2. Download migration guides
3. Apply automated fixes (if any)
4. Update `NV_PLATFORM_VERSION` in `.envrc`

```bash
just upgrade
```

#### Manual Steps

If automatic migration is not available or fails:

##### Step 1: Update Files

List specific files that need updating:

```bash
# Example: Update justfile
curl -o justfile.new https://raw.githubusercontent.com/ORG/platform-lib/vA.B.C/justfile
# Manually merge changes preserving your customizations
```

##### Step 2: Update Configuration

```bash
# Example: Update .envrc
echo 'export NEW_VAR=value' >> .envrc
```

##### Step 3: Test Changes

```bash
just build
just test
```

##### Step 4: Update Platform Version

```bash
sed -i 's/NV_PLATFORM_VERSION=X.Y.Z/NV_PLATFORM_VERSION=A.B.C/' .envrc
```

### For Forked/Scaffolded Platforms

If you scaffolded your own platform from an earlier version.

#### Step 1: Identify Changed Files

List core platform files that changed:

- `scripts/setup.sh`
- `scripts/scaffold.sh`
- `justfile`
- `.github/workflows/*.yml`

#### Step 2: Update Core Scripts

```bash
# Backup current files
cp scripts/setup.sh scripts/setup.sh.backup

# Download new version
curl -o scripts/setup.sh https://raw.githubusercontent.com/ORG/platform-lib/vA.B.C/scripts/setup.sh

# Review and merge changes
diff scripts/setup.sh.backup scripts/setup.sh
```

#### Step 3: Update CI Workflows

```bash
# Update workflow files
# Example changes to .github/workflows/ci.yml
```

#### Step 4: Update Platform Documentation

Update docs to reflect changes:
- README.md
- docs/user-guide.md
- docs/architecture.md

#### Step 5: Update Platform Version

```bash
sed -i 's/export VERSION=X.Y.Z/export VERSION=A.B.C/' .envrc
```

#### Step 6: Test Platform

```bash
# Test setup
just setup --dev --platform

# Run platform tests
just platform-test

# Test scaffolding
cd /tmp/test-project
bash /path/to/platform/scripts/scaffold.sh --src /path/to/platform --dest . --project test
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
