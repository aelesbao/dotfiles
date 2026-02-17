# Atomic Commit Workflows

This guide shows practical examples of how to create atomic commits in real-world scenarios.

## Scenario 1: Fixing a Bug While Adding a Feature

### ❌ Bad Approach: Mixed Commit
```bash
# You're adding a new feature and discover a bug
vim src/parser.rs  # Add feature + fix bug in same file

git add src/parser.rs
git commit -m "feat(parser): add validation and fix crash bug"
```

**Problems:**
- Mixes feature and bug fix
- If feature needs to be reverted, bug fix is also reverted
- Can't cherry-pick the bug fix alone

### ✅ Good Approach: Separate Commits
```bash
# You're adding a feature and discover a bug
vim src/parser.rs  # Edit file with both changes

# Use git add -p to stage only the bug fix
git add -p src/parser.rs
# Select 'y' for bug fix hunks, 'n' for feature hunks

git commit -m "fix(parser): prevent crash on empty input"

# Now stage the feature
git add -p src/parser.rs
# Select 'y' for feature hunks

git commit -m "feat(parser): add email validation"
```

**Benefits:**
- Bug fix can be cherry-picked to release branch
- Feature can be reverted without losing bug fix
- Each commit is independently reviewable

---

## Scenario 2: Large Refactoring

### ❌ Bad Approach: One Giant Commit
```bash
# Refactor everything at once
vim src/*.rs  # Change 20 files

git add .
git commit -m "refactor: improve code quality"
```

**Problems:**
- Impossible to review
- Can't identify which change caused issues
- Can't partially revert

### ✅ Good Approach: Incremental Steps
```bash
# Step 1: Separate formatting
cargo fmt
git add .
git commit -m "style: format codebase with rustfmt"

# Step 2: Fix clippy warnings
cargo clippy --fix
git add .
git commit -m "style: fix clippy warnings"

# Step 3: Rename types for clarity
vim src/models.rs  # Rename types only
git add src/models.rs
git commit -m "refactor(models): rename User to UserAccount for clarity"

# Step 4: Extract validation logic
vim src/models.rs src/validation.rs  # Move validation code
git add src/models.rs src/validation.rs
git commit -m "refactor(models): extract validation to separate module"

# Step 5: Simplify error handling
vim src/error.rs  # Simplify error types
git add src/error.rs
git commit -m "refactor(error): simplify error type hierarchy"

# After each commit: verify it compiles and passes tests!
cargo test
```

---

## Scenario 3: Moving Files and Updating Imports

### ❌ Bad Approach: Move and Modify Together
```bash
# Move file and refactor it in one commit
git mv src/user.rs src/models/user.rs
vim src/models/user.rs  # Also refactor the code
vim src/main.rs         # Update imports

git add .
git commit -m "refactor: reorganize user module and improve logic"
```

**Problems:**
- Git may not detect the rename correctly
- Diff is confusing (looks like delete + add)
- Can't see what actually changed in the code

### ✅ Good Approach: Separate Move from Changes
```bash
# Step 1: Just move the file
git mv src/user.rs src/models/user.rs
vim src/main.rs         # Only update imports
git add .
git commit -m "refactor: move user module to models directory"

# Step 2: Now refactor
vim src/models/user.rs  # Make logical changes
git add src/models/user.rs
git commit -m "refactor(user): extract validation logic"

# Git now tracks the rename properly and diffs are clean
```

---

## Scenario 4: Using `git add -p` Effectively

### Interactive Staging Example

```bash
# You've made multiple changes to the same file
vim src/api.rs
# - Fixed a bug in line 50
# - Added a new feature in line 100-120
# - Fixed formatting in line 200

# Start interactive staging
git add -p src/api.rs
```

**Interactive session:**
```
diff --git a/src/api.rs b/src/api.rs
@@ -48,7 +48,9 @@ fn handle_request() {
     let body = request.body();
-    process(body)
+    if body.is_empty() {
+        return Err(Error::EmptyBody);
+    }
+    process(body)
 }

Stage this hunk [y,n,q,a,d,s,e,?]? y  ← Stage the bug fix
```

```
@@ -98,6 +100,18 @@ fn validate() {
     Ok(())
 }
 
+pub fn validate_email(email: &str) -> Result<(), Error> {
+    if !email.contains('@') {
+        return Err(Error::InvalidEmail);
+    }
+    Ok(())
+}

Stage this hunk [y,n,q,a,d,s,e,?]? n  ← Don't stage the feature yet
```

**Continue:**
```bash
# Commit the bug fix
git commit -m "fix(api): validate empty request body"

# Stage the feature
git add -p src/api.rs
# This time select 'y' for the feature hunks

git commit -m "feat(api): add email validation"

# Stage formatting
git add src/api.rs  # Remaining changes
git commit -m "style(api): fix formatting"
```

---

## Scenario 5: Cleaning Up History with Interactive Rebase

### Before Cleanup
```bash
git log --oneline
a1b2c3d feat(auth): add authentication
b2c3d4e fix typo
c3d4e5f add more validation
d4e5f6g whoops, forgot to add file
e5f6g7h fix another typo
f6g7h8i tests
```

### ❌ This history is messy!
- Typo fixes should be squashed
- "whoops" commit shows mistakes
- "tests" is not descriptive

### ✅ Clean it up with interactive rebase
```bash
git rebase -i HEAD~6
```

**In the editor:**
```
pick a1b2c3d feat(auth): add authentication
fixup b2c3d4e fix typo                        # Squash into previous
pick c3d4e5f add more validation
fixup d4e5f6g whoops, forgot to add file      # Squash into previous
fixup e5f6g7h fix another typo                # Squash into previous
reword f6g7h8i tests                          # Fix the message
```

**Reword the test commit:**
```
test(auth): add comprehensive authentication tests
```

### After Cleanup
```bash
git log --oneline
a1b2c3d feat(auth): add authentication
c3d4e5f feat(auth): add validation rules
f6g7h8i test(auth): add comprehensive authentication tests
```

**Much better!**
- Clean, professional history
- Each commit is meaningful
- No typo fix commits cluttering history

---

## Scenario 6: Splitting a Large Commit

### You accidentally made a large commit
```bash
git log --oneline
a1b2c3d feat(api): add complete user management system
```

### Split it into atomic commits
```bash
# Step 1: Undo the commit but keep changes
git reset HEAD~1

# Step 2: Stage and commit piece by piece
git add src/models/user.rs
git commit -m "feat(user): add User model and validation"

git add src/db/user_repository.rs
git commit -m "feat(user): implement user repository"

git add src/api/user_routes.rs
git commit -m "feat(api): add user CRUD endpoints"

git add tests/user_tests.rs
git commit -m "test(user): add comprehensive test suite"
```

---

## Scenario 7: Feature Branch with Clean History

### Development Process
```bash
# Create feature branch
git checkout -b feat/user-authentication

# Work iteratively, committing often
git commit -m "feat(auth): add authentication trait"
git commit -m "wip: experimenting with JWT"
git commit -m "feat(auth): implement JWT provider"
git commit -m "fix typo in JWT validation"
git commit -m "add more validation"
git commit -m "refactor: cleanup"
git commit -m "test(auth): add basic tests"
git commit -m "test(auth): add more test cases"

# Before creating PR, clean up history
git rebase -i main
```

**Interactive rebase:**
```
pick  abc123  feat(auth): add authentication trait
drop  def456  wip: experimenting with JWT              # Drop WIP commit
pick  ghi789  feat(auth): implement JWT provider
fixup jkl012  fix typo in JWT validation              # Squash typo fix
fixup mno345  add more validation                      # Squash into feature
drop  pqr678  refactor: cleanup                        # Drop vague commit
pick  stu901  test(auth): add basic tests
fixup vwx234  test(auth): add more test cases          # Combine test commits
```

### Result
```bash
git log --oneline
abc123 feat(auth): add authentication trait
ghi789 feat(auth): implement JWT provider
stu901 test(auth): add comprehensive authentication tests
```

**Clean, reviewable history!**

---

## Scenario 8: Dependency Updates

### ❌ Bad: Mixing dependency updates with features
```bash
git commit -m "feat(api): add rate limiting and update dependencies"
```

### ✅ Good: Separate commits
```bash
# Commit 1: Update dependencies
vim Cargo.toml  # Update tokio version
cargo update
git add Cargo.toml Cargo.lock
git commit -m "build(deps): update tokio to 1.35.0

Update tokio for security fixes in HTTP/2 handling.
No API changes required."

# Commit 2: Add feature
vim src/api/rate_limit.rs
git add src/api/rate_limit.rs
git commit -m "feat(api): add rate limiting middleware"
```

---

## Best Practices Summary

### When to Commit
✅ **Do commit when:**
- Code compiles
- Tests pass
- You've completed a logical unit of work
- You're about to switch tasks

❌ **Don't commit when:**
- Code doesn't compile (unless using `--amend` to fix)
- Tests are failing (unless fixing in next commit)
- You've mixed multiple unrelated changes

### How to Stage Changes

**For simple changes:**
```bash
git add file.rs
git commit -m "fix(parser): handle edge case"
```

**For mixed changes in one file:**
```bash
git add -p file.rs  # Interactive staging
# Stage related chunks together
git commit -m "fix(parser): handle edge case"
# Repeat for remaining changes
```

**For reviewing before staging:**
```bash
git diff              # See what changed
git add -p            # Stage interactively
git diff --staged     # Review what's staged
git commit            # Commit
```

### Verification Checklist

Before committing, always verify:
```bash
# 1. Does it compile?
cargo build

# 2. Do tests pass?
cargo test

# 3. Is the commit message correct?
git log -1 --pretty=format:"%s"

# 4. Does the diff make sense?
git diff HEAD~1
```

### Daily Workflow

**Morning:**
```bash
git pull --rebase origin main
git checkout -b feat/my-feature
```

**During development:**
```bash
# Make changes
vim src/file.rs

# Verify it works
cargo test

# Commit atomically
git add -p src/file.rs
git commit -m "feat(module): add functionality"

# Repeat
```

**Before pushing:**
```bash
# Clean up history
git rebase -i main

# Verify everything still works
cargo test

# Push
git push origin feat/my-feature
```

---

## Common Mistakes and Solutions

### Mistake: "I committed to the wrong branch"
```bash
# Solution: Cherry-pick to correct branch
git checkout correct-branch
git cherry-pick <commit-hash>
git checkout wrong-branch
git reset --hard HEAD~1
```

### Mistake: "I forgot to add a file to my commit"
```bash
# Solution: Amend the commit
git add forgotten-file.rs
git commit --amend --no-edit
```

### Mistake: "My commit message has a typo"
```bash
# Solution: Reword the commit
git commit --amend  # Opens editor
# Or
git commit --amend -m "fixed message"
```

### Mistake: "I need to split my last commit"
```bash
# Solution: Reset and recommit
git reset HEAD~1     # Undo commit, keep changes
git add -p          # Stage parts
git commit -m "first part"
git add -p          # Stage more
git commit -m "second part"
```

---

## Advanced: Git Bisect with Atomic Commits

**Why atomic commits matter for bisecting:**

```bash
# Each commit works independently
git bisect start
git bisect bad HEAD
git bisect good v1.0.0

# Git checks out commits one by one
# At each step:
cargo test  # Must pass!

# If test fails, that commit introduced the bug
git bisect bad

# If test passes, bug is later
git bisect good

# Git narrows down to the exact commit
```

**This only works if every commit:**
- ✅ Compiles
- ✅ Passes tests
- ✅ Is atomic

If commits are broken or mixed, bisecting is impossible!

---

Remember: **Atomic commits are about making life easier for yourself and your team in the future.** Take the extra time to commit properly—it pays off!
