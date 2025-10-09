# AI Migration Workflows

This directory contains workflows to help AI assistants with platform migrations.

## For Platform Development

When working on **a platform repository** to create a new version:

- `generate-migration-guide.md` - Help create migration guides for new platform versions

## For Scaffolded Projects

When helping users with **projects scaffolded from a platform**:

- `detect-scaffolded-version.md` - Detect platform and version from scaffolded project
- `assist-project-migration.md` - Guide user through migrating their scaffolded project
- `validate-project-migration.md` - Verify scaffolded project migration succeeded

## Which Workflow to Use?

**Platform Repository** (PROJECT in .envrc matches repository, VERSION from git tags):
- Use `generate-migration-guide.md`

**Scaffolded Project** (has NV_PLATFORM and NV_PLATFORM_VERSION in .envrc):
- Use `detect-scaffolded-version.md` → `assist-project-migration.md` → `validate-project-migration.md`
