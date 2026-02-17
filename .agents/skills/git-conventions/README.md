# Git Conventions Skill for Claude Code

This skill teaches Claude Code to help you write perfect Git commit messages and maintain atomic commits following Conventional Commits specification.

## What This Skill Does

When you ask Claude Code about Git, commits, or version control, this skill automatically guides it to:

- ✅ Write commit messages following Conventional Commits specification
- ✅ Use correct types: `feat`, `fix`, `docs`, `style`, `refactor`, etc.
- ✅ Apply proper scopes (package/module names)
- ✅ Use imperative mood, lowercase, no period
- ✅ Help you create atomic commits (one logical change per commit)
- ✅ Guide you through interactive staging with `git add -p`
- ✅ Help clean up commit history with interactive rebase
- ✅ Handle breaking changes correctly with `!` indicator

## Installation

### For Personal Use (All Projects)

Copy this skill to your personal skills directory:

```bash
# Create the directory if it doesn't exist
mkdir -p ~/.claude/skills

# Copy the skill folder
cp -r git-conventions-skill ~/.claude/skills/git-conventions
```

### For Project-Specific Use

Copy to your project's skills directory:

```bash
# In your project root
mkdir -p .claude/skills
cp -r git-conventions-skill .claude/skills/git-conventions
```

### For Enterprise/Team Use

Your organization admin can install this in the shared enterprise skills location for all team members.

## Usage

### Automatic Invocation

Claude Code automatically uses this skill when you ask Git-related questions:

```
"Help me write a commit message for this authentication feature"
"How should I commit these changes atomically?"
"Review my commit message for best practices"
"How do I split this large commit into smaller ones?"
"What's the right commit type for a performance improvement?"
```

### Manual Invocation

You can explicitly invoke the skill with a slash command:

```
/git-conventions - write a commit message for adding JWT authentication
```

### Example Prompts

**Writing commit messages:**
```
Help me write a commit message for adding user authentication with OAuth2
```

**Reviewing commits:**
```
Review this commit message: "feat(auth): Added JWT support"
```

**Breaking changes:**
```
I'm removing a deprecated API endpoint. How should I format the commit message?
```

**Atomic commits:**
```
I fixed a bug and added a feature in the same file. How should I commit this?
```

**Interactive staging:**
```
Walk me through using git add -p to separate my changes into atomic commits
```

**Cleaning history:**
```
My feature branch has messy commits with "WIP" and typo fixes. Help me clean it up
```

## What's Included

```
git-conventions/
├── SKILL.md                           # Main skill file with all guidelines
├── CHECKLIST.md                       # Quick reference checklist
├── README.md                          # This file
└── examples/
    ├── commit-messages.md             # Good and bad commit examples
    └── atomic-workflows.md            # Practical atomic commit workflows
```

## Key Conventions Enforced

### Commit Message Format
```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Commit Types
- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation only
- `style` - Formatting, whitespace
- `refactor` - Code restructuring
- `perf` - Performance improvement
- `test` - Adding/updating tests
- `build` - Build system, dependencies
- `ci` - CI configuration
- `chore` - Maintenance
- `revert` - Revert previous commit

### Message Rules
- **Imperative mood:** "add" not "added"
- **Lowercase:** "add feature" not "Add feature"
- **No period:** "add feature" not "add feature."
- **Concise:** Under 72 characters preferred

### Atomic Commits
- One logical change per commit
- Each commit must compile and pass tests
- Separate formatting from logic changes
- Separate file moves from content changes
- Use `git add -p` for fine-grained staging

## Examples

### Simple Feature
```
feat(auth): add JWT token validation
```

### Bug Fix with Context
```
fix(parser): prevent crash on empty input

Add validation to return error instead of panicking
when input string is empty.

Closes #234
```

### Breaking Change
```
feat(api)!: remove deprecated status endpoint

BREAKING CHANGE: The /api/status endpoint has been removed.
Use /api/health instead.

Migration guide: docs/api/migration.md
```

### Refactoring
```
refactor(db): extract connection pool logic

Move connection pool from main.rs to db/pool.rs to
improve code organization. No behavior changes.
```

## Common Scenarios

### Scenario 1: Mixed Changes in One File

**Problem:** You fixed a bug and added a feature in the same file.

**Solution:**
```bash
# Use interactive staging
git add -p src/api.rs

# Stage only bug fix chunks (select 'y')
git commit -m "fix(api): validate empty request body"

# Stage feature chunks
git add -p src/api.rs
git commit -m "feat(api): add rate limiting"
```

### Scenario 2: Messy Commit History

**Problem:** Your branch has commits like "WIP", "fix typo", "oops forgot file".

**Solution:**
```bash
# Interactive rebase
git rebase -i main

# Use fixup/squash to combine commits
# Use reword to fix commit messages
# Use drop to remove unnecessary commits
```

### Scenario 3: Wrong Commit Message

**Problem:** You just committed but the message has a typo or wrong type.

**Solution:**
```bash
# Amend the last commit
git commit --amend -m "fix(auth): prevent token replay attacks"
```

### Scenario 4: Committed to Wrong Branch

**Problem:** You made commits on `main` instead of a feature branch.

**Solution:**
```bash
# Create branch from current HEAD
git branch feat/my-feature

# Reset main to before your commits
git reset --hard origin/main

# Switch to feature branch
git checkout feat/my-feature
```

## Verification

To verify the skill is installed correctly:

```bash
# Check that the skill exists
ls ~/.claude/skills/git-conventions/SKILL.md

# Start Claude Code
claude-code

# Ask: "What Git commit conventions should I follow?"
# Claude should reference the Conventional Commits guidelines
```

## Customization

You can customize this skill by editing `SKILL.md`:

1. Add company-specific commit types
2. Adjust scope conventions for your monorepo structure
3. Add project-specific examples
4. Modify breaking change policies

## Git Configuration

### Commit Message Template

You can set up a Git commit message template to help remember the format:

```bash
# Create template
cat > ~/.gitmessage << 'EOF'
# <type>[optional scope]: <description>
# 
# [optional body]
# 
# [optional footer(s)]
#
# Types: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert
# 
# Rules:
#   - Use imperative mood ("add" not "added")
#   - No capital letter
#   - No period at the end
#   - Keep description under 72 characters
EOF

# Configure Git to use it
git config --global commit.template ~/.gitmessage
```

### Commit Message Hooks

Install a pre-commit hook to validate commit messages:

```bash
# In your repo
cat > .git/hooks/commit-msg << 'EOF'
#!/bin/bash
commit_msg=$(cat "$1")
commit_regex='^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\(.+\))?!?: .+$'

if ! echo "$commit_msg" | grep -qE "$commit_regex"; then
    echo "ERROR: Commit message doesn't follow Conventional Commits format"
    echo "Format: <type>[scope]: <description>"
    echo "Example: feat(auth): add OAuth2 support"
    exit 1
fi
EOF

chmod +x .git/hooks/commit-msg
```

## Troubleshooting

**Skill not being invoked?**
- Check that `SKILL.md` has proper YAML frontmatter
- Verify the file is in the correct directory
- Restart Claude Code

**Want to update the skill?**
- Edit the `SKILL.md` file
- Changes take effect immediately

**Need help with specific Git scenarios?**
- Check `examples/atomic-workflows.md` for detailed workflows
- Check `examples/commit-messages.md` for message examples
- Ask Claude: "Help me with [specific scenario]"

## Integration with CI/CD

Many teams enforce commit message format in CI. This skill helps you write compliant messages from the start.

**Example GitHub Action:**
```yaml
# .github/workflows/commit-lint.yml
name: Commit Lint
on: [pull_request]
jobs:
  commitlint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0
      - uses: wagoid/commitlint-github-action@v5
```

**Example commitlint config:**
```js
// commitlint.config.js
module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'type-enum': [2, 'always', [
      'feat', 'fix', 'docs', 'style', 'refactor',
      'perf', 'test', 'build', 'ci', 'chore', 'revert'
    ]]
  }
};
```

## Resources

- [Conventional Commits Specification](https://www.conventionalcommits.org/)
- [Pro Git Book](https://git-scm.com/book/en/v2)
- [Git Interactive Rebase](https://git-scm.com/docs/git-rebase#_interactive_mode)
- [Atomic Commits Guide](https://www.freshconsulting.com/insights/blog/atomic-commits/)

## Benefits of This Approach

### For You
- ✅ Consistent, professional commit history
- ✅ Easy to find specific changes
- ✅ Simpler code reviews
- ✅ Easier to revert changes
- ✅ Better debugging with `git bisect`

### For Your Team
- ✅ Clear project history
- ✅ Automated changelog generation
- ✅ Easier to onboard new developers
- ✅ Better collaboration
- ✅ Compliance with CI/CD requirements

### For Your Project
- ✅ Professional appearance
- ✅ Easier maintenance
- ✅ Better release management
- ✅ Improved documentation
- ✅ Clearer project evolution

## Contributing

If you find issues or have improvements:

1. Update `SKILL.md` with your changes
2. Add examples to the `examples/` directory
3. Update `CHECKLIST.md` with new checks
4. Test with Claude Code to ensure guidelines work

## License

These guidelines are based on the Conventional Commits specification and common Git best practices. Feel free to adapt them for your team's needs.

---

**Happy committing! 🎯**

Remember: Good commits are a gift to your future self and your teammates.
