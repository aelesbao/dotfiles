---
name: git-conventions
description: Git commit message conventions and atomic commit practices. Use when writing commit messages, reviewing Git history, helping with version control workflows, creating commits, rebasing, squashing, or when the user asks about Git best practices, commit guidelines, or repository management.
---

# Git Conventions

Apply these Git conventions to maintain a clean, understandable, and maintainable project history.

## Conventional Commit Messages

All commit messages **must** follow the Conventional Commits specification.

### Commit Message Structure

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Example Commit Messages

**Simple commit:**
```
feat(auth): add JWT token validation
```

**With body:**
```
fix(api): prevent race condition in user creation

Add mutex lock around user creation logic to prevent
duplicate users from being created simultaneously.
```

**Breaking change:**
```
feat(api)!: remove deprecated status endpoint

BREAKING CHANGE: The /api/status endpoint has been removed.
Use /api/health instead.
```

**With issue reference:**
```
fix(parser): handle empty input strings

Closes #234
```

## Commit Types

Use these standardized types for all commits:

### `feat` - New Feature
A commit that introduces a new feature or capability.

**Examples:**
```
feat(user): add user profile editing
feat(api): implement GraphQL query endpoint
feat: add dark mode support
```

### `fix` - Bug Fix
A commit that fixes a defect or bug in the code.

**Examples:**
```
fix(auth): prevent token expiration edge case
fix(ui): correct button alignment on mobile
fix: resolve memory leak in worker thread
```

### `docs` - Documentation
Changes that only affect documentation (README, comments, guides).

**Examples:**
```
docs(api): update authentication examples
docs: add contributing guidelines
docs(readme): fix installation instructions
```

### `style` - Code Style
Changes that address code formatting, whitespace, indentation, or other style issues **without changing behavior**.

**Examples:**
```
style(parser): format with rustfmt
style: fix inconsistent indentation
style(api): organize imports alphabetically
```

### `refactor` - Code Refactoring
Commits that rewrite or restructure code **without altering external behavior**. No bug fixes, no new features.

**Examples:**
```
refactor(user): extract validation logic to separate function
refactor(db): simplify query builder implementation
refactor: replace nested if/else with match expression
```

### `perf` - Performance Improvement
A code change that improves performance.

**Examples:**
```
perf(parser): use zero-copy deserialization
perf(db): add index on frequently queried column
perf: reduce allocations in hot path
```

### `test` - Tests
Adding missing tests or correcting existing tests. No production code changes.

**Examples:**
```
test(auth): add tests for token refresh flow
test: add integration tests for user API
test(parser): cover edge cases in validation
```

### `build` - Build System
Changes that affect build components, dependencies, project version, compilation.

**Examples:**
```
build: upgrade tokio to 1.35.0
build(deps): update serde to 1.0.195
build: add release profile optimization flags
```

### `ci` - Continuous Integration
Changes to CI configuration files and scripts (GitHub Actions, GitLab CI, etc.).

**Examples:**
```
ci: add automated security scanning
ci(actions): run tests on pull requests
ci: configure cargo caching
```

### `chore` - Maintenance
Other changes that don't modify source or test files. General maintenance tasks.

**Examples:**
```
chore: update .gitignore
chore(deps): bump minor versions
chore: clean up unused files
```

### `revert` - Revert Previous Commit
Reverts a previous commit. Should reference the commit being reverted.

**Example:**
```
revert: revert "feat(api): add rate limiting"

This reverts commit a1b2c3d4.
```

## Scopes

The `scope` provides additional contextual information about what part of the codebase is affected.

### Scope Guidelines

- **Use the package or crate name** as the scope
  - Example: changes in crate `games/lilypad` → scope is `lilypad`
  - Example: `feat(lilypad): add new game mode`

- **Use module or component names** when appropriate
  - Example: `fix(auth): prevent token replay attacks`
  - Example: `refactor(parser): simplify error handling`

- **Do NOT use issue identifiers as scopes**
  - ❌ Bad: `fix(issue-123): resolve crash`
  - ✅ Good: `fix(api): resolve crash in request handler`

- **Scopes are optional** - omit when change is global or doesn't fit a specific scope
  - Example: `docs: update README`
  - Example: `chore: update license year`

### Common Scopes by Project Type

**Library/Framework:**
- `core`, `api`, `cli`, `docs`, `tests`

**Web Application:**
- `auth`, `ui`, `api`, `db`, `router`

**Rust Workspace:**
- Use crate names: `server`, `client`, `common`, `models`

## Breaking Changes

### Breaking Change Indicator

Commits that introduce breaking changes **must** be indicated with `!` before the `:`.

**Syntax:**
```
<type>(<scope>)!: <description>
```

**Examples:**
```
feat(api)!: remove status endpoint
refactor(auth)!: change token format
fix(parser)!: correct validation logic
```

### Breaking Change Footer

Breaking changes **should** be described in the footer section if the description isn't sufficiently detailed.

**Single-line footer:**
```
feat(api)!: remove deprecated endpoints

BREAKING CHANGE: The /v1/status and /v1/info endpoints have been removed. Use /v2/health instead.
```

**Multi-line footer:**
```
refactor(auth)!: redesign authentication flow

BREAKING CHANGE:

- Token format has changed from JWT to opaque tokens
- /auth/login now returns a refresh token
- Clients must implement token refresh logic
- Old tokens are invalid and must be re-issued
```

## Description

The description contains a concise summary of the change.

### Description Rules

**Mandatory:** The description is **required** for all commits.

**Imperative mood:** Use present tense, imperative form.
- ✅ "add feature"
- ✅ "fix bug"
- ✅ "update documentation"
- ❌ "added feature"
- ❌ "fixes bug"
- ❌ "updating documentation"

**Think:** "This commit will..." or "This commit should..."

**No capitalization:** Do **not** capitalize the first letter.
- ✅ `feat: add user login`
- ❌ `feat: Add user login`

**No period:** Do **not** end with a period (`.`).
- ✅ `fix: resolve memory leak`
- ❌ `fix: resolve memory leak.`

**Concise:** Keep it under 72 characters when possible.

### Good Description Examples

```
feat(auth): add OAuth2 provider support
fix(parser): handle malformed JSON gracefully
docs(api): clarify rate limiting behavior
refactor(db): extract connection pool to module
perf(query): optimize index usage
test(user): add edge cases for email validation
```

### Bad Description Examples

```
feat(auth): Added OAuth2 provider support.    # Capitalized, has period, wrong tense
fix: bug                                       # Too vague
FIX: Resolve memory leak                       # Capitalized type
feat: This commit adds user login              # Verbose, not imperative
```

## Body

The body should explain **why** the change was made and **what** the change does.

### Body Guidelines

**Optional:** The body is optional. Use it when the description alone isn't clear enough.

**Imperative mood:** Use present tense, just like the description.

**Motivation:** Explain the motivation for the change and contrast with previous behavior.

**Wrap lines:** Wrap body text at 72 characters for readability.

**Separate from description:** Leave **one blank line** between description and body.

### Body Examples

**Example 1 - Explaining a fix:**
```
fix(auth): prevent token replay attacks

Add nonce validation to prevent the same authentication token
from being used multiple times. Previous implementation only
checked token expiration, allowing replay attacks within the
valid time window.
```

**Example 2 - Explaining rationale:**
```
refactor(parser): switch from regex to manual parsing

Replace regex-based parsing with a hand-written parser to
improve performance by 10x and reduce binary size by 50KB.
The regex approach was too slow for large inputs and added
unnecessary dependencies.
```

**Example 3 - Describing implementation:**
```
feat(cache): add distributed cache support

Implement Redis-backed caching layer with automatic failover.
Cache entries expire after 5 minutes by default. If Redis is
unavailable, requests fall back to direct database queries
with a warning logged.
```

## Footer

The footer contains issue references and breaking change information.

### Footer Guidelines

**Optional:** Usually optional, **but mandatory** for breaking changes.

**Issue references:** Link to issue tracker entries.
- `Closes #123`
- `Fixes #456`
- `Resolves #789`
- `Refs #101112` (for reference without closing)

**Breaking changes:** Must start with `BREAKING CHANGE:`.

**Multiple footers:** Separate with blank lines.

### Footer Examples

**Simple issue reference:**
```
fix(api): validate request parameters

Closes #342
```

**Multiple issues:**
```
feat(auth): add multi-factor authentication

Closes #123
Closes #456
```

**Breaking change (single line):**
```
feat(api)!: redesign error response format

BREAKING CHANGE: Error responses now use RFC 7807 Problem Details format.
```

**Breaking change (multi-line):**
```
refactor(db)!: migrate to async database driver

BREAKING CHANGE:

All database methods are now async and must be awaited.
Update all calls to use `.await` syntax.

Migration guide: docs/migration/async-db.md

Closes #789
```

## Atomic Commits

Each commit must represent a **single, logical, and complete change**.

### Fundamental Principles

**One Thing Only:**
- A commit should do **one thing** only
- Examples: fix one bug, add one small feature, refactor one function

**Do Not Mix Concerns:**
- ❌ Never combine unrelated changes (e.g., bug fix + new feature)
- ❌ Don't mix formatting changes with logic changes
- ✅ Separate different types of work into different commits

**Keep It Small:**
- Smaller commits are easier to review
- Easier to test
- Easier to revert if needed
- If a feature is large, break it into incremental commits

**Must Compile and Pass Tests:**
- Every commit must leave code in a working state
- Must compile successfully
- Must pass all tests
- Broken intermediate commits make `git bisect` impossible

### Practical Examples

**❌ Bad - Mixed Concerns:**
```
feat: add user authentication and fix database connection bug

- Implement JWT authentication
- Add login endpoint
- Fix connection pool exhaustion
- Update documentation
```

**✅ Good - Atomic Commits:**
```
fix(db): prevent connection pool exhaustion
feat(auth): add JWT token generation
feat(auth): add login endpoint
docs(auth): document authentication flow
```

**❌ Bad - Too Large:**
```
feat: implement entire user management system

- Add user CRUD operations
- Add authentication
- Add authorization
- Add user profiles
- Add admin panel
```

**✅ Good - Incremental:**
```
feat(user): add user model and database schema
feat(user): implement user creation endpoint
feat(user): implement user retrieval endpoints
feat(user): add update and delete operations
feat(auth): add authentication middleware
feat(auth): add authorization checks
feat(profile): add user profile endpoints
feat(admin): add admin dashboard
```

## Practical Workflow

### Commit Often

Make commits as soon as you reach a **working state**.

- Don't wait until the end of the day
- Commit after each logical unit of work is complete
- It's easier to squash commits later than to split them

### Use `git add -p` for Staging

Use `git add --patch` to interactively stage specific changes:

```bash
git add -p file.rs
```

This allows you to:
- Split mixed changes in the same file into separate commits
- Review changes before staging
- Create atomic commits even when work isn't perfectly separated

**Example workflow:**
```bash
# You've modified file.rs with both a bug fix and a new feature

# Stage only the bug fix chunks
git add -p file.rs
# Select 'y' for bug fix hunks, 'n' for feature hunks

# Commit the bug fix
git commit -m "fix(parser): handle empty input"

# Stage the feature chunks
git add -p file.rs
# Select 'y' for remaining hunks

# Commit the feature
git commit -m "feat(parser): add validation rules"
```

### Separate Formatting Changes

**Always** commit formatting/style changes separately from functional changes.

**❌ Bad:**
```
feat(api): add rate limiting and format code

- Implement token bucket algorithm
- Run rustfmt on entire codebase
- Fix clippy warnings
```

**✅ Good:**
```
# First commit
style: format codebase with rustfmt

# Second commit
style: fix clippy warnings

# Third commit
feat(api): add rate limiting
```

### Separate Moves and Renames

When renaming or moving files, do it in a **dedicated commit**.

**❌ Bad:**
```
refactor: reorganize modules and update imports

- Move user.rs to models/user.rs
- Move auth.rs to services/auth.rs
- Update all imports
- Refactor user creation logic
```

**✅ Good:**
```
# First commit
refactor: move user.rs to models directory

# Second commit
refactor: move auth.rs to services directory

# Third commit
refactor(user): extract validation logic
```

This helps Git track renames properly and makes diffs clearer.

### Clean Up History Before Pushing

Use interactive rebase to organize commits before pushing:

```bash
# Rebase last 5 commits interactively
git rebase -i HEAD~5
```

**Common rebase operations:**
- `pick` - keep commit as-is
- `reword` - change commit message
- `edit` - amend commit content
- `squash` - merge with previous commit
- `fixup` - like squash but discard commit message
- `drop` - remove commit

**Example interactive rebase:**
```
pick a1b2c3d feat(user): add user model
fixup d4e5f6g fix typo in user model
pick g7h8i9j feat(user): add validation
reword j0k1l2m feat(api): add user endpoint
squash m3n4o5p add tests for user endpoint
```

**Typical workflow:**
```bash
# 1. Make commits as you work
git commit -m "feat(auth): add token validation"
git commit -m "fix typo"
git commit -m "add more validation"
git commit -m "fix another typo"

# 2. Before pushing, clean up
git rebase -i HEAD~4

# 3. Squash typo fixes into main commits
# Result: One clean "feat(auth): add token validation" commit

# 4. Push clean history
git push
```

## Common Workflows

### Feature Development

```bash
# 1. Create feature branch
git checkout -b feat/user-authentication

# 2. Work and commit atomically
git add src/auth/mod.rs
git commit -m "feat(auth): add authentication trait"

git add src/auth/jwt.rs
git commit -m "feat(auth): implement JWT provider"

git add tests/auth_tests.rs
git commit -m "test(auth): add JWT validation tests"

# 3. Clean up before PR
git rebase -i main

# 4. Push
git push origin feat/user-authentication
```

### Bug Fix

```bash
# 1. Create fix branch
git checkout -b fix/memory-leak

# 2. Make fix
git add src/cache.rs
git commit -m "fix(cache): prevent memory leak in cleanup

Add explicit drop for cached entries to prevent memory
accumulation over time.

Closes #456"

# 3. Push
git push origin fix/memory-leak
```

### Refactoring

```bash
# 1. Separate formatting from logic changes
git add .
git commit -m "style: run rustfmt"

git add src/parser/mod.rs
git commit -m "refactor(parser): extract validation logic"

git add src/parser/validate.rs
git commit -m "refactor(parser): simplify error handling"

# 2. Each commit compiles and passes tests
cargo test  # Run after each commit!
```

## Commit Message Checklist

Use this checklist when writing commit messages:

- [ ] Type is one of: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`
- [ ] Scope is relevant (package/crate name) or omitted if not applicable
- [ ] Breaking change marked with `!` if applicable
- [ ] Description uses imperative mood ("add" not "added")
- [ ] Description is lowercase (not capitalized)
- [ ] Description has no trailing period
- [ ] Description is concise (under 72 characters if possible)
- [ ] Body explains "why" and "what" (if needed)
- [ ] Body uses imperative mood
- [ ] Body lines wrapped at 72 characters
- [ ] Blank line between description and body
- [ ] Footer includes issue references if applicable
- [ ] Footer includes `BREAKING CHANGE:` if applicable
- [ ] Commit is atomic (one logical change)
- [ ] Commit compiles and passes tests
- [ ] No mixed concerns (formatting separate from logic)
- [ ] File moves/renames in separate commits

## Git Best Practices Summary

### Commit Messages
- Follow Conventional Commits specification
- Use imperative mood, lowercase, no period
- Include scope when relevant (crate/package name)
- Add body for non-obvious changes
- Reference issues in footer
- Mark breaking changes with `!` and footer

### Atomic Commits
- One logical change per commit
- Each commit must compile and pass tests
- Separate concerns (formatting, moves, logic)
- Commit often, clean up with rebase
- Use `git add -p` for fine-grained staging

### Workflow
- Make frequent small commits
- Review with `git diff --staged` before committing
- Use interactive rebase to clean history
- Ensure every commit in the history is meaningful
- Think about future developers reading the history

## Tools and Commands

### Helpful Git Commands

**Stage interactively:**
```bash
git add -p            # Interactive staging
git add -i            # Interactive mode menu
```

**Review changes:**
```bash
git diff              # Unstaged changes
git diff --staged     # Staged changes
git log --oneline     # Compact history
git log --graph       # Visual branch history
```

**Rebase and cleanup:**
```bash
git rebase -i HEAD~N  # Interactive rebase last N commits
git rebase -i main    # Rebase onto main
git commit --amend    # Modify last commit
```

**Undo operations:**
```bash
git reset HEAD~1      # Undo last commit, keep changes
git reset --soft HEAD~1  # Undo commit, keep staged
git reset --hard HEAD~1  # Undo commit, discard changes
git revert <commit>   # Create new commit that undoes changes
```

### Commit Message Templates

You can set up a commit message template:

```bash
# Create template file
cat > ~/.gitmessage << 'EOF'
# <type>[optional scope]: <description>
# 
# [optional body]
# 
# [optional footer(s)]
#
# Types: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert
# Scope: Use package/crate/component name
# Breaking: Add ! before : for breaking changes
#
# Description:
#   - Use imperative mood: "add" not "added"
#   - No capital letter
#   - No period at the end
#
# Body (optional):
#   - Explain WHY, not HOW
#   - Wrap at 72 characters
#
# Footer (optional):
#   - Reference issues: Closes #123
#   - Breaking changes: BREAKING CHANGE: description
EOF

# Configure git to use it
git config --global commit.template ~/.gitmessage
```

## Examples Gallery

### Example 1: Simple Feature
```
feat(cache): add Redis backend support
```

### Example 2: Bug Fix with Details
```
fix(auth): prevent session fixation attacks

Regenerate session ID after successful login to prevent
session fixation vulnerabilities. Previous implementation
reused the same session ID, allowing attackers to hijack
authenticated sessions.

Closes #234
```

### Example 3: Breaking Change
```
feat(api)!: change error response format

BREAKING CHANGE:

Error responses now follow RFC 7807 Problem Details format.
Old format:
  { "error": "message" }
New format:
  {
    "type": "about:blank",
    "title": "Error title",
    "status": 400,
    "detail": "Detailed message"
  }

Migration guide: docs/api/error-format-migration.md

Closes #567
```

### Example 4: Refactoring
```
refactor(parser): extract token validation logic

Move token validation to separate module to improve testability
and reduce complexity in the main parser. No behavior changes.
```

### Example 5: Performance Improvement
```
perf(db): add index on user_email column

Add B-tree index on users.email to speed up login queries.
Benchmarks show 50x improvement for email lookups on tables
with 1M+ users.
```

### Example 6: Multiple Issues
```
fix(ui): resolve layout issues on mobile devices

Fix flexbox overflow, adjust touch targets, and correct
z-index layering for mobile viewports.

Closes #123
Closes #124
Closes #125
```

## Summary

These Git conventions ensure:
- **Clarity:** Future developers understand what changed and why
- **Searchability:** Easy to find specific changes by type or scope
- **Reviewability:** Each commit can be reviewed independently
- **Bisectability:** Every commit is functional, enabling `git bisect`
- **Maintainability:** Clean history makes debugging and reverting easier
- **Automation:** Tools can parse commit messages for changelogs and releases

Follow these guidelines for all commits to maintain a professional, maintainable Git history.
