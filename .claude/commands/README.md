# Claude Commands

This template uses the **Claudevoyant** plugin for powerful slash commands that help with template and project management.

## Installation

The Claudevoyant plugin is **automatically installed** when you run:

```bash
just setup --dev
```

The plugin provides all slash commands like `/plan`, `/commit`, `/upgrade`, etc.

### Manual Installation

If you need to install or reinstall the plugin manually, first add the marketplace:

```bash
claude plugin marketplace add cloudvoyant/claudevoyant
```

Then install the plugin:

```bash
claude plugin install claudevoyant
```

Or for local development:

```bash
claude plugin marketplace add ../claudevoyant
claude plugin install claudevoyant
```

## Available Commands

Once installed, you'll have access to these commands:

### Project Management

- `/plan` - Manage project planning using `.claude/plan.md`
  - `/plan new` - Create a new plan by exploring requirements
  - `/plan init` - Initialize an empty plan template
  - `/plan refresh` - Review and update plan status
  - `/plan pause` - Capture insights from planning session
  - `/plan go` - Execute the plan with spec-driven development
  - `/plan done` - Mark plan as complete and optionally commit

- `/upgrade` - Migrate project to latest template version
- `/adapt` - Adapt template to your project's needs

### Development Workflow

- `/commit` - Create conventional commit with proper formatting
- `/review` - Perform comprehensive code review
- `/docs` - Validate documentation completeness

### Architecture & Decisions

- `/adr-new` - Create new Architectural Decision Record
- `/adr-capture` - Capture decisions from current session as ADRs

## Documentation

For detailed command documentation, see the [Claudevoyant plugin repository](https://github.com/claudevoyant/claudevoyant).

## Updating Commands

To update to the latest version of the commands:

```bash
claude plugin update claudevoyant
```

## Plugin Source

The plugin source code and documentation is maintained separately at:
https://github.com/claudevoyant/claudevoyant
