# Commit Message Examples

This file shows real-world examples of good and bad commit messages to help you understand the conventions.

## ✅ Good Examples

### Simple Feature Addition
```
feat(auth): add OAuth2 provider support
```
**Why it's good:**
- Clear type (`feat`)
- Relevant scope (`auth`)
- Imperative mood ("add")
- Lowercase, no period
- Concise and clear

---

### Bug Fix with Context
```
fix(parser): handle empty input strings

Previous implementation crashed on empty input. Add validation
to return an error instead of panicking.

Closes #234
```
**Why it's good:**
- Describes the problem and solution
- Explains previous behavior
- References the issue
- Body provides context

---

### Breaking Change
```
feat(api)!: remove deprecated /status endpoint

BREAKING CHANGE: The /api/status endpoint has been removed.
Use /api/health instead for health checks.

Migration: Update all clients to use /api/health.
```
**Why it's good:**
- Breaking change indicator (`!`)
- Clear BREAKING CHANGE footer
- Provides migration path
- Explains the replacement

---

### Refactoring
```
refactor(db): extract connection pool to module

Move connection pool logic from main.rs to db/pool.rs to
improve code organization. No behavior changes.
```
**Why it's good:**
- Correct type (`refactor`)
- Explains motivation
- Clarifies no behavior change

---

### Performance Improvement
```
perf(query): optimize user lookup query

Add index on users.email column and rewrite query to use
covering index. Reduces lookup time from 500ms to 5ms
for tables with 1M+ rows.

Benchmark results: benchmarks/user-lookup.md
```
**Why it's good:**
- Specific about the improvement
- Quantifies the performance gain
- References benchmark data

---

### Multiple Commits for Large Feature
```
# Commit 1
feat(user): add User model and database schema

# Commit 2
feat(user): implement user creation endpoint

# Commit 3
feat(user): add user retrieval endpoints

# Commit 4
feat(user): implement update and delete operations

# Commit 5
test(user): add comprehensive test suite
```
**Why it's good:**
- Feature broken into logical, atomic commits
- Each commit is independently reviewable
- Each commit builds on the previous
- Tests added separately

---

### Documentation Update
```
docs(api): clarify authentication requirements

Add examples for Bearer token format and explain token
refresh flow. Update error response documentation.
```
**Why it's good:**
- Clear what was documented
- Mentions specific improvements

---

### Dependency Update
```
build(deps): update tokio to 1.35.0

Update tokio for security fixes in HTTP/2 handling.
No API changes required.
```
**Why it's good:**
- Explains why the update was needed
- Notes whether changes were required

---

### CI Configuration
```
ci(actions): add automated security scanning

Add Dependabot and cargo-audit to CI pipeline to detect
vulnerabilities in dependencies.
```
**Why it's good:**
- Clear what was added
- Explains the purpose

---

## ❌ Bad Examples (and How to Fix Them)

### Too Vague
```
fix: bug
```
**Problems:**
- No scope
- "bug" doesn't describe what was fixed
- No context

**Fixed:**
```
fix(auth): prevent token expiration edge case

Handle tokens expiring during request processing by checking
expiration after acquiring the lock.

Closes #123
```

---

### Wrong Tense
```
feat(api): added new endpoint
```
**Problems:**
- Past tense ("added" instead of "add")
- Should be imperative mood

**Fixed:**
```
feat(api): add health check endpoint
```

---

### Capitalized
```
feat(auth): Add JWT validation
```
**Problems:**
- First letter is capitalized
- Should be lowercase

**Fixed:**
```
feat(auth): add JWT validation
```

---

### Has Period
```
fix(parser): resolve parsing error.
```
**Problems:**
- Ends with a period
- Should have no trailing punctuation

**Fixed:**
```
fix(parser): resolve parsing error
```

---

### Mixed Concerns
```
feat: add user authentication and fix database bug and update docs

- Implement JWT authentication
- Fix connection pool exhaustion
- Update README
- Format code with rustfmt
```
**Problems:**
- Multiple unrelated changes in one commit
- Mixing feature, fix, docs, and style
- Not atomic

**Fixed:**
```
# Commit 1
fix(db): prevent connection pool exhaustion

# Commit 2
style: format codebase with rustfmt

# Commit 3
feat(auth): add JWT token generation

# Commit 4
feat(auth): add authentication middleware

# Commit 5
docs: update README with authentication examples
```

---

### Wrong Type
```
feat(api): fix crash in request handler
```
**Problems:**
- Type is `feat` but this is clearly a bug fix
- Should use `fix` type

**Fixed:**
```
fix(api): prevent crash in request handler

Add null check before accessing request body to prevent
panic when body is empty.
```

---

### Issue Number as Scope
```
fix(issue-123): resolve login problem
```
**Problems:**
- Issue number used as scope
- Scope should be component/module name

**Fixed:**
```
fix(auth): prevent login failures on token refresh

Closes #123
```

---

### No Imperative Mood
```
feat(api): This commit adds rate limiting to the API
```
**Problems:**
- Not imperative ("This commit adds" is verbose)
- Should be concise

**Fixed:**
```
feat(api): add rate limiting

Implement token bucket algorithm to limit requests to
100 per minute per user.
```

---

### Breaking Change Without Indicator
```
feat(api): change error response format

Error responses now use a different format.
```
**Problems:**
- This is a breaking change but no `!` indicator
- No BREAKING CHANGE footer

**Fixed:**
```
feat(api)!: change error response format

BREAKING CHANGE: Error responses now follow RFC 7807 format.
Old clients must update to handle new format.

Migration guide: docs/api/error-migration.md
```

---

### Too Much Detail in Description
```
feat(auth): add JWT authentication with Bearer token support and token refresh mechanism using Redis for session storage
```
**Problems:**
- Description is too long (over 100 characters)
- Too much detail should be in body

**Fixed:**
```
feat(auth): add JWT authentication with token refresh

Implement Bearer token authentication with automatic refresh.
Use Redis for session storage to enable distributed deployments.
Tokens expire after 15 minutes and can be refreshed up to
7 days from issuance.
```

---

### Missing Context for Complex Change
```
refactor(parser): improve validation
```
**Problems:**
- Too vague for a refactoring
- No explanation of what was improved or why

**Fixed:**
```
refactor(parser): simplify validation logic

Replace nested if/else chains with match expressions and
extract validation rules to separate functions. This improves
readability and makes adding new validation rules easier.

No behavior changes.
```

---

## 📋 Real-World Example: Feature Development

Here's a complete feature development with proper atomic commits:

```
# 1. Add the data model
feat(order): add Order and OrderItem models

Define data structures for orders with validation.

# 2. Add database schema
build(db): add orders and order_items tables

Create tables with foreign key constraints and indexes.

# 3. Implement repository
feat(order): implement order repository

Add database access layer for order CRUD operations using
the repository pattern.

# 4. Add business logic
feat(order): add order processing service

Implement order validation, inventory checks, and payment
processing coordination.

# 5. Add API endpoints
feat(api): add order management endpoints

Implement REST API for creating, retrieving, and updating
orders with proper error handling.

# 6. Add tests
test(order): add comprehensive test suite

Add unit tests for order validation and integration tests
for repository and API endpoints.

# 7. Add documentation
docs(order): document order API and workflows

Add API documentation and diagram of order processing flow.
```

Each commit:
- ✅ Is atomic (one logical change)
- ✅ Has proper type and scope
- ✅ Uses imperative mood
- ✅ Compiles and passes tests
- ✅ Can be reviewed independently
- ✅ Can be reverted if needed

---

## 🎯 Quick Reference

**Good commit message formula:**
```
<type>(<scope>): <what changed>

<why it changed>
<how it's different from before>

<issue references>
```

**Remember:**
- Imperative mood: "add", "fix", "update" (not "added", "fixed", "updated")
- Lowercase first letter
- No trailing period
- One logical change per commit
- Each commit must compile and pass tests
