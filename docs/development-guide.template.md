# Development Guide

> Developer onboarding and workflow guide for {{PROJECT_NAME}}

## Getting Started

### Prerequisites

Before you begin, ensure you have the following installed:

- **Git** - Version control
- **mise** - Tool and task runner ([installation](https://mise.jdx.dev/getting-started.html))
- **Docker** - Container runtime (optional, for containerized development)

### Initial Setup

1. **Clone the repository**:
   ```bash
   git clone https://github.com/YOUR-ORG/{{PROJECT_NAME}}.git
   cd {{PROJECT_NAME}}
   ```

2. **Install tools**:
   ```bash
   mise install
   mise run install
   ```

   `mise install` installs all tools declared in `mise.toml` (node, shellcheck, shfmt, gcloud, docker-cli, claude, etc.).
   `mise run install` installs npm dependencies (semantic-release and plugins).

3. **Verify installation**:
   ```bash
   mise --version
   docker --version  # if installed
   echo $PROJECT
   echo $VERSION
   ```

## Development Workflow

### Commands

Common commands using `mise run`:

```bash
# List all available tasks
mise tasks

# Build the project
mise run build

# Run locally
mise run run

# Run tests
mise run test

# Format code
mise run format

# Lint code
mise run lint

# Clean build artifacts
mise run dev:clean
```

### Making Changes

1. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes**:
   - Write code
   - Add tests
   - Update documentation

3. **Test your changes**:
   ```bash
   mise run test
   mise run lint
   mise run format-check
   ```

4. **Commit using conventional commits**:
   ```bash
   # Feature
   git commit -m "feat: add new capability"

   # Bug fix
   git commit -m "fix: resolve issue with X"

   # Documentation
   git commit -m "docs: update README"

   # Refactoring
   git commit -m "refactor: restructure component Y"
   ```

5. **Push and create pull request**:
   ```bash
   git push -u origin feature/your-feature-name
   ```

### Pull Request Process

1. **Open PR** on GitHub
2. **Ensure CI passes**:
   - All tests pass
   - Code is formatted
   - No linting errors
3. **Request review** from team members
4. **Address feedback** and push updates
5. **Merge** when approved

## Project Structure

```
{{PROJECT_NAME}}/
├── .github/           # GitHub Actions workflows
├── .claude/           # AI assistant configuration
├── .mise-tasks/       # File-based mise tasks (bash scripts)
├── docs/              # Documentation
├── src/               # Source code
├── mise.toml          # Tools, env vars, and task definitions
├── Dockerfile         # Container definition
└── README.md          # Project overview
```

## Development Environment

### Using Docker

Development container for consistent environment:

```bash
# Build dev container
docker compose build dev

# Run in container
docker compose run --rm dev bash

# Inside container
mise run build
mise run test
```

### Using Dev Containers

If using VS Code:

1. Install "Dev Containers" extension
2. Open project in VS Code
3. Click "Reopen in Container" when prompted
4. Develop inside container with all tools pre-installed

## Testing

### Running Tests

```bash
# Run all tests
mise run test

# Run specific test file (TODO: Adjust based on test framework)
mise run test path/to/test_file

# Run with coverage (TODO: Add coverage support)
mise run test-coverage
```

### Writing Tests

TODO: Add language-specific testing guidelines

Example test structure:

```
test/
├── unit/         # Unit tests
├── integration/  # Integration tests
└── e2e/          # End-to-end tests
```

### Test Template

For template development:

```bash
# Run template tests
mise run test-template
```

## Code Style

### Formatting

Code should be formatted before committing:

```bash
# Format all files
mise run format

# Check formatting without changing files
mise run format-check
```

### Linting

Run linters to catch issues:

```bash
# Run all linters
mise run lint

# Auto-fix linting issues (if available)
mise run lint-fix
```

### Best Practices

- Write clear, descriptive variable and function names
- Add comments for complex logic
- Keep functions small and focused
- Write tests for new features
- Update documentation when changing behavior

## Debugging

### Local Debugging

TODO: Add language-specific debugging instructions

### Container Debugging

```bash
# Run container with interactive shell
docker compose run --rm dev bash

# Attach to running container
docker exec -it {{PROJECT_NAME}}-dev bash
```

### Common Issues

#### Build failures

```bash
# Clean and rebuild
mise run dev:clean
mise run build
```

## AI-Assisted Development

This project uses Claude Code for AI-assisted development:

```bash
# Install Claude CLI (if not already installed)
npm install -g @anthropic-ai/claude-cli

# Verify installation
claude --version
```

### Claude Code Commands

Custom commands available in `.claude/commands/`:

```bash
# List available commands
ls .claude/commands/

# Use a command (in Claude Code CLI)
/command-name
```

## Versioning

This project uses semantic versioning (SemVer):

- **Major** (1.0.0): Breaking changes
- **Minor** (0.1.0): New features (backwards compatible)
- **Patch** (0.0.1): Bug fixes

Versions are determined automatically by semantic-release based on commit messages.

### Version Management

```bash
# Check current version
mise run version

# Preview next version (dry-run)
mise run version-next
```

## Contributing Guidelines

### Code Review

- Be respectful and constructive
- Explain reasoning behind suggestions
- Approve when changes look good

### Documentation

- Update docs with code changes
- Keep README current
- Document new features
- Add ADRs for significant decisions

### Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```bash
# Format
<type>(<scope>): <description>

[optional body]

[optional footer]
```

**Types**:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `style`: Formatting (no code change)
- `refactor`: Code change (no feature/fix)
- `perf`: Performance improvement
- `test`: Adding/updating tests
- `chore`: Maintenance tasks

## Resources

### Documentation

- [Architecture Guide](./architecture.md)
- [User Guide](./user-guide.md)
- [Infrastructure Guide](./infrastructure.md)

### External Resources

TODO: Add links to relevant external resources:
- Language-specific docs
- Framework documentation
- API references

### Getting Help

- **Issues**: File a GitHub issue
- **Discussions**: Use GitHub Discussions
- **Chat**: TODO: Add team chat link

---

**Template**: {{TEMPLATE_NAME}} v{{TEMPLATE_VERSION}}
