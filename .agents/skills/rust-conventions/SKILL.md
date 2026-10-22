---
name: rust-conventions
description: Rust implementation, debugging, refactoring, and code review with house conventions for errors, ownership, APIs, functional style, testing, and async work. Use for any Rust code change or Rust review.
---

# Rust conventions

The repository's own conventions always win. Everything in this skill is a house
default for where the repository is silent, not a Rust correctness rule. Keep
changes scoped to the task.

## Workflow

1. **Inspect.** Read project instructions, `Cargo.toml` and workspace manifests,
   toolchain, rustfmt and lint config, and CI. Use the commands the project uses.
2. **Pin compatibility.** Identify MSRV, edition, targets, supported feature
   combinations, runtime, and dependency policy. Keep all of them as they are
   unless the task is to change them.
3. **Classify.** Bug fix, API change, feature, or review. Read only the
   references below that the change touches.
4. **Change minimally.** Preserve public contracts and unrelated behavior. Add
   dependencies, abstractions, or async only when the task needs them.
5. **Test.** Cover changed behavior, failure paths, empty input, and boundaries.
   Update affected API docs.
6. **Validate.** Run the repository's checks, or the fallback list below.
7. **Report evidence.** Changed behavior, commands actually run, results, and
   limits. Separate pre-existing failures from regressions. If a tool or
   dependency is missing, report it as a blocker and ask before installing.

## References

Paths are relative to this skill directory.

- [Error handling](references/error-handling.md): error types, context,
  fallbacks, panics.
- [Functional style](references/functional-style.md): iterator transformations,
  ownership, mutation, allocation.
- [Async and concurrency](references/async-and-concurrency.md): runtimes,
  spawning, cancellation, locks, shutdown.
- [Review](references/review.md): any review task; defines finding labels.

## Types and APIs

- Start concrete. Add traits or generics for real reuse or invariants, not
  anticipated ones. A function parameter beats constructor or trait scaffolding.
- Encode invariants in validated newtypes, enums, `NonZero*`, and `Option`
  instead of strings, boolean pairs, or sentinels. Validate at construction.
- Default to private; widen to `pub(crate)` or `pub` as needed. Libraries curate
  re-exports in `lib.rs`.
- `#[non_exhaustive]` on public enums expected to grow. Adding it to an existing
  enum is a breaking change.
- `#[must_use]` where ignoring the value is likely a bug, not everywhere.
- Unsafe: a `# Safety` section on unsafe APIs, and a `// SAFETY:` comment at
  every unsafe block explaining why the obligations hold at that call site. Use
  explicit unsafe blocks inside unsafe functions. Passing tests are not proof of
  soundness.

## Output and observability

- Stdout carries CLI results. Diagnostics go to stderr through the existing
  logging system. Libraries never print or install a global subscriber.
- For a new service or async system, use `tracing`. Use
  `#[instrument(skip_all, fields(...))]` and allowlist only safe fields.
- Keep credentials, tokens, and sensitive bodies out of logs, error context, and
  span fields.
- Log an error once, at the boundary that handles it. Code that returns an error
  does not also log it.

## Cargo and lints

- Format with `cargo +nightly fmt --all` unless the repo configures otherwise.
  Nightly is for rustfmt only, never for unstable language features.
- Keep CI lint policy such as `-D warnings`. Otherwise run Clippy on affected
  targets and fix relevant warnings.
- Put Clippy policy in manifest `[lints]` (Rust 1.74+), respecting workspace
  inheritance. Select individual `restriction` lints, never the whole group.
  Every `allow` gets a justification.
- Explain any major new dependency or feature flag.

## Compatibility gates

Check features against the project's MSRV and edition, not the local compiler.

- `async fn` in traits: stable since 1.75, not `dyn`-compatible. For `Send`
  futures, declare `fn f(&self) -> impl Future<Output = T> + Send`, or use
  `trait_variant` if dependencies allow. Return-type notation is unstable.
- Edition 2024 needs Rust 1.85+. It widens return-position `impl Trait` lifetime
  capture, requires `unsafe extern` blocks, and warns on
  `unsafe_op_in_unsafe_fn`. Review captures during migration.
- Let-chains need Rust 1.88 and edition 2024.

## Testing and validation

Unit tests sit near the code; integration tests cover public boundaries. Test
observable contracts. Control time, randomness, and external effects; add a trait
only when a real seam needs a test double. Use property tests for important
invariants. Profile before optimizing.

Fallback checks when the repository defines none:

1. `cargo +nightly fmt --all`, then `cargo +nightly fmt --all -- --check`.
2. Focused tests, then package or workspace tests and doctests.
3. `cargo clippy` for affected targets and supported feature combinations.
   Choose feature sets deliberately; `--all-features` can combine exclusive ones.
4. `cargo doc --no-deps` for API or doc changes.
5. The declared MSRV and relevant targets, where available.

Done means each check ran or is reported as not run with the reason, and the
report lists actual commands and outcomes.
