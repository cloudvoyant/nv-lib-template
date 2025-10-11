# Style Guide

## Documentation Style Guide

- Create file in `docs/` directory
- Required files
  - `design.md`
    - Goal: explain high level design for maintainers
    - Structure: introduction → features → design → details
    - Save implementation details for `architecture.md`
  - `architecture.md`
    - Explain architecture details for maintainers
    - Structure: overview -> implementation broken down into key components
  - `user-guide.md`
    - Explain usage for clients
- Link from README.md if top-level doc
- Be concise and scannable
- Use backticks for files, commands, and code
- Avoid excessive bold formatting
- Use clear markdown structure
- Include code examples

## Architectural Decision Records (ADRs)

ADRs document important architectural decisions in `docs/decisions/`.

**File naming:** `NNN-short-title.md` (e.g., `001-use-just-as-command-runner.md`)

**Template:**

```markdown
# ADR-NNN: Title

**Status:** Accepted | Superseded | Deprecated

**Date:** YYYY-MM-DD

## Context

What problem are you solving? What's the situation that requires a decision?

## Decision

What did you decide to do?

## Alternatives Considered

### Alternative 1
- **Pros:** Benefits
- **Cons:** Drawbacks

### Alternative 2
- **Pros:** Benefits
- **Cons:** Drawbacks

## Rationale

Why did you make this choice? What factors led to this decision?
```

**When to create an ADR:**
- Choosing a technology or tool
- Defining a pattern or convention
- Making a trade-off decision
- Establishing a constraint
- Selecting an approach for a significant feature

**After creating an ADR:**
- Add entry to `docs/decisions/README.md`
- Update relevant docs (design.md, architecture.md)
- Reference the ADR when explaining the choice

## Justfile Style Guide

- Add `_load` dependency if relying on .envrc variables
- Ensure every task has a description comment
- Use `@` for silent execution if needed
- Use `{{ARGS}}` for parameters
- Keep TODO placeholder if not implemented

## Bash Style Guide

Follow the [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html) with these project-specific conventions:

### Script Template

```bash
#!/usr/bin/env bash
: <<DOCUMENTATION
Description: What this script does
Usage: ./script.sh [options]
DOCUMENTATION

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/utils.sh"
setup_script_lifecycle

# Main logic here
```

### Use Shared Utilities

All scripts should use `scripts/utils.sh` functions:

### Testing

Use **bats** for all script testing:

```bash
@test "validates input" {
    run my_function ""
    [ "$status" -eq 1 ]
    [[ "$output" == *"error"* ]]
}
```

### Additional Resources

- [ShellCheck](https://www.shellcheck.net/) - Automated linting
- [Bash Hackers Wiki](https://wiki.bash-hackers.org/)
