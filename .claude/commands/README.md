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

#### `/validate-docs`

Validate documentation for completeness and consistency.

- Checks documentation structure
- Validates internal links
- Verifies code examples
- Checks version references
- Finds TODOs and placeholders

**Usage:**

```
/validate-docs
```

#### `/generate-release-notes`

Generate user-friendly release notes from CHANGELOG.md.

- Transforms technical changelog into user-focused release notes
- Adds new versions to existing RELEASE_NOTES.md (preserves history)
- Uses clear, concise language for end users
- Highlights key features and breaking changes

**Usage:**

```
/generate-release-notes
```

### For Platform Development

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

#### `/new-decision`

Interactively create a new Architectural Decision Record (ADR).

- Guides through decision-making process
- Researches relevant context and options
- Presents alternatives with pros/cons
- Creates ADR with proper formatting
- Supports WIP (Work In Progress) status

**Usage:**

```
/new-adr
```

#### `/capture-decisions`

Capture significant decisions from the current session as ADRs.

- Analyzes conversation for key decisions
- Identifies technology, architecture, and process choices
- Generates ADR files for each decision
- Updates ADR index automatically

**Usage:**

```
/capture-decisions
```

## Workflows

These commands invoke workflows in `.claude/migrations/`:

| Command          | Workflow File                 | Purpose                     |
| ---------------- | ----------------------------- | --------------------------- |
| `/upgrade`       | `assist-project-migration.md` | Migrate scaffolded projects |
| `/new-migration` | `generate-migration-guide.md` | Create migration guides     |

Additional workflows:

- `detect-scaffolded-version.md` - Detect platform/version (used by `/upgrade`)
- `validate-project-migration.md` - Verify migration success (used by `/upgrade`)
