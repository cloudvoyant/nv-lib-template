Generate user-friendly release notes from CHANGELOG.md.

## Purpose

Transform the auto-generated CHANGELOG.md (created by semantic-release) into user-friendly RELEASE_NOTES.md that's readable for end users.

**Important**: This command adds new release notes to existing RELEASE_NOTES.md rather than overwriting it.

## Prerequisites

Check that CHANGELOG.md exists:

```bash
ls -la CHANGELOG.md
```

If CHANGELOG.md doesn't exist, you need to run a release first.

## Steps

### 1. Read the CHANGELOG and Existing Release Notes

Read the current CHANGELOG.md:

```bash
cat CHANGELOG.md
```

Check if RELEASE_NOTES.md already exists:

```bash
cat RELEASE_NOTES.md 2>/dev/null || echo "No existing release notes"
```

### 2. Identify New Versions

Compare CHANGELOG.md with RELEASE_NOTES.md to find which versions are new and need user-friendly notes.

**If RELEASE_NOTES.md exists:**
- Extract the latest version number from RELEASE_NOTES.md
- Only generate notes for versions in CHANGELOG.md that are newer than the latest in RELEASE_NOTES.md
- This prevents regenerating notes for versions that already have user-friendly descriptions

**If RELEASE_NOTES.md doesn't exist:**
- Generate notes for all versions in CHANGELOG.md

### 3. Generate User-Friendly Release Notes

Transform only the **new version(s)** from the changelog into user-focused release notes with:

- **Clear, concise summaries** of what changed
- **User-focused language** - impact over implementation details
- **Organized by release version** - same structure as changelog
- **Highlights** of key features and improvements
- **Breaking changes** clearly marked with ⚠️ or 🚨
- **Omit overly technical details** - focus on user impact

**Guidelines:**
- Keep version numbers and structure from CHANGELOG.md
- Translate technical commit messages into user benefits
- Group related changes together
- Use active voice ("Added X", "Fixed Y", "Improved Z")
- Explain why changes matter to users

**Example transformation:**

CHANGELOG (technical):
```
feat: add GitHub template support and migration workflows
fix: added error handling in scaffold.sh
```

RELEASE_NOTES (user-friendly):
```
### New Features
- **GitHub Template Support**: You can now use "Use this template" to create new projects directly from GitHub
- **Automated Migration**: Upgrade projects between platform versions with interactive migration guides

### Improvements
- **Better Error Messages**: The scaffold script now provides clearer error messages when setup fails
```

### 4. Update Release Notes File

**If RELEASE_NOTES.md exists:**
- Prepend the new release notes to the top of the existing file
- Keep all existing release notes intact
- Maintain chronological order (newest first)

**If RELEASE_NOTES.md doesn't exist:**
- Create new file with the generated notes

Use the Write or Edit tool to update the file at the project root.

### 5. Display and Confirm

Show the newly added release notes to the user and provide next steps:

```
Release notes updated: RELEASE_NOTES.md

Added release notes for version X.Y.Z

Next steps:
1. Review RELEASE_NOTES.md and edit if needed
2. Commit: git add RELEASE_NOTES.md && git commit -m 'docs: add release notes for vX.Y.Z'
```

## Example Output Format

```markdown
# Release Notes

## Version 1.2.0 (2025-10-11)

### New Features

🎉 **ADR Management System**
- Create architectural decision records interactively with `/new-decision`
- Automatically capture decisions from your work sessions with `/capture-decisions`
- Track the "why" behind your technical choices

📝 **Documentation Validation**
- New `/validate-docs` command checks that documentation matches your actual project
- Verifies code examples, file paths, and version references
- Available for all projects, not just platform development

### Improvements

✨ **Setup Script Enhancement**
- Now distinguishes between required and optional dependencies
- Use `--include-optional` flag to install all development tools
- Clearer error messages when dependencies are missing

📚 **Documentation Updates**
- Comprehensive migration guide for v1.1.0 → v1.2.0
- Updated user guide with ADR workflows
- Added git commit and testing guidelines

### Breaking Changes

None - this is a fully backward-compatible release.

---

## Version 1.1.0 (2025-10-09)

... (existing release notes preserved)
```

## Tips

- Focus on the user's perspective: "What can I do now that I couldn't before?"
- Use emojis sparingly for key features (🎉 ✨ 🚨 ⚠️ 📝 🔧)
- Group similar changes under clear headings
- Keep it scannable - users should grasp changes in 30 seconds
- Link to migration guides for version upgrades
- **Always preserve existing release notes** - only add new versions
