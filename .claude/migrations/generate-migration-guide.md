# Generate Migration Guide (Platform Development)

Use this workflow when creating a migration guide for a new platform version.

## When to Use

- You're in a **platform repository** (not a scaffolded project)
- A new version is about to be released
- Need to document changes from previous version

## Steps

### 1. Identify Platform

Read `.envrc` to get platform name:

```bash
grep "^export PROJECT=" .envrc | cut -d= -f2
```

### 2. Determine Version Range

**Current (unreleased) version:**
```bash
source .envrc && echo $VERSION
# Or get from git tags
git tag --sort=-v:refname | head -1
```

**Previous version:**
```bash
git tag --sort=-v:refname | head -2 | tail -1
```

### 3. Analyze Changes

Review commits between versions:

```bash
# List commits
git log <previous-version>..HEAD --oneline

# Check file changes
git diff <previous-version> --stat

# Detailed diff
git diff <previous-version>
```

Look for:
- **Breaking changes**: API changes, removed features, renamed commands
- **New features**: New files, new commands, new functionality
- **Bug fixes**: Fixed issues
- **Documentation updates**: README, docs/ changes

### 4. Create Migration Guide

Use template at `docs/migrations/TEMPLATE.md`:

```bash
cp docs/migrations/TEMPLATE.md docs/migrations/<prev>-to-<new>.md
```

Fill in:
- Version numbers
- Breaking changes (if any)
- New features
- Migration steps (if needed)
- Rollback instructions

### 5. Key Sections

**Breaking Changes**:
- Only include if there ARE breaking changes
- For each change: describe impact and required action
- If none, state "No breaking changes"

**New Features**:
- List significant additions
- Explain what they enable

**Migration Steps**:
- If no breaking changes: "No action required"
- If breaking changes: provide step-by-step instructions
- Include verification commands

### 6. Review Checklist

- [ ] Version numbers correct
- [ ] All breaking changes documented
- [ ] Migration steps are clear and tested
- [ ] Rollback instructions provided
- [ ] Examples use actual commands/code
- [ ] No hardcoded platform names (use generic examples or variables)

## Example Analysis

```bash
# Get changes
$ git log v1.0.4..HEAD --oneline
feat: enhanced string replacement in scaffold.sh
fix: added error handling in scaffold.sh
fix: added scripts to install platform deps

# Check for breaking changes
$ git diff v1.0.4 --name-status | grep -E '^(D|R)'
# (none = no files deleted or renamed = likely no breaking changes)

# Check new files
$ git diff v1.0.4 --name-status | grep '^A'
A    scripts/platform-install.sh
A    test/scaffold.bats
A    README.template.md
```

**Conclusion**: Feature release (1.0.4 → 1.1.0), no breaking changes, several new features.

## Template Variables

When filling template, replace:
- `{{PLATFORM_NAME}}` → Value from `export PROJECT=...`
- `{{FROM_VERSION}}` → Previous git tag
- `{{TO_VERSION}}` → New version (unreleased)
- `{{DATE}}` → Current date

## Output

Migration guide at: `docs/migrations/<from>-to-<to>.md`
