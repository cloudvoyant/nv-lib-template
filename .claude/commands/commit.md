Create a git commit following conventional commit standards with a professional, concise message.

## Workflow

### Step 1: Check Git Status

Run these commands in parallel to understand what's being committed:

```bash
git status
git diff
git log --oneline -5
```

Analyze:
- What files changed (from git status)
- What the changes do (from git diff)
- Recent commit message style (from git log)

### Step 2: Draft Commit Message

Create a conventional commit message following this format:

```
<type>: <short description>

[optional body paragraph explaining why, not what]
```

**Type must be one of:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `refactor`: Code refactoring (no functionality change)
- `test`: Test additions or changes
- `chore`: Build, CI, or tooling changes
- `perf`: Performance improvements
- `style`: Code style/formatting (not docs style)

**Rules:**
- First line max 72 characters
- Use imperative mood: "add feature" not "added feature" or "adds feature"
- No period at end of first line
- Be professional and concise
- Do NOT include self-attribution (no "Generated with Claude Code", no "Co-Authored-By: Claude")
- Body is optional - only add if the "why" isn't obvious from the type and description
- Keep body lines under 72 characters

**Examples:**

Good:
```
docs: remove bold formatting from markdown headings

Improves readability by using plain text for structural elements
and reserving bold for emphasis within content.
```

```
feat: add user authentication with JWT
```

```
fix: prevent memory leak in connection pool
```

Bad:
```
Update documentation files and also added new commit command
```
(Too long, mixed changes, wrong mood)

```
docs: updated the markdown files to make them look better

I went through all the markdown files and removed the bold formatting
from the headings because it looks better in code editors.

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```
(Casual tone, self-attribution, obvious explanation)

### Step 3: Review with User

Show the proposed commit message and ask: "Does this commit message look good?"

Wait for:
- Approval: Proceed to Step 4
- Changes requested: Revise and show again
- Cancel: Exit without committing

### Step 4: Stage and Commit

Stage all changes and create the commit:

```bash
git add -A
git commit -m "$(cat <<'EOF'
<type>: <description>

[optional body]
EOF
)"
```

Always use HEREDOC format for commit messages to ensure proper formatting.

### Step 5: Confirm

Report success:
```
Commit created successfully!

Run 'git log -1' to view the commit.
```

## Guidelines

**Scope of changes:**
- If changes span multiple types (docs + feat), ask user which to prioritize or suggest splitting into multiple commits
- Avoid mixing unrelated changes in one commit

**Breaking changes:**
- If breaking change, use `!` after type: `feat!: redesign API`
- Or add `BREAKING CHANGE:` in body footer

**Commit frequently:**
- Small, focused commits are better than large ones
- Each commit should be a logical unit of change

**Never commit:**
- Secrets or credentials (.env files, API keys, passwords)
- Warn user if such files are staged

## Notes

- This command follows conventional commits specification
- Keeps messages professional and concise
- No self-attribution or branding
- Focus on what changed and why, not who made the change
