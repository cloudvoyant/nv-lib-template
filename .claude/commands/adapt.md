Help me adapt this template to my project's specific needs using a spec-driven approach.

## Overview

This workflow helps you customize the nv-lib-template for your specific use case by:
1. Understanding your requirements
2. Creating a comprehensive adaptation plan
3. Working through changes systematically
4. Testing and validating adaptations

## Steps

### 1. Understand Requirements

I'll ask you about:
- Project language and framework
- Build and test requirements
- Publishing targets (GCP, npm, Docker, etc.)
- CI/CD needs beyond SDK publishing? If so this template may not be fit for your needs.
- Additional tooling requirements

### 2. Create Adaptation Plan

I'll create `.claude/plan.md` with phases for:

```markdown
# Adaptation Plan: nv-lib-template → <your-project>

## Phase 1: Language Setup
- [ ] Update justfile build recipe for <language>
- [ ] Update justfile test recipe for <language>
- [ ] Add language-specific dependencies to setup.sh
- [ ] Update .gitignore for <language>

## Phase 2: Publishing
- [ ] Update publish recipe for <target>
- [ ] Configure registry authentication
- [ ] Notify users of any changes needed for GitHub action secrets

## Phase 3: Tooling
- [ ] Add <tool> configuration
- [ ] Update justfile recipes for <tool>
- [ ] Add <tool> to CI override scripts

## Phase 4: Documentation
- [ ] Update README.md with project specifics
- [ ] Update user-guide.md with custom workflows
- [ ] Document custom recipes in justfile
```

### 3. Work Through Plan

For each adaptation:
1. Review current implementation
2. Make necessary changes
3. Test changes work
4. Mark task complete
5. Move to next task

### 4. Validate Adaptations

```bash
# Test all changes work
just test

# Verify build works
just build

# Check CI would pass
just lint && just format-check && just test
```

### 5. Update Documentation

Update project docs to reflect customizations:
- `docs/architecture.md` - document custom design decisions
- `docs/user-guide.md` - explain custom workflows
- `README.md` - update with project specifics

### 6. Cleanup

```bash
# Archive or delete adaptation plan
mv .claude/plan.md .claude/adaptation-complete-$(date +%Y%m%d).md
```

## Best Practices

- Create plan before making changes
- Test after each significant adaptation
- Keep language-agnostic logic in `scripts/`
- Put language-specific logic in `justfile`
- Document why you made specific choices
- Update README.md to reflect customizations

## What to Keep vs Change

### Always Keep (core framework)
- `scripts/` - bash automation framework
- `.envrc` - environment variable management
- `.github/workflows/` - CI/CD structure
- `direnv` + `just` pattern

### Customize (language-specific)
- `justfile` recipes (build, test, run, publish)
- `.gitignore` patterns
- `docs/` content for your project
- `.envrc` for needed configuration
- Publishing targets and authentication

### Optional Additions
- Language-specific linters/formatters
- Additional CI checks
- Custom deployment scripts
- Development tooling