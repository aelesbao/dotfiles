---
name: git-conventions
description: Conventional Commits and atomic commit rules. Use when writing or reviewing commit messages, or creating, splitting, squashing, or rebasing commits.
---

# Git Conventions

Repo conventions come first. If the repo has a commitlint config, a commit section in CONTRIBUTING.md, or a consistent style in `git log`, follow it and use these rules only to fill the gaps. Reuse scopes that already appear in `git log`.

## Creating commits

1. Read `git status` and `git diff` (staged and unstaged).
2. Group the changes into atomic commits, one logical change each. Formatting, file moves/renames, dependency updates, and logic changes always go in separate commits.
3. For each group, in dependency order: stage only its changes, run the project's build and tests, then commit with a message that follows the rules below.
4. Check the result with `git log --oneline <base>..HEAD`.

Done when every change sits in exactly one atomic commit and every commit builds and passes tests.

### Non-interactive git

Run git so it never waits for an editor or a prompt:

- Partial file staging: `git diff -- <file> > <tmp>/part.patch`, keep only the hunks for this commit, then `git apply --cached --recount <tmp>/part.patch`.
- Fold a fix into an earlier commit: `git commit --fixup=<sha>`, then `GIT_SEQUENCE_EDITOR=: git rebase -i --autosquash <base>`.
- Reword the last commit: `git commit --amend -m "<message>"`.

Rewrite only commits that have not been pushed, and push only when asked.

## Message format

```
<type>[(scope)][!]: <description>

[body]

[footers]
```

| Type       | Use for                                                   |
| ---------- | --------------------------------------------------------- |
| `feat`     | new behavior for users                                    |
| `fix`      | bug fix                                                   |
| `docs`     | documentation only                                        |
| `style`    | formatting and whitespace, no behavior change             |
| `refactor` | restructuring with no behavior change, no fix, no feature |
| `perf`     | performance improvement                                   |
| `test`     | adding or fixing tests only                               |
| `build`    | build system, dependencies, version bumps                 |
| `ci`       | CI configuration                                          |
| `chore`    | other maintenance that touches no source or test files    |
| `revert`   | reverting an earlier commit                               |

### Header

- Description in imperative mood, lowercase first letter, no trailing period: "add", not "Added" or "adds".
- Keep the whole header within 72 characters. Move details to the body.

### Scope

- Use the package or crate name (`games/lilypad` becomes `lilypad`), or a module/component name (`auth`, `parser`).
- Omit it for repo-wide changes: `docs: update README`.
- Issue IDs belong in a footer, not in the scope.

### Body

- Explain why the change was made and how behavior differs from before. The diff already shows how the code changed.
- Imperative mood, wrapped at 72 characters, one blank line after the header.

### Footers

- One blank line after the body, then all footers on consecutive lines. Git reads only the last paragraph as trailers, so a blank line inside the footer block drops the footers above it (including `Co-Authored-By`).
- Issue references: `Closes #123`, `Fixes #123`, `Refs #123`.
- Breaking changes: add `!` before the `:` and a `BREAKING CHANGE: <what broke and how to migrate>` footer.
- Reverts: `revert: <description of the reverted commit>` with a `Refs: <sha>` footer.

## Examples

```
fix(parser): handle empty input strings

The parser panicked on empty input. Return an error instead
so callers can report it.

Closes #234
```

```
feat(api)!: remove deprecated status endpoint

/api/health has returned the same payload since v2.3, and keeping
both endpoints doubled the monitoring config.

BREAKING CHANGE: /api/status is removed. Call /api/health instead.
Refs #567
```

| Wrong                                     | Right                                                       |
| ----------------------------------------- | ----------------------------------------------------------- |
| `feat(auth): Added JWT validation.`       | `feat(auth): add JWT validation`                            |
| `fix(issue-123): resolve login problem`   | `fix(auth): keep session on token refresh` + `Closes #123`  |
| `feat(api): fix crash in request handler` | `fix(api): prevent crash on empty request body`             |
| `feat: add auth and fix db pool bug`      | two commits: `fix(db): ...`, then `feat(auth): ...`         |

When unsure how to phrase a message or which type fits, read [commit-messages.md](commit-messages.md).
