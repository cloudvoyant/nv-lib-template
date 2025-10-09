# Claude Commands

Custom slash commands for platform and project management.

## Available Commands

### For Scaffolded Projects (Users)

#### `/upgrade`
Upgrade this project to a newer platform version.
- Detects current platform and version
- Finds migration path to target version
- Guides through sequential migrations
- Validates successful migration

**Usage:**
```
/upgrade
```

### For Platform Development

#### `/new-platform`
Create a new platform repository from scratch.
- Guides through platform setup and configuration
- Initializes core platform structure
- Configures platform identity and versioning
- Sets up GitHub Template distribution

**Usage:**
```
/new-platform
```

#### `/new-migration`
Generate a migration guide for a new platform version.
- Analyzes git history since last version
- Identifies breaking changes and new features
- Creates migration guide from template
- Documents upgrade path

**Usage:**
```
/new-migration
```

## Workflows

These commands invoke workflows in `.claude/migrations/`:

| Command | Workflow File | Purpose |
|---------|--------------|---------|
| `/upgrade` | `assist-project-migration.md` | Migrate scaffolded projects |
| `/new-platform` | `create-new-platform.md` | Create new platform repository |
| `/new-migration` | `generate-migration-guide.md` | Create migration guides |

Additional workflows:
- `detect-scaffolded-version.md` - Detect platform/version (used by `/upgrade`)
- `validate-project-migration.md` - Verify migration success (used by `/upgrade`)
