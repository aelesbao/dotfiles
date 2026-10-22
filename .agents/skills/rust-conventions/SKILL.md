---
name: rust-conventions
description: Rust implementation, debugging, refactoring, and code review with repository-aware conventions for errors, ownership, APIs, functional style, testing, and async work. Use for Rust changes or reviews that need concrete implementation and validation guidance, not for unrelated languages or architecture design.
---

# Rust conventions

Follow the repository's conventions first. Use this skill's house defaults only
where the repository is silent; they are not Rust correctness requirements.
Keep changes focused on the requested task, not an unrelated style migration.
This skill does not prescribe application layers or a binary/library split.

## Inspect, change, test, report

1. **Inspect the repository.** Read applicable project instructions, `Cargo.toml`,
   workspace manifests, toolchain files, rustfmt and lint configuration, and CI.
   Find the commands the project actually uses before selecting your own.
2. **Establish compatibility.** Identify the minimum supported Rust version
   (MSRV), edition, target platforms, supported feature combinations, runtime,
   and dependency policy. Do not silently raise any of these requirements.
3. **Classify the task.** Is this a bug fix, API change, new feature, or review?
   Read only the supporting resources relevant to the affected behavior below.
   For a review, use the finding labels in the review reference.
4. **Make the smallest appropriate change.** Preserve unrelated behavior and
   public contracts. Do not add dependencies, abstractions, async execution,
   workspace restructuring, or broad rewrites merely to apply a preference.
5. **Add focused tests.** Cover changed behavior and applicable failures, empty
   inputs, and boundary values. Update affected API documentation.
6. **Run validation.** Execute repository commands for the affected scope.
   Use the validation procedure below where no commands are specified.
7. **Report evidence.** Summarize changed behavior, commands actually run,
   results, and limitations. Separate pre-existing failures from regressions.
   If tools or dependencies are unavailable, report the blocker, respect host
   approval rules, and do not claim the checks ran. Do not silently install tools.

## Supporting resources: read when relevant

Resolve these paths from the skill directory, not the project working directory.
Each topic reference owns its detailed rules; this core owns the workflow and
cross-cutting API, tooling, documentation, and testing defaults.

- [Error handling](references/error-handling.md): read for error types,
  propagation, boundary context, fallbacks, or deliberate panic decisions.
- [Async and concurrency](references/async-and-concurrency.md): read before
  changing runtimes, locks, spawned work, cancellation, or shutdown.
- [Functional style](references/functional-style.md): read for transformations,
  ownership, allocation, mutation, or comparing imperative and functional code.
- [Review](references/review.md): read for review tasks, finding classification,
  severity, evidence, and reporting without unsolicited style rewrites.
- [Example guide](examples/GUIDE.md): read before using the checked Cargo package;
  distinguishes runnable examples, teaching stand-ins, and compile-fail snippets.
- [Error examples](examples/src/error_handling.rs): inspect concrete typed errors,
  lazy boundary context, validation alternatives, and fallible logger setup.
- [Functional examples](examples/src/functional_patterns.rs): inspect tested
  transformations, explicit empty-input behavior, and deterministic processing.
- [Async examples](examples/src/async_concurrency.rs): inspect measured work/task
  bounds, owned shutdown, cancellation, backpressure, locks, and safe tracing.
- [README](README.md): read for layout, filesystem installation, and contribution.

## Naming, types, and public APIs

- Use `UpperCamelCase` for types and traits, `snake_case` for functions, methods,
  modules and variables, and `SCREAMING_SNAKE_CASE` for constants and statics.
- Choose descriptive names; use abbreviations only when domain-standard. Avoid
  stutter such as `user::UserUserId`; prefer `user::UserId`.
- Start concrete. Introduce traits or generics for real reuse, variation, or
  invariants, not anticipated complexity. Compose small types rather than deep
  abstraction hierarchies. Use dynamic dispatch when runtime variation needs it.
- Use `impl Trait` when it clarifies an API; use named generics when callers need
  to name or relate types, including explicit generic arguments (turbofish).
  Put complex bounds in `where` clauses; avoid deeply nested bounds.
- Encode meaningful invariants with validated newtypes, enums, `NonZero*`, and
  `Option` rather than ambiguous strings, conflicting booleans, or sentinels.
  A newtype alone does not validate its contents: enforce constraints at creation.
- Keep modules cohesive and default to private. Widen to `pub(crate)` or `pub`
  only as needed. In libraries, curate re-exports from `lib.rs` rather than
  exposing deep internal trees. Do not create a library just to satisfy this rule.
- Make dependencies and mutable state explicit. Prefer passing needed values
  over hidden mutable globals; do not introduce constructor/trait scaffolding
  when a function parameter suffices.
- Consider `#[non_exhaustive]` for public error enums expected to grow. It changes
  downstream construction/matching, so preserve existing exhaustive contracts.
- Use `#[must_use]` when ignoring a returned value would likely be a bug, with a
  useful message where needed; do not annotate every value indiscriminately.

## Documentation and unsafe code

Document public **library contracts** with `///`: purpose, invariants, and relevant
performance costs. Scope binary-internal documentation to project needs.

- Include `# Errors`, `# Panics`, and examples where applicable, not empty sections.
  Make examples runnable doctests when possible; label sketches and intentionally
  invalid examples explicitly. Keep them compatible with supported features.
- For unsafe APIs, document caller obligations in a `# Safety` section. At each
  unsafe block, use a local `// SAFETY:` explanation of why those obligations and
  the operation's other soundness requirements hold at that exact call site.
- Avoid unsafe code without clear value such as FFI or measured low-level needs.
  Keep unsafe blocks minimal and review aliasing, lifetimes, validity, and thread
  safety as applicable. Use explicit blocks even inside unsafe functions.
- Add focused tests for unsafe behavior, but do not treat passing tests as proof
  of soundness. The panic policy lives in the error-handling reference.

## Output and observability

- Stdout is appropriate for CLI results, including machine-readable output.
  Keep diagnostics separate, normally on stderr via the existing logging system
  or an explicit CLI diagnostic path. Libraries should not print unexpectedly or
  initialize a global subscriber on callers' behalf.
- Preserve the existing logging system. For a new service or async system needing
  structured diagnostics, prefer `tracing`; do not add it to unrelated work.
- Instrument logical operations with spans and relevant fields. With
  `#[instrument]`, prefer `skip_all` and explicitly allowlist safe fields to avoid
  implicit argument capture, duplicate fields, and sensitive data exposure.
- Never record credentials, tokens, or sensitive request bodies. Review identifiers
  and error chains for secrets too; adding context is not permission to leak data.
- Log an error at the boundary that handles it, not at every propagation layer.
  Returning an error after logging it usually produces duplicate diagnostics.
- Select levels by operational meaning: `error` for failed operations requiring
  attention, `warn` for unexpected but handled conditions, `info` for significant
  normal events, `debug` for diagnostic detail, and `trace` for very fine detail.
  A client error or HTTP status alone does not determine the level. Enable verbose
  levels deliberately; do not assume they are always safe or useful in production.

## Cargo, formatting, and lint policy

- Keep dependencies and feature flags minimal and intentional. Explain major new
  dependencies; check for redundant dependencies when relevant, not on every fix.
  Use workspaces when managing multiple related crates warrants one; do not
  restructure an existing repository as part of an unrelated task.
- Follow the repository's explicit toolchain and formatting configuration.
  Otherwise default to `cargo +nightly fmt --all`; use nightly for formatting,
  not as an excuse to introduce unstable language features.
- Preserve CI lint policy, including `-D warnings` when configured. Without a
  policy, run Clippy for the affected targets and fix relevant warnings; do not
  impose a repository-wide deny policy as an unrelated change.
- Prefer manifest `[lints]` configuration for project Clippy policy when MSRV
  permits (Rust 1.74+), rather than adding crate-level deny attributes. Respect
  workspace lint inheritance. Do not enable the entire `clippy::restriction`
  group; select intentional lints. Justify narrow allowances, never hide a defect
  or suppress warnings merely to make validation pass.

## Compatibility gates

The teaching package uses Rust 1.89.0 and edition 2024. That is an example baseline,
not permission to raise another project's MSRV or edition. Check both language
features and dependency requirements against the actual project.

- Native `async fn` in traits is stable since 1.75, but such traits are not
  `dyn`-compatible. For callers needing `Send` futures, a stable option is an
  explicit method returning `impl Future<Output = T> + Send`; `trait_variant`
  is an optional dependency-based alternative, subject to repository policy.
  Return-type notation is **unstable** at this baseline: do not present it as a
  stable way to add `Send` bounds. It requires an explicitly approved nightly
  `#![feature(return_type_notation)]`; use a supported pattern for trait objects.
- Edition 2024 requires Rust 1.85+. Return-position `impl Trait` captures in-scope
  generic parameters, including lifetimes, more broadly than in earlier editions;
  review lifetime/capture changes during migration rather than assuming parity.
- Edition 2024 requires `unsafe extern` blocks and warns on
  `unsafe_op_in_unsafe_fn` by default. An unsafe function's contract does not
  remove the need to justify each unsafe operation.
- Let-chains are stable since 1.88 and require edition 2024. Do not use them in
  older-edition or lower-MSRV projects even if the local compiler accepts them.

## Testing and validation

Prefer small unit tests near the code and integration tests at public boundaries.
Test observable contracts rather than private implementation details. Control time,
randomness, and external effects; use suitable test doubles without introducing
traits solely to mock trivial code. Consider property tests for important invariants.
Profile before optimizing; do not infer performance improvements from style alone.

When repository commands are absent, select checks appropriate to the change:

1. Run the selected formatter, then its check mode (for the fallback:
   `cargo +nightly fmt --all` and `cargo +nightly fmt --all -- --check`).
2. Run focused tests, then relevant package/workspace tests and doctests.
3. Run `cargo clippy` for affected targets and supported feature combinations.
4. Build documentation with `cargo doc --no-deps` for API/documentation changes.
5. Check the declared MSRV and relevant targets where available. Do not blindly
   combine mutually exclusive features with `--all-features` or fetch dependencies
   without respecting repository and host approval rules.

### Final verification checklist

- [ ] Scope and compatibility match the request and inspected repository policy.
- [ ] Changed behavior, failure cases, and affected contracts have focused tests.
- [ ] Relevant topic references were applied without unrelated rewrites.
- [ ] Formatting, tests, linting, and applicable docs/compatibility checks ran,
      or each unavailable check is explicitly identified.
- [ ] Report lists actual commands, outcomes, pre-existing failures, and remaining
      limitations; review findings use the labels in the review reference.

For external API design background, consult the
[Rust API Guidelines](https://rust-lang.github.io/api-guidelines/); verify technical
claims against the project's versions rather than assuming latest docs prove MSRV
compatibility. This skill's tool, dependency, and style defaults are house choices,
not claims of universal community enforcement.
