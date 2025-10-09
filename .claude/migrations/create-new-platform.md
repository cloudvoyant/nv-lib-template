# Create New Platform

Use this workflow to create a brand new platform repository from scratch.

## When to Use

- Creating a new platform (not scaffolding from an existing platform)
- Need to set up platform structure and configuration
- Want to establish a new base for future projects

## Prerequisites

- Empty git repository or new directory
- Platform name decided
- Initial version number (typically 0.1.0)

## Steps

### 1. Verify Current State

Check if this is a platform or scaffolded project:

```bash
# Check for platform indicators
if [ -f ".envrc" ]; then
    if grep -q "NV_PLATFORM=" .envrc; then
        echo "This appears to be a scaffolded project"
        exit 1
    fi
fi
```

### 2. Gather Platform Information

Ask user for:
- **Platform name** (e.g., "yin", "nova-platform")
  - Must be lowercase, alphanumeric, hyphens/underscores allowed
  - Will be used as PROJECT name in .envrc
- **Initial version** (default: 0.1.0)
- **Description** (one-line summary)
- **Language/tech stack** (Node.js, Python, Go, etc.)

### 3. Clone This Platform as Template

```bash
# Clone this platform repository as a template
git clone https://github.com/cloudvoyant/lib /tmp/platform-template
cd /tmp/platform-template

# Get latest version
git checkout main
```

### 4. Copy Template to New Platform

```bash
# Copy all files to new platform location
rsync -a \
    --exclude='.git' \
    --exclude='.nv' \
    /tmp/platform-template/ /path/to/new-platform/
```

### 5. Configure Platform Identity

Update `.envrc`:

```bash
cd /path/to/new-platform

# Update platform name and version
sed -i 's/^export PROJECT=.*/export PROJECT=<platform-name>/' .envrc
sed -i 's/^export VERSION=.*/export VERSION=<initial-version>/' .envrc

# Remove NV_PLATFORM tracking (this IS the platform, not scaffolded from one)
sed -i '/^# Nedavellir platform tracking/,/^export NV_PLATFORM_VERSION=/d' .envrc

# Load new environment
direnv allow
```

### 6. Update Documentation

**README.md**:
```bash
# Update platform name and description
# Customize getting started instructions
# Update examples with actual platform name
```

**docs/architecture.md**:
```bash
# Update with platform-specific architecture decisions
# Document intended use cases
```

**docs/design.md**:
```bash
# Update design principles for this platform
# Customize to platform's specific goals
```

### 7. Configure Migration System

**Keep migration infrastructure**:
- `docs/migrations/TEMPLATE.md` - For future migrations
- `.claude/migrations/generate-migration-guide.md` - For creating guides
- `.claude/commands/new-migration.md` - For developers

**Remove example migration**:
```bash
rm -f docs/migrations/1.0.4-to-1.1.0.md
```

### 8. Customize Scaffold Script

Update `scripts/scaffold.sh`:

```bash
# Verify the PLATFORM_NAME detection works for new platform
# Test that string replacements work correctly
```

### 9. Initialize Git Repository

```bash
# Initialize if not already a git repo
git init

# Add all files
git add .

# Create initial commit
git commit -m "chore: initialize <platform-name> platform v<version>

Initial platform setup based on Nedavellir template.

Platform: <platform-name>
Version: <version>"

# Tag initial version
git tag v<version>
```

### 10. Set Up GitHub Repository

**Create repository on GitHub**:
```bash
# Create new repository on GitHub
gh repo create <org>/<platform-name> --public --source=. --remote=origin

# Push code
git push -u origin main --tags
```

**Enable GitHub Template**:
- Go to Settings → General
- Check ✅ "Template repository"
- Save changes

### 11. Configure CI/CD

**Update workflows** (`.github/workflows/`):
- Verify release.yml uses correct registry
- Update secrets documentation
- Test CI/CD pipeline

### 12. Create First Migration Template

When ready to release v0.2.0:
```bash
# User can run /new-migration command
# This creates docs/migrations/0.1.0-to-0.2.0.md
```

### 13. Document Platform Usage

Create `docs/platform-usage.md`:
```markdown
# Using This Platform

## Creating Projects

1. Click "Use this template" on GitHub
2. Create new repository
3. Clone and run: `just scaffold`

## Updating Projects

Projects track this platform via:
- `NV_PLATFORM=<platform-name>`
- `NV_PLATFORM_VERSION=<version>`

To upgrade: `/upgrade` command in Claude Code
```

## Example: Creating "nova" Platform

```
Creating new platform: nova v0.1.0

Platform name: nova
Initial version: 0.1.0
Description: Multi-cloud deployment platform
Tech stack: Node.js, TypeScript

Steps:
✓ Cloned template from lib
✓ Copied files to /path/to/nova
✓ Updated .envrc with platform identity
✓ Removed NV_PLATFORM tracking (this is a platform, not scaffolded)
✓ Updated README.md with nova branding
✓ Removed example migrations
✓ Initialized git repository
✓ Created initial commit and tag v0.1.0
✓ Created GitHub repository: org/nova
✓ Enabled GitHub Template

Next steps:
1. Customize platform features for your use case
2. Update architecture docs
3. Test scaffolding process
4. Release when ready: just release
```

## Post-Creation Checklist

- [ ] Platform name and version correct in .envrc
- [ ] No NV_PLATFORM tracking (this IS the platform)
- [ ] README.md updated with platform identity
- [ ] GitHub Template enabled
- [ ] CI/CD workflows tested
- [ ] Scaffold script tested
- [ ] Migration system documented
- [ ] First release tagged

## Differences: Platform vs Scaffolded Project

**Platform Repository**:
- `.envrc` has `PROJECT=<platform-name>`, `VERSION=<version>`
- No `NV_PLATFORM` or `NV_PLATFORM_VERSION` (this IS the platform)
- Contains `docs/migrations/` for creating guides
- Contains `.claude/migrations/generate-migration-guide.md`
- Contains `.claude/commands/new-migration.md`
- Is a GitHub Template
- Users scaffold FROM this

**Scaffolded Project**:
- `.envrc` has `PROJECT=<project-name>`, `VERSION=<project-version>`
- Has `NV_PLATFORM=<platform-name>` and `NV_PLATFORM_VERSION=<version>`
- No `docs/migrations/` (removed by scaffold)
- Has user-facing migration workflows only
- Not a template (created from template)
- Tracks platform version for updates

## Platform Lifecycle

1. **Create** - Use this workflow to create new platform
2. **Develop** - Add features, customize for use case
3. **Release** - Tag versions, create migration guides
4. **Distribute** - Users create projects via GitHub Template
5. **Maintain** - Users upgrade via `/upgrade` command in Claude Code
