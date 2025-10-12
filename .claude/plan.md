# Improvement Plan

## Overview

Three major improvements to simplify the platform and make it more flexible:

1. **Consolidate setup scripts** - Merge platform-install.sh into setup.sh with clearer flag semantics
2. **Generalize versioning pipeline** - Extract semantic-release logic to make it easy to swap versioning tools
3. **Separate registry configuration** - Move registry variables to .env.registry for cleaner separation

---

## 1. Consolidate Setup Scripts

### Current State

- `scripts/setup.sh` - Installs system dependencies with `--include-optional` flag
  - Required: bash, just, direnv
  - Optional (with flag): docker, node/npx, shellcheck, shfmt
- `scripts/platform-install.sh` - Separate script for platform development (bats-core)

### Problems

- Two separate scripts is confusing
- `--include-optional` is vague - optional for what purpose?
- No clear distinction between dev, CI, and platform needs

### Proposed Changes

**Merge platform-install.sh into setup.sh with semantic flags:**

```bash
scripts/setup.sh               # Required only (bash, just, direnv)
scripts/setup.sh --dev         # + Development tools (shellcheck, shfmt, docker, node/npx)
scripts/setup.sh --ci          # + CI essentials (docker, node/npx) - minimal for CI
scripts/setup.sh --platform    # + Platform development (bats-core)
```

**Can combine flags:**
```bash
scripts/setup.sh --dev --platform    # All development + platform tools
```

**Flag semantics:**
- `--dev` - Local development environment (linters, formatters, containers)
- `--ci` - Minimal CI environment (just what CI needs to run)
- `--platform` - Platform maintainer tools (testing infrastructure)

### Implementation Steps

1. **Update scripts/setup.sh**
   - Replace `--include-optional` with `--dev`, `--ci`, `--platform` flags
   - Move bats-core installation from platform-install.sh
   - Add logic to handle flag combinations:
     - `--dev` installs: docker, node/npx, shellcheck, shfmt
     - `--ci` installs: docker, node/npx (no linters/formatters)
     - `--platform` installs: bats-core
     - No flags: just required (bash, just, direnv)

2. **Update justfile**
   - Remove `platform-install` recipe (no longer needed)
   - Update `setup` recipe comment:
     ```just
     # Setup development environment
     # Flags: --dev (development tools), --ci (CI essentials), --platform (platform dev)
     setup *ARGS: _load
         @bash scripts/setup.sh {{ARGS}}
     ```

3. **Delete scripts/platform-install.sh**

4. **Update documentation**
   - docs/user-guide.md - Update setup section with new flags
   - docs/architecture.md - Remove platform-install.sh references
   - README.md - Update quick start with flag examples

5. **Update tests**
   - test/scaffold.bats - Update assertions for platform file cleanup

6. **Update CI workflows**
   - .github/workflows/ci.yml - Use `just setup --ci` instead of `just setup --include-optional`
   - .github/workflows/release.yml - Use `just setup --ci` instead of `just setup --include-optional`

---

## 2. Generalize Versioning Pipeline

### Current State

- `.github/workflows/release.yml` has semantic-release logic embedded directly
- Hard to customize for different languages
- Users must edit workflow YAML to configure language-specific plugins

### Problems

- Semantic-release is embedded in CI workflow
- Not clear how to configure language-specific plugins:
  - Python: @semantic-release/exec with setuptools
  - Go: @semantic-release/exec with go modules
  - Rust: @semantic-release/exec with cargo
  - Node: @semantic-release/npm (default)
- Users must understand GitHub Actions YAML to customize

### Proposed Changes

**Extract versioning logic to scripts/upversion.sh:**

```bash
scripts/upversion.sh
├── Wraps semantic-release with consistent interface
├── Analyzes commits since last release
├── Determines next version using semantic-release
├── Updates CHANGELOG.md
├── Creates git tag
├── Pushes tag to remote
└── Outputs: new_release_published=true/false, new_release_version=X.Y.Z
```

**Add just command:**
```just
# Analyze commits and create new version if needed
upversion: _load
    @bash scripts/upversion.sh
```

**Simplified release.yml workflow:**
```yaml
- name: Create new version
  id: upversion
  run: just upversion

- name: Publish package
  if: steps.upversion.outputs.new_release_published == 'true'
  run: just publish
```

### Benefits

1. **Easy to customize** - Edit one bash script instead of YAML
2. **Testable locally** - Run `just upversion` to test versioning
3. **Clear separation** - Version creation vs publishing
4. **Language-specific** - Document semantic-release plugins for each language

### Implementation Steps

1. **Create scripts/upversion.sh**
   - Extract semantic-release logic from release.yml
   - Add environment variable exports for GitHub Actions:
     ```bash
     echo "new_release_published=true" >> $GITHUB_OUTPUT
     echo "new_release_version=${VERSION}" >> $GITHUB_OUTPUT
     ```
   - Support both CI (with $GITHUB_OUTPUT) and local modes
   - Wraps `npx semantic-release` with consistent interface
   - Include comments documenting language-specific plugins:
     ```bash
     # LANGUAGE-SPECIFIC PLUGINS:
     # Configure in .releaserc.json or package.json

     # Python: Update version in setup.py/pyproject.toml
     # npm install --save-dev @semantic-release/exec
     # Add to .releaserc.json:
     #   "plugins": [
     #     ["@semantic-release/exec", {
     #       "prepareCmd": "sed -i 's/version=\".*\"/version=\"${nextRelease.version}\"/' setup.py"
     #     }]
     #   ]

     # Go: Update version in go.mod or version file
     # Similar @semantic-release/exec configuration

     # Rust: Update Cargo.toml version
     # Similar @semantic-release/exec configuration

     # Node: Uses @semantic-release/npm by default
     ```

2. **Add upversion recipe to justfile**
   ```just
   # Create new version based on commits (semantic-release)
   upversion: _load
       @bash scripts/upversion.sh
   ```

3. **Update .github/workflows/release.yml**
   - Replace semantic-release action with `just upversion`
   - Use outputs from upversion.sh for conditional publishing
   - Simplify workflow logic

4. **Update documentation**
   - docs/architecture.md - Document upversion.sh and customization
   - docs/design.md - Update versioning section
   - docs/user-guide.md - Add section on customizing versioning
   - Add examples for different languages in docs/

5. **Update tests**
   - Add platform tests for upversion.sh in test/upversion.bats
   - Test both CI and local modes
   - Test output format

6. **Create migration guide**
   - docs/migrations/1.2.0-to-1.3.0.md
   - Document setup.sh flag changes
   - Document new upversion workflow

---

## 3. Separate Registry Configuration

### Current State

Registry-specific variables are mixed with project variables in `.envrc`:

```bash
export PROJECT=platform-lib
export VERSION=0.0.1
export GCP_PROJECT_ID=your-project-id
export GCP_REGION=us-central1
export GCP_REPOSITORY=your-repository
```

### Problems

- Registry configuration mixed with project configuration
- No clear separation of concerns
- Makes it unclear which variables are for what purpose

### Proposed Changes

**Create .env.registry.example with GCP defaults:**

```bash
# Registry Configuration
# Copy this file to .env.registry and configure for your target registry

# GCP Artifact Registry (default example)
export GCP_PROJECT_ID=your-project-id
export GCP_REGION=us-central1
export GCP_REPOSITORY=your-repository

# To use a different registry, replace the above with your registry configuration:
# npm: export NPM_REGISTRY=https://registry.npmjs.org
# PyPI: export PYPI_REPOSITORY=pypi
# Docker: export DOCKER_REGISTRY=docker.io
```

**Update .envrc to source .env.registry:**

```bash
export PROJECT=platform-lib
export VERSION=0.0.1

# Load registry configuration if available
if [ -f .env.registry ]; then
    source .env.registry
fi
```

**Update justfile:**

The `_load` recipe already sources .envrc, which will now source .env.registry, so no changes needed.

**Update .gitignore:**

```gitignore
# Registry configuration (contains sensitive values)
.env.registry
```

Note: `.env.registry.example` is tracked, `.env.registry` is ignored.

### Benefits

1. **Clear separation** - Project config in .envrc, registry config in .env.registry
2. **Cleaner .envrc** - Focused on project-level variables only
3. **Easy to customize** - Copy example file and configure
4. **Secure** - Actual .env.registry with secrets is gitignored
5. **GCP still default** - Example shows GCP setup, no breaking changes

### Implementation Steps

1. **Create .env.registry.example**
   - Add GCP variables with placeholder values
   - Include comments for other registry options
   - Commit to git (tracked)

2. **Update .envrc**
   - Remove GCP variables
   - Add conditional source of .env.registry
   - Keep only PROJECT and VERSION

3. **Update .gitignore**
   - Add `.env.registry` to ignore list
   - Ensure .env.registry.example is NOT ignored

4. **Update documentation**
   - docs/architecture.md - Document .env.registry pattern and setup
   - docs/design.md - Update environment variables section
   - docs/user-guide.md - Add registry configuration section with copy command
   - README.md - Add setup step: `cp .env.registry.example .env.registry`

5. **Update tests**
   - test/scaffold.bats - Verify .env.registry.example exists after scaffolding
   - Verify .env.registry is in .gitignore
   - Verify .envrc sources .env.registry
   - Verify .envrc doesn't contain GCP variables

6. **Update scaffold.sh**
   - Copy .env.registry.example to .env.registry

---

## Testing Plan

### Setup Script Changes

```bash
# Test required only
just setup
command -v bash && command -v just && command -v direnv

# Test dev
just setup --dev
command -v shellcheck && command -v shfmt && command -v docker

# Test CI
just setup --ci
command -v docker && command -v npx

# Test platform
just setup --platform
command -v bats

# Test combination
just setup --dev --platform
command -v bats && command -v shellcheck
```

### Upversion Changes

```bash
# Test locally
just upversion
# Should analyze commits, update version, create tag

# Test in CI
# GitHub Actions workflow should run and publish if version created
```

### Platform Tests

```bash
# Run all platform tests
just platform-test

# Should pass with new setup.sh structure
```

---

## Migration Strategy

### For Existing Projects

Scaffolded projects don't include platform-install.sh, so minimal impact:

1. Update to use `--dev` instead of `--include-optional` in documentation
2. Update CI workflows to use `--ci` flag
3. Adopt scripts/upversion.sh for custom versioning (optional)

### For Platform Repository

1. Merge platform-install.sh into setup.sh
2. Create scripts/upversion.sh with semantic-release logic
3. Update all documentation
4. Create migration guide
5. Test thoroughly with platform tests
6. Release as v1.3.0

---

## Timeline

### Phase 1: Setup Script Consolidation
- Implement setup.sh flag changes
- Update documentation
- Update tests
- **Estimated: 2-3 hours**

### Phase 2: Versioning Generalization
- Create upversion.sh
- Update release.yml workflow
- Add tests
- Document customization
- **Estimated: 3-4 hours**

### Phase 3: Separate Registry Configuration
- Create .env.registry.example
- Update .envrc to source .env.registry
- Update .gitignore
- Update scaffold.sh to copy example file
- Update documentation
- **Estimated: 1-2 hours**

### Phase 4: Testing & Documentation
- Run platform tests
- Update all documentation
- Create migration guide
- **Estimated: 2-3 hours**

**Total estimated time: 8-12 hours**

---

## Success Criteria

- ✅ scripts/platform-install.sh deleted
- ✅ scripts/setup.sh supports --dev, --ci, --platform flags
- ✅ scripts/upversion.sh created and tested
- ✅ release.yml simplified and uses upversion.sh
- ✅ .env.registry.example created with GCP defaults
- ✅ .env.registry added to .gitignore
- ✅ .envrc updated to source .env.registry (no GCP vars)
- ✅ scaffold.sh copies .env.registry.example to .env.registry
- ✅ All platform tests pass
- ✅ Documentation updated
- ✅ Migration guide created
- ✅ CI workflows updated to use new flags

---

## Questions for User

1. **Flag naming**: Happy with `--dev`, `--ci`, `--platform`? Any alternatives?
2. **upversion.sh outputs**: Should it support different output formats (JSON, env vars)?
3. **Language examples**: Which language-specific semantic-release plugins should we document? (Python, Go, Rust, others?)
4. **Registry examples**: Should .env.registry.example include more registry examples beyond GCP (npm, PyPI, Docker)?
5. **Migration**: Should this be v1.3.0 or wait for more changes?
