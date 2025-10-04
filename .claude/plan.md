# Language-Agnostic Build System - Implementation Plan

## Mission

Build a **language-agnostic build system** that can be easily forked and extended for any programming language or SDK project.

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

- [x] **Release on Merge** (`release.yml`)

  - Trigger on merge to main
  - Run semantic-release to analyze commits
  - Determine version and create git tag
  - Update VERSION file and CHANGELOG.md

- [x] **Publish on Tag** (`publish.yml`)
  - Trigger on tag creation
  - Build production artifacts
  - Publish package to registry
  - Create GitHub release with notes

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

### Phase 8: GCP Artifact Publishing

**GCP Artifact Registry Integration**

- [ ] Add justfile recipe for GCP artifact publishing
- [ ] Script for authenticating with GCP (gcloud auth)
- [ ] Docker image build and push to GCP Artifact Registry
- [ ] Generic artifact upload (tarballs, binaries, etc.)
- [ ] GitHub Actions workflow for automated GCP publishing
- [ ] Documentation for GCP setup and configuration
- [ ] Environment variable configuration (.envrc updates)

### Phase 9: Project Scaffolding

**Scaffold Script** (`scripts/scaffold.sh`)

- [ ] Interactive prompts for project details (name, description, etc.)
- [ ] String replacement in template files:
  - Replace `{{PROJECT}}` with user's project name
  - Update `.envrc` with new project name
- [ ] Reset `.claude/` directory:
  - Remove `plan.md` (this implementation plan)
  - Optionally keep empty .claude/ for user's own AI context
- [ ] Initialize git history:
  - Option to squash/reset commit history
  - Create initial commit with scaffolded project
- [ ] Non-interactive mode for automation
- [ ] Validation of inputs (project name format, etc.)
