# Git Commit Checklist

Use this checklist before committing to ensure you follow conventions.

## ✅ Pre-Commit Checklist

### Code Quality
- [ ] Code compiles successfully (`cargo build` or equivalent)
- [ ] All tests pass (`cargo test` or equivalent)
- [ ] No linter warnings (`cargo clippy` or equivalent)
- [ ] Code is formatted (`cargo fmt` or equivalent)

### Commit Atomicity
- [ ] This commit does **one thing** only
- [ ] No mixed concerns (feature + bug fix, logic + formatting, etc.)
- [ ] If moving/renaming files, that's in a separate commit
- [ ] If reformatting code, that's in a separate commit
- [ ] Commit is small enough to review in 5-10 minutes

### Commit Message Format
- [ ] Follows format: `<type>[scope]: <description>`
- [ ] Type is one of: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`
- [ ] Scope is relevant (package/module name) or omitted
- [ ] Breaking change marked with `!` if applicable

### Description
- [ ] Uses imperative mood ("add" not "added", "fix" not "fixed")
- [ ] First letter is **lowercase** (not capitalized)
- [ ] No trailing period (.)
- [ ] Under 72 characters if possible
- [ ] Describes **what** changed, not **how**

### Body (if present)
- [ ] Blank line between description and body
- [ ] Explains **why** the change was needed
- [ ] Explains **what** changed from before
- [ ] Uses imperative mood
- [ ] Lines wrapped at 72 characters

### Footer (if present)
- [ ] Issue references use format: `Closes #123` or `Fixes #456`
- [ ] Breaking changes include `BREAKING CHANGE:` footer
- [ ] Breaking changes explain what broke and migration path

## 📝 Commit Type Quick Reference

| Type | Use When | Example |
|------|----------|---------|
| `feat` | Adding a new feature | `feat(auth): add OAuth2 support` |
| `fix` | Fixing a bug | `fix(parser): handle empty strings` |
| `docs` | Only documentation changes | `docs(api): update examples` |
| `style` | Code formatting, whitespace | `style: run rustfmt` |
| `refactor` | Restructuring without behavior change | `refactor(db): extract query builder` |
| `perf` | Performance improvement | `perf(cache): reduce allocations` |
| `test` | Adding or updating tests | `test(auth): add token validation tests` |
| `build` | Build system, dependencies | `build(deps): update tokio to 1.35` |
| `ci` | CI configuration changes | `ci: add security scanning` |
| `chore` | Maintenance tasks | `chore: update .gitignore` |
| `revert` | Reverting a previous commit | `revert: revert "feat(api): rate limit"` |

## 🚫 Common Mistakes to Avoid

### Message Format
- [ ] ❌ Don't capitalize first letter: ~~`feat(auth): Add support`~~
- [ ] ❌ Don't use past tense: ~~`feat(auth): added support`~~
- [ ] ❌ Don't add period at end: ~~`feat(auth): add support.`~~
- [ ] ❌ Don't be vague: ~~`fix: bug`~~
- [ ] ❌ Don't use issue numbers as scope: ~~`fix(#123): problem`~~

### Commit Content
- [ ] ❌ Don't mix feature and bug fix
- [ ] ❌ Don't mix logic changes and formatting
- [ ] ❌ Don't commit broken code
- [ ] ❌ Don't commit code that doesn't compile
- [ ] ❌ Don't commit failing tests (unless explicitly fixing)
- [ ] ❌ Don't commit commented-out code
- [ ] ❌ Don't commit debug statements or console logs

### Commit Size
- [ ] ❌ Don't commit 20 files at once
- [ ] ❌ Don't bundle multiple features in one commit
- [ ] ❌ Don't commit with message "WIP" or "temp" (clean up first)

## 🛠️ Pre-Commit Commands

Run these before committing:

```bash
# 1. Review what you're committing
git diff --staged

# 2. Verify code compiles
cargo build  # Or your build command

# 3. Run tests
cargo test   # Or your test command

# 4. Check formatting
cargo fmt -- --check

# 5. Check for linter warnings
cargo clippy -- -D warnings

# 6. Review commit message
git commit --dry-run
```

## 📋 Example Good Commits

**Feature:**
```
feat(auth): add JWT token validation

Implement Bearer token authentication with automatic
token refresh. Tokens expire after 15 minutes.
```

**Bug fix:**
```
fix(parser): prevent crash on malformed input

Add validation to return error instead of panicking
when input is missing required fields.

Closes #234
```

**Breaking change:**
```
feat(api)!: change error response format

BREAKING CHANGE: Error responses now use RFC 7807 format.
Update clients to handle new format.

Migration: docs/api/migration.md
```

**Refactoring:**
```
refactor(db): extract connection pool logic

Move connection pool from main.rs to db/pool.rs.
No behavior changes.
```

**Documentation:**
```
docs(api): add authentication examples

Add examples for Bearer token format and explain
token refresh flow.
```

## 🔄 Interactive Staging Workflow

Use this when you have mixed changes:

```bash
# 1. Start interactive staging
git add -p file.rs

# 2. For each hunk, choose:
#    y = stage this hunk
#    n = don't stage
#    s = split into smaller hunks
#    e = manually edit the hunk
#    q = quit

# 3. Review what's staged
git diff --staged

# 4. Commit
git commit -m "fix(parser): handle edge case"

# 5. Repeat for remaining changes
git add -p file.rs
git commit -m "feat(parser): add validation"
```

## 🧹 Pre-Push Checklist

Before pushing your branch:

- [ ] All commits follow conventions
- [ ] Each commit compiles and passes tests
- [ ] No "WIP", "temp", or "fixup" commits
- [ ] Commit messages are descriptive
- [ ] History is clean and logical
- [ ] No typo fix commits (squashed into feature commits)
- [ ] No merge commits (rebased instead)

### Clean Up History
```bash
# Interactive rebase to clean up
git rebase -i main

# Common operations:
# - fixup: squash typo fixes
# - reword: improve commit messages
# - drop: remove unnecessary commits
# - reorder: logical sequence

# Verify after rebase
cargo test
git log --oneline
```

## 🎯 Quick Decision Tree

**"Should I commit now?"**

```
Does code compile? ────NO───→ Fix it first
    │
    YES
    │
    ↓
Do tests pass? ────NO───→ Fix them first
    │
    YES
    │
    ↓
Is this one logical change? ────NO───→ Split with git add -p
    │
    YES
    │
    ↓
Is commit message correct? ────NO───→ Fix message
    │
    YES
    │
    ↓
✅ COMMIT!
```

## 🚀 Daily Workflow

### Start of Day
```bash
git checkout main
git pull --rebase
git checkout -b feat/my-feature
```

### During Development
```bash
# Make changes
vim src/file.rs

# Verify
cargo test

# Stage carefully
git add -p src/file.rs

# Commit atomically
git commit -m "feat(module): add functionality"

# Repeat
```

### End of Day / Before PR
```bash
# Review commits
git log --oneline

# Clean up if needed
git rebase -i main

# Verify still works
cargo test

# Push
git push origin feat/my-feature
```

## 📖 Helpful Git Commands

**Review changes:**
```bash
git status              # What's changed
git diff                # Unstaged changes
git diff --staged       # Staged changes
git log --oneline -10   # Recent commits
git log --graph         # Visual history
```

**Stage carefully:**
```bash
git add -p              # Interactive staging
git add -i              # Interactive menu
git reset HEAD file     # Unstage file
```

**Fix mistakes:**
```bash
git commit --amend      # Fix last commit
git reset HEAD~1        # Undo last commit, keep changes
git revert <commit>     # Create reverting commit
```

**Clean history:**
```bash
git rebase -i HEAD~N    # Interactive rebase last N commits
git rebase -i main      # Rebase onto main
```

## 🎓 Remember

**Good commits are:**
- ✅ Atomic (one logical change)
- ✅ Working (compiles and passes tests)
- ✅ Descriptive (clear message)
- ✅ Reviewable (small enough to understand)
- ✅ Revertable (can be undone independently)

**Bad commits are:**
- ❌ Mixed (multiple unrelated changes)
- ❌ Broken (doesn't compile or fails tests)
- ❌ Vague ("fix stuff", "update code")
- ❌ Massive (touches 50 files)
- ❌ Dependent (can't be reverted alone)

---

**Print this checklist and keep it visible while coding!**
