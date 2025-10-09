# Detect Scaffolded Project Version

Use this workflow to detect the platform and version of a scaffolded project.

## When to Use

- User has a project scaffolded from a platform
- Need to determine current platform version
- Planning a migration

## Steps

### 1. Check for .envrc

```bash
cat .envrc
```

If file doesn't exist → **Not a platform-based project**

### 2. Look for Platform Tracking Variables

```bash
grep "^export NV_PLATFORM=" .envrc
grep "^export NV_PLATFORM_VERSION=" .envrc
```

If either variable is missing → **Not a platform-based project**

### 3. Extract Values

```bash
PLATFORM=$(grep "^export NV_PLATFORM=" .envrc | cut -d= -f2)
VERSION=$(grep "^export NV_PLATFORM_VERSION=" .envrc | cut -d= -f2)
PROJECT=$(grep "^export PROJECT=" .envrc | cut -d= -f2)
```

### 4. Determine Latest Version

Ask user for platform repository URL or check common locations:

```bash
# If they know the platform repo
git ls-remote --tags <platform-repo-url> | grep -o 'v[0-9]*\.[0-9]*\.[0-9]*' | sort -V | tail -1
```

### 5. Report Findings

**Platform-based project:**
```
✓ Platform: <platform-name>
✓ Current version: <version>
✓ Project name: <project-name>
→ Latest version: <latest>
```

**Not platform-based:**
```
✗ This is not a platform-based project
  (No NV_PLATFORM or NV_PLATFORM_VERSION found in .envrc)

To adopt a platform for this project, use the nv CLI:
  nv scaffold <platform>

This will provide:
- Standardized build/test/publish workflows
- Automated versioning and releases
- Cross-platform development environment
- Easy updates and migrations
```

## Next Steps

- **If platform detected** → Use `assist-project-migration.md`
- **If not platform-based** → Direct user to use nv CLI for platform adoption

## Example Output

```
I've detected your project configuration:

📦 Platform: yin
📌 Current Version: 1.0.4
🎯 Project Name: my-awesome-app
🆕 Latest Version: 1.1.0

Migration available from 1.0.4 → 1.1.0
Would you like to proceed?
```
