# Error handling

Read this reference when designing error types, propagating failures, adding
context, or deciding whether a panic or fallback is part of a contract.

## Typed errors and house defaults

Use `Result<T, E>` for recoverable failures. Keep error variants actionable and
preserve typed sources when callers need to inspect or match them; avoid making
callers parse display strings. Use `Option` for meaningful absence, not to hide a
failure that the caller needs to handle.

The house conventions **require `thiserror` for library error types and `anyhow`
for binary error aggregation**, unless explicit repository conventions or
dependency constraints override them. These are dependency/style choices, not Rust
correctness rules. Existing hand-written errors, another error framework, no-std,
restricted dependency policies, or a task that does not change error design can
justify preserving the existing approach. Do not introduce `anyhow` solely to add
context, convert every binary-internal function to it, or erase a library's typed
public contract. Report a relevant exception rather than rewriting unrelated code.

Define only meaningful distinctions. Use `#[from]` or explicit conversions to
retain a source where useful, not to couple a public API unnecessarily to an
implementation dependency. Follow the core skill's API-evolution guidance for
public error enums.

## Context at boundaries

Add context where it tells the caller which operation failed or identifies a safe
resource, such as a config path. Plain `?` is correct when the existing error is
already informative. Avoid redundant wrapping at every call and do not log an
error simply because it is being propagated.

- Use `.context("static message")` for a fixed message.
- Use `.with_context(|| format!(...))` for allocated or expensive context so it is
  constructed only on failure, not `.context(format!(...))`.
- Preserve error sources instead of replacing them with strings. Keep typed
  library errors until an application boundary needs aggregation.
- Do not include secrets in context or expose internal details indiscriminately
  in user-facing messages. The core owns output and logging policy.

## Boundary examples

These are links to runnable, tested definitions, not snippets requiring undefined
`Config`, database, or identifier types:

- [`UserError` and `UserId`](../examples/src/error_handling.rs): structured errors
  with a `Display` implementation for the ID and preserved repository sources.
- [`load_user_config` and `parse_user_config`](../examples/src/error_handling.rs):
  synchronous I/O plus useful application context, including lazy path formatting.
  Error context does not require introducing an async runtime.
- [`process_user_request`](../examples/src/error_handling.rs): typed lookup errors
  gain context at an application boundary without logging and re-returning them.
- [`initialize_logger`](../examples/src/error_handling.rs): `try_init()` reports
  initialization failure. `fmt::init()` returns `()` and may panic on repeated
  setup; do not call `.expect()` on that unit value. Global setup belongs to the
  application, not an unexpected library side effect.

Read the [example guide](../examples/GUIDE.md) for teaching stand-in limitations,
compile-fail examples, and reproducible checks.

## Panic policy

Reserve `panic!`, `unwrap()`, and `expect()` for tests, genuinely impossible states
backed by documented invariants, or deliberate fatal programmer errors. They are
not replacements for handling malformed input, unavailable services, I/O errors,
or other recoverable conditions. An assertion about an invariant must explain why
external input and valid caller behavior cannot violate it.

For a justified production panic, prefer `expect()` with an invariant-focused
message over an unexplained `unwrap()`. Document caller-visible panic conditions
in the contract's `# Panics` section where applicable. Do not turn every possible
failure into a fatal programmer error by naming it one. Review intentional panic
exceptions consistently; a blanket ban would also reject legitimate invariant
checks. Tests may use unwraps to make unexpected setup or assertion failures fail
the test directly.

## Explicit fallback contracts

A default value or sentinel is a different API contract from error propagation.
Use one only when explicitly intended and documented. Distinguish a valid zero,
missing input, malformed input, and forbidden zero when those states matter.
Do not use `.ok()`, `filter_map(Result::ok)`, or `unwrap_or_default()` to silently
hide failures while claiming equivalent validation.

The runnable `imperative::validate_and_parse` and `functional::validate_and_parse`
functions preserve the same missing/malformed/zero/valid distinctions. The
`fallback::parse_user_id_or_default` example intentionally maps invalid input to a
sentinel and names that loss of information. Test these contracts separately;
style alone does not establish equivalence.
