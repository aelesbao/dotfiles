# Commit Message Examples

## Good

### Feature

```
feat(auth): add OAuth2 provider support
```

### Bug fix with context

```
fix(parser): handle empty input strings

The parser crashed on empty input. Add validation to return an
error instead of panicking.

Closes #234
```

### Breaking change

```
feat(api)!: remove deprecated /status endpoint

BREAKING CHANGE: /api/status is removed. Update all clients to use
/api/health, which returns the same payload.
```

### Refactoring

```
refactor(db): extract connection pool to module

Move connection pool logic from main.rs to db/pool.rs so it can be
tested in isolation. No behavior changes.
```

### Performance

```
perf(query): optimize user lookup query

Add an index on users.email and rewrite the query to use a covering
index. Lookup time drops from 500ms to 5ms on tables with 1M+ rows.
```

### Documentation

```
docs(api): clarify authentication requirements

Add examples for the Bearer token format and explain the token
refresh flow.
```

### Dependency update

```
build(deps): update tokio to 1.35.0

Pick up security fixes in HTTP/2 handling. No API changes required.
```

### CI

```
ci(actions): add automated dependency auditing

Run cargo-audit on every pull request to catch vulnerable
dependencies before merge.
```

## Bad, and how to fix them

### Too vague

```
fix: bug
```

Says nothing about what broke. Fixed:

```
fix(auth): prevent token expiration edge case

Tokens that expired while a request was in flight were accepted.
Check expiration after acquiring the lock.

Closes #123
```

### Narrates instead of imperative

```
feat(api): This commit adds rate limiting to the API
```

Fixed:

```
feat(api): add rate limiting

Limit each user to 100 requests per minute with a token bucket.
```

### Breaking change without indicator

```
feat(api): change error response format

Error responses now use a different format.
```

Missing `!` and the `BREAKING CHANGE:` footer. Fixed:

```
feat(api)!: change error response format

BREAKING CHANGE: Error responses now follow RFC 7807. Clients must
parse the new format. Migration guide: docs/api/error-migration.md
```

### Header too long

```
feat(auth): add JWT authentication with Bearer token support and token refresh mechanism using Redis for session storage
```

Fixed, with the details moved to the body:

```
feat(auth): add JWT authentication with token refresh

Use Redis for session storage so refresh works across instances.
Tokens expire after 15 minutes and can be refreshed for up to 7 days.
```

### Missing context for a non-obvious change

```
refactor(parser): improve validation
```

Fixed:

```
refactor(parser): simplify validation logic

Replace nested if/else chains with match expressions and extract
each rule into its own function, so new rules are one-line
additions. No behavior changes.
```
