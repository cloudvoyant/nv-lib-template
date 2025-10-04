# Common Task Templates

## Creating a Bash Script

1. Create `scripts/<name>.sh`
2. Add shebang and DOCUMENTATION heredoc
3. Source utils: `source "${SCRIPT_DIR}/utils.sh"`
4. Add error handling: `setup_script_lifecycle`
5. Implement `show_help()` function
6. Implement `main()` with argument parsing
7. Call `main "$@"`
8. Update plan.md checkbox

## Adding a Justfile Recipe

1. Determine if needs `_load` dependency
2. Add recipe with description comment
3. Use `@` for silent execution if needed
4. Use `{{ARGS}}` for parameters
5. Keep TODO placeholder if not implemented
6. Update plan.md checkbox

## Creating Documentation

1. Create file in `docs/` directory
2. Use clear markdown structure
3. Include code examples
4. Link from README.md if top-level doc
5. Update plan.md checkbox

## Updating Configuration

1. Edit `.envrc` for environment variables
2. Edit `.releaserc.json` for semantic-release
3. Edit `justfile` for commands
4. Test changes locally
5. Update plan.md checkbox
