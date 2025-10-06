# Language-Agnostic Build System Platform

## Mission

Build a **language-agnostic build system platform** for **Nedavellir (nv)** - a tool that manages multiple development platforms.

This repository is **one platform option** that nv can scaffold and manage. Other platforms will exist in separate repositories with different setups (e.g., microservices platform, monorepo platform, serverless platform, etc.).

Nedavellir (nv) provides:
- Platform scaffolding via GitHub Templates
- Version-aware migrations between platform versions
- Multi-platform management
- Unified developer experience across platforms

### Requirements

Support common development workflows across any language:

- Build projects
- Run tests
- Execute locally
- Install dependencies
- Format code
- Lint code
- Publish packages
- Manage documentation
- Automated versioning
- Docker and dev container support
- CI/CD with GitHub Actions
- Standard IDE/editor configuration
- Easy to swap languages, package registries, and docker registries

### Technology Stack

- `bash`: Core scripting language for maximum portability
- `direnv`: Automatic environment management
- `just`: Modern command runner for intuitive developer experience
- `docker`: For dev containers and docker based runs

### Principles

- Easy to extend by editing justfile directly
- Modern, intuitive developer experience
- Fork-friendly architecture
- Platform-aware versioning and migrations

### Platform Versioning via .envrc

**This Repo (Platform Repository):**

Contains minimal `.envrc`:
```bash
source ./scripts/utils.sh

export PROJECT=yin
export VERSION=$(get_version)  # Git tags = platform version
```

**Scaffolded Projects:**

When scaffolding a new project from this platform, the scaffold script adds platform tracking to `.envrc`:

```bash
source ./scripts/utils.sh

export NV_PLATFORM="language-agnostic-build-system"
export NV_PLATFORM_VERSION="1.0.0"  # Version scaffolded from
export PROJECT="myproject"           # User's project name
export VERSION=$(get_version)        # User's git tags

# GCP registry config (optional)
export GCP_PROJECT_ID="your-gcp-project-id"
export GCP_REGION="us-central1"
export GCP_REPOSITORY="your-artifact-repository"
```

**Migration:**

`just migrate` reads `NV_PLATFORM_VERSION` from `.envrc`, downloads migration scripts from platform repo, applies them, and updates the version using `sed`:

```bash
sed -i 's/^export NV_PLATFORM_VERSION=.*/export NV_PLATFORM_VERSION="2.0.0"/' .envrc
```

**Benefits:**
- No JSON parsing or jq dependency
- Shell-native, direnv auto-loads
- Simple sed-based updates
- Platform version only in scaffolded projects, not in platform repo itself

## Design

### Project Structure

```
lib/
├── README.md             # Project overview and links to docs
├── .envrc                # Environment configuration
├── justfile              # Command definitions (customize here!)
├── scripts/              # Reusable bash utilities
│   ├── utils.sh         # Shared functions (logging, versioning, etc.)
│   ├── setup.sh         # Environment setup
│   └── scaffold.sh      # Project initialization
├── src/                 # Your source code
├── test/                # Your tests
├── docs/                # User and developer documentation
│   ├── README.md        # Quick start guide
│   ├── architecture.md  # System design
│   └── ...              # Additional guides
├── .claude/             # AI assistant context
│   └── plan.md         # Implementation plan (this file)
└── .github/
    └── workflows/       # CI/CD automation
```

### Usage Examples

**Developer Workflow**

```bash
# Clone and setup
git clone <repo>
just setup

# Daily development
just install          # Install dependencies
just build            # Build project
just run              # Run locally
just test             # Run tests

# Code quality
just format           # Format code
just lint             # Check linting
just lint-fix         # Auto-fix issues

# Publishing
git commit -m "feat: new feature"
git push              # Triggers automated release
```

**Customizing for Your Language**

Simply edit `justfile` and replace TODO placeholders with your commands:

_Node.js Project_

```just
build: _load
    npm run build

test *ARGS: build
    npm test {{ARGS}}

run: build
    node dist/index.js
```

_Python Project_

```just
build: _load
    python -m build

test *ARGS: build
    pytest {{ARGS}}

run: build
    python -m mypackage
```

_Go Project_

```just
build: _load
    go build -o bin/app

test *ARGS: build
    go test ./... {{ARGS}}

run: build
    ./bin/app
```

_Rust Project_

```just
build: _load
    cargo build --release

test *ARGS: build
    cargo test {{ARGS}}

run: build
    cargo run
```

### Workflow Illustration

**For a Node.js Library**

```bash
$ just build
npm run build
✓ Build complete!

$ just test
npm test
✓ All tests passed

$ just publish
Current version: 1.2.3
Next version: 1.3.0
npm publish
✓ Published successfully
```

**For a Python Package**

```bash
$ just format
black .
✓ All files formatted

$ just lint
pylint mypackage/
✓ No issues found

$ just publish
Building wheel...
Publishing to PyPI...
✓ Published successfully
```

### Extensibility Example

**Fork and Customize**

1. Fork the repository
2. Edit `justfile` - replace TODOs with your language commands
3. Optionally use bash utils from `scripts/utils.sh`
4. All commands work immediately

## Implementation Plan

### Phase 1: LLM Assistant Configuration ✅

**AI-Specific Context** (`.claude/`)

- [x] Implementation plan (this file)
- [x] Task templates (tasks.md)
- [x] AI workflow instructions (workflows.md)

### Phase 2: Foundation ✅

**Environment & Utilities**

- [x] `.envrc` with PROJECT and VERSION variables
- [x] `scripts/utils.sh` with reusable functions
- [x] Error handling, logging, lock file management
- [x] Version management functions (`get_version`, `get_next_version`)

**Command Interface**

- [x] `justfile` with placeholder recipes
- [x] `_load` recipe to source environment
- [x] Recipe dependencies (build → run → test → publish)

**Setup**

- [x] `scripts/setup.sh` for installing dependencies
- [x] Platform detection and package manager support
- [x] Node.js/npx installation for semantic-release

### Phase 3: Automation

**Versioning**

- [x] `.releaserc.json` for semantic-release configuration
- [x] GitHub Actions workflow for automated releases

**CI/CD Workflows**

- [x] **PR/Feature Branch CI** (`ci.yml`)

  - Run tests on every commit to feature branches
  - Run build to ensure it compiles
  - Block merges if tests fail (required status check)

- [x] **Release and Publish** (`release.yml`)

  - Trigger on merge to main
  - Run semantic-release to analyze commits
  - Determine version and create git tag
  - Update VERSION file and CHANGELOG.md
  - Build production artifacts
  - Publish package to registry
  - Create GitHub release with notes
  - Combined into single workflow for simplicity

### Phase 4: Dev Container Support ✅

**Dev Container Configuration**

- [x] `.devcontainer/devcontainer.json` - VS Code dev container config
- [x] `.devcontainer/Dockerfile` - Ubuntu 24.04 base image
- [x] Container setup uses `scripts/setup.sh` for dependencies
- [x] VS Code extensions (direnv, just, docker)
- [x] Docker-in-docker feature

### Phase 5: IDE Configuration ✅

**VS Code Settings** (`.vscode/`)

- [x] `settings.json` - Editor settings (formatting, line endings, etc.)
- [x] `extensions.json` - Recommended extensions (direnv, just, docker, shellcheck)

**Editor Config**

- [x] `.editorconfig` - Cross-editor configuration (indentation, charset, etc.)

### Phase 6: Polish ✅

**Developer Experience**

- [x] Colored output in justfile recipes
- [x] Better error messages with suggestions
- [x] Progress indicators for long operations

**Validation**

- [x] Ensure cross-platform compatibility
- [x] Performance optimization
- [x] Security review (secret scanning, etc.)

### Phase 7: Documentation ✅

**User Documentation** (`docs/`)

- [x] `docs/design.md` - Requirements, system design and structure
- [x] `docs/architecture.md` - Implementation considerations and important details
- [x] Command reference integrated into `design.md` (no separate commands.md)

**Project Root Documentation**

- [x] `README.md` - Quick start, project overview, links to docs and user guide
- [x] `CONTRIBUTING.md` - How to contribute

### Phase 8: Artifact Registry Publishing ✅

**Consolidated Publishing via `publish` Recipe**

- [x] Updated `publish` recipe to use `gcloud artifacts generic upload`
- [x] Removed separate `registry-publish` and `registry-auth` recipes
- [x] Publishing logic consolidated in single customizable `publish` recipe
- [x] GitHub Actions workflow uses `just publish` with secrets
- [x] Documentation for customization (npm, PyPI, Docker, multi-registry)
- [x] Environment variable configuration (.envrc updates)
- [x] build-prod creates dummy artifact (dist/artifact.txt)

### Phase 9: Project Scaffolding

**Scaffold Script** (`scripts/scaffold.sh`)

- [ ] Interactive prompts for project details (name, description, etc.)
- [ ] Update .envrc with platform tracking:
  - Add `export NV_PLATFORM="language-agnostic-build-system"`
  - Add `export NV_PLATFORM_VERSION="$(get_version)"` (current platform version from git tags)
  - Update `export PROJECT="<user-input>"` with user's project name
  - Add registry config if using GCP (optional, interactive prompt)
- [ ] String replacement in template files:
  - Replace `{{PROJECT}}` with user's project name in remaining files (if any)
- [ ] Reset `.claude/` directory:
  - Remove `plan.md` (this implementation plan)
  - Remove migration docs/workflows (added in Phase 10)
  - Optionally keep empty .claude/ for user's own AI context
- [ ] Initialize git history:
  - Option to squash/reset commit history
  - Create initial commit with scaffolded project
- [ ] Non-interactive mode for automation
- [ ] Validation of inputs (project name format, etc.)

### Phase 10: Platform Migration Documentation

**Version-Aware Migration System**

- [ ] Version tracking via .envrc
  - `NV_PLATFORM` identifies this platform
  - `NV_PLATFORM_VERSION` tracks platform version
  - Scaffold script writes initial values to .envrc
  - Migrations update NV_PLATFORM_VERSION using sed
- [ ] Migration guides (docs/migrations/)
  - `1.0.0-to-2.0.0.md` - Version-specific migration steps
  - `2.0.0-to-3.0.0.md` - Subsequent version migrations
  - Template for future version migrations
- [ ] AI migration workflows (.claude/migrations/)
  - Platform and version detection workflow
  - Automated migration assistance per version
  - Breaking change detection and fixes
  - Migration validation workflow
- [ ] Migration command (`just migrate`)
  - Sources .envrc and reads `NV_PLATFORM` and `NV_PLATFORM_VERSION`
  - Detects platform repository (GitHub API or local config)
  - Compares to latest platform version (git tags)
  - Downloads and applies migration scripts
  - Updates `NV_PLATFORM_VERSION` in .envrc using sed:
    ```bash
    sed -i 's/^export NV_PLATFORM_VERSION=.*/export NV_PLATFORM_VERSION="2.0.0"/' .envrc
    ```
- [ ] nv CLI integration (future)
  - `nv migrate` - Migrate to latest platform version
  - `nv platforms` - List available platforms
  - `nv scaffold <platform>` - Create new project from platform template
- [ ] Document GitHub Templates vs Forking
  - Pros/cons of each approach
  - Recommendation: GitHub Templates (cleaner history, no fork relationship)
  - Setup instructions for creating GitHub Templates
- [ ] Update scaffold script to remove migration artifacts
  - Remove docs/migrations/
  - Remove .claude/migrations/
  - .envrc persists with user's project configuration (NV_PLATFORM, NV_PLATFORM_VERSION, PROJECT, etc.)

### Phase 11: Multi-Registry Support Patterns

**Make it easy for users to swap registry providers**

- [ ] Choose 2-3 sensible default implementations
  - GCP Artifact Registry (already implemented)
  - npm (most common for Node.js projects)
  - Docker Hub (most common for containers)
- [ ] Create docs/registry-examples.md
  - Show complete working examples for each default
  - Template pattern for adding your own registry
  - Clear sections showing what to modify:
    - .envrc variables
    - justfile publish recipe
    - GitHub Actions authentication
    - Organization secrets needed
- [ ] Add examples/ directory with complete configurations
  - examples/npm/ - Complete setup for npm publishing
  - examples/docker-hub/ - Complete setup for Docker Hub
  - examples/custom-registry/ - Template showing pattern to follow
- [ ] Document the substitution pattern
  - Identify the 3 key places to change (envrc, justfile, workflow)
  - Provide checklist for swapping registries
  - Show before/after for switching from GCP to another registry
- [ ] Optional: Add registry provider comments to current implementation
  - Add clear markers in justfile showing "REGISTRY PROVIDER: GCP"
  - Comments explaining what each section does
  - Make it obvious what needs changing
