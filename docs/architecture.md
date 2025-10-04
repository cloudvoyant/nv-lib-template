# Architecture

## Project Structure

```
lib/
├── README.md                 # Quick start guide
├── CONTRIBUTING.md           # Contribution guidelines
├── .envrc                    # Environment variables
├── .gitignore                # Git ignore patterns
├── .gitattributes            # Git line ending configuration
├── justfile                  # Command definitions
├── scripts/
│   ├── utils.sh             # Shared bash functions
│   ├── setup.sh             # Dependency installation
│   └── scaffold.sh          # Project initialization
├── src/                      # User source code
├── test/                     # User tests
├── docs/
│   ├── design.md            # System design and features
│   ├── architecture.md      # This file
│   └── commands.md          # Command reference
├── .claude/
│   ├── plan.md              # Implementation plan
│   ├── workflows.md         # AI workflow instructions
│   └── tasks.md             # Task templates
├── .vscode/
│   ├── settings.json        # Editor settings
│   └── extensions.json      # Recommended extensions
├── .devcontainer/
│   ├── devcontainer.json    # VS Code dev container config
│   └── Dockerfile           # Container image
├── .editorconfig            # Cross-editor configuration
└── .github/workflows/
    ├── ci.yml               # PR testing
    ├── release.yml          # Release automation
    └── publish.yml          # Package publishing
```

## Implementation Details

### justfile

Uses `bash` as the shell interpreter:

```just
set shell := ["bash", "-c"]
```

Color variables for output (ANSI escape codes):

```just
INFO := '\033[0;34m'      # Blue
SUCCESS := '\033[0;32m'    # Green
WARN := '\033[1;33m'       # Yellow
ERROR := '\033[0;31m'      # Red
NORMAL := '\033[0m'        # Reset
```

The `_load` recipe is private (prefix `_`) and sources `.envrc`:

```just
_load:
    #!/usr/bin/env bash
    if [ -f .envrc ]; then
        source .envrc
    fi
```

All recipes depend on `_load` to ensure environment variables are available.

### scripts/utils.sh

Provides reusable functions sourced by other scripts and `.envrc`.

Key functions:

- `log_info`, `log_error`, `log_warn`, `log_success` - Colored logging with timestamps
- `spinner` - Progress indicator for long-running background processes
- `progress_step` - Step-based progress (e.g., "1/5 Checking bash...")
- `get_version` - Reads version from git tags, defaults to `0.0.1`
- `get_next_version` - Uses semantic-release dry-run to determine next version
- `command_exists` - Check if a command is available
- `require_command` - Fail with helpful message if command missing
- `sed_inplace` - Cross-platform sed in-place editing
- `setup_script_lifecycle` - Sets `set -euo pipefail`, error traps, and optional lock files

Error handling pattern:

```bash
source "$(dirname "$0")/utils.sh"
setup_script_lifecycle --lock .script.lock

# Script continues with:
# - set -euo pipefail (fail fast)
# - Error trap on line failure
# - Automatic lock file cleanup on exit
```

### scripts/setup.sh

Platform detection using `uname`:

```bash
detect_platform() {
    case "$(uname -s)" in
    Linux*) PLATFORM=Linux ;;
    Darwin*) PLATFORM=Mac ;;
    CYGWIN*) PLATFORM=Cygwin ;;
    MINGW*) PLATFORM=MinGw ;;
    *) PLATFORM="UNKNOWN" ;;
    esac
}
```

Package manager detection for each platform:

- macOS: Homebrew (`brew`)
- Linux: `apt-get`, `yum`, `pacman`
- Fallback: Binary installers via curl

Dependencies installed:

1. Bash (shell)
2. just (command runner)
3. Docker (containerization)
4. direnv (environment management)
5. Node.js/npx (for semantic-release)

Progress tracking:

```bash
local total=5
local current=0
current=$((current + 1))
progress_step $current $total "Checking Bash..."
```

### scripts/scaffold.sh

Currently a stub with TODO. Will implement:

- Interactive prompts for project name, description
- String replacement: `{{PROJECT}}`, `{{DESCRIPTION}}`
- Clean up `.claude/` directory (remove implementation plan)
- Optional git history reset
- Non-interactive mode for automation

### .envrc

Loaded by direnv or sourced by `_load` recipe:

```bash
export PROJECT=yin

# Read version from VERSION file if exists, otherwise default
if [ -f VERSION ]; then
    export VERSION=$(cat VERSION)
else
    export VERSION=0.0.1
fi
```

Uses `get_version` function from `utils.sh` to read from git tags.

### CI/CD Workflows

All workflows run on Ubuntu latest for consistency.

`ci.yml`:

- Triggers on pull requests and feature branch pushes (not main)
- Runs `just build` then `just test`
- Uploads build artifacts
- Required status check blocks merges if failing

`release.yml`:

- Triggers on push to main branch
- Runs semantic-release to analyze commits
- Creates version tags (e.g., `v1.2.3`)
- Updates CHANGELOG.md
- Uses `GITHUB_TOKEN` secret

`publish.yml`:

- Triggers on tag creation (`v*`)
- Checks out code, runs setup
- Executes `just build` and `just publish`
- Creates GitHub release with generated notes
- Users customize `just publish` for their package registry

### Development Container

Minimal Ubuntu 24.04 base in `Dockerfile`:

```dockerfile
FROM ubuntu:24.04
RUN apt-get update && apt-get install -y bash curl sudo
RUN useradd -m -s /bin/bash vscode
USER vscode
WORKDIR /workspace
```

The `devcontainer.json` runs `scripts/setup.sh` to install remaining dependencies:

```json
"postCreateCommand": "bash scripts/setup.sh"
```

This ensures consistency between local and container environments.

## Cross-Platform Considerations

### Line Endings

Enforced LF via `.editorconfig` and `.vscode/settings.json`:

```
end_of_line = lf
insert_final_newline = true
```

### Sed In-Place Editing

macOS requires `-i.bak`, GNU sed uses `-i`. The `sed_inplace` helper handles both:

```bash
sed_inplace() {
    local expression=$1
    local file=$2
    sed -i.bak "$expression" "$file" && rm -f "${file}.bak"
}
```

### Date Commands

Uses compatible format for cache age calculations:

```bash
# Works on both macOS and Linux
date -r "$cache_file" +%s 2>/dev/null || stat -c %Y "$cache_file" 2>/dev/null
```

### Shell Compatibility

Requires Bash 3.2+ (available on all Unix-like systems including macOS default).

Avoids Bash 4+ features like associative arrays.

## Security Implementation

### Secret Patterns in .gitignore

Comprehensive patterns for:

- Environment files: `.env*`
- Keys: `*.key`, `*.pem`, `*.p12`, `*.pfx`, `*.keystore`, `*.jks`
- Certificates: `*.crt`, `*.cer`
- Credentials: `secrets.*`, `credentials.*`, `service-account*.json`
- SSH keys: `id_rsa*`
- Registry configs: `.npmrc`, `.pypirc`

### CI/CD Secrets

Access GitHub Secrets via workflow syntax:

```yaml
env:
  GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
  NPM_TOKEN: ${{ secrets.NPM_TOKEN }}
```

Never hardcode secrets in workflows or scripts.

### Script Safety

All scripts use:

```bash
set -euo pipefail  # Fail on error, unset variables, pipe failures
trap 'log_error "Script failed at line $LINENO"; exit 1' ERR
```

Lock files prevent concurrent execution:

```bash
setup_script_lifecycle --lock .script.lock
```

## Performance Optimizations

### Fast Version Discovery

`get_version` reads from git tags (fast, no network):

```bash
git describe --tags --abbrev=0 2>/dev/null | sed 's/^v//'
```

No calls to slow tools like `npx semantic-release --version`.

### Efficient Setup

Progress indicators provide feedback during long operations.

Dependency checks before installation avoid redundant work.

### Minimal Container

Dev container installs only bash, curl, sudo in Dockerfile. Everything else via `setup.sh` keeps image small and flexible.

## Extension Patterns

### Adding Commands

Edit `justfile`:

```just
new-command *ARGS: _load
    @bash scripts/new-command.sh {{ARGS}}
```

### Adding Scripts

Create `scripts/new-script.sh`:

```bash
#!/usr/bin/env bash
source "$(dirname "$0")/utils.sh"
setup_script_lifecycle

log_info "Running new script..."
# Implementation here
```

### Adding Workflows

Create `.github/workflows/new-workflow.yml`:

```yaml
name: New Workflow
on: [push]
jobs:
  job:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: bash scripts/setup.sh
      - run: just new-command
```

## Dependency Management

The `just install` command handles project dependencies:

```just
install: _load
    npm install  # Node.js
    # pip install -r requirements.txt  # Python
    # go mod download  # Go
    # cargo fetch  # Rust
```

This is separate from `just setup` which installs system-level dependencies (bash, just, docker, etc.).

## Build Artifact Cleanup

The `just clean` command removes build artifacts:

```just
clean: _load
    rm -rf dist/ node_modules/  # Node.js
    # rm -rf dist/ build/ *.egg-info/  # Python
    # rm -rf bin/  # Go
    # cargo clean  # Rust
```

## Testing Considerations

Users should implement tests in their language of choice.

The `just test` command should:

- Run test suite on development build
- Report failures with exit code 1

Example pattern:

```just
test: build
    pytest           # Python
    # npm test       # Node.js
    # go test ./...  # Go
```

CI workflow expects `just test` to fail on test failures (exit code 1).

## Production Builds

The `just build-prod` command creates optimized production artifacts:

```just
build-prod: _load
    NODE_ENV=production npm run build  # Node.js
    # python -m build                  # Python
    # go build -ldflags="-s -w"        # Go
    # cargo build --release            # Rust
```

Production builds are used by the `publish` command but are not separately tested. Tests always run on development builds.

## Release Notes with Claude

The `just release-notes` command uses Claude CLI to generate user-friendly release notes:

```bash
just release-notes
```

Requirements:
- Claude CLI installed: `npm install -g @anthropic-ai/claude-cli`
- Or via Homebrew: `brew install anthropics/claude/claude`

The script:
1. Gets commits since last release
2. Calls Claude CLI to analyze commits
3. Generates `RELEASE_NOTES.md` with user-focused descriptions
4. Prompts you to review and commit

Workflow:
```bash
just release-notes          # Generate with Claude
# Review RELEASE_NOTES.md
git add RELEASE_NOTES.md
git commit -m "docs: release notes for v1.2.0"
git push                    # Release includes both CHANGELOG.md and RELEASE_NOTES.md
```

The GitHub release will use RELEASE_NOTES.md if present, otherwise falls back to auto-generated notes from commits.
