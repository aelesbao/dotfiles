# Error handling

## Error types

- `Result<T, E>` for recoverable failures; `Option` only for meaningful absence.
- House default: `thiserror` for library error types, `anyhow` for binary error
  aggregation. Keep an existing approach (hand-written errors, another crate,
  no-std, strict dependency policy) when the task does not redesign errors.
- Libraries keep typed public errors. Convert to `anyhow` at the application
  boundary, not inside library code.
- Variants are actionable distinctions callers can match. Preserve typed sources
  with `#[source]` or `#[from]` so callers never parse display strings. Avoid
  `#[from]` that couples a public API to an internal dependency.

## Context at boundaries

Add context where it names the failed operation or a safe resource such as a
path. Plain `?` is right when the error already says enough.

```rust
use anyhow::{Context, Result};
use std::path::Path;

fn load_port(path: &Path) -> Result<u16> {
    let text = std::fs::read_to_string(path)
        // Lazy: format! runs only on failure.
        .with_context(|| format!("reading {}", path.display()))?;
    // Static message: plain .context().
    text.trim().parse().context("parsing port")
}
```

Use `.with_context(|| format!(..))` for any allocated message; `.context()` is
for static strings.

Global logger setup belongs to the binary and is fallible:

```rust
// fmt::init() returns () and panics if a subscriber is already set.
tracing_subscriber::fmt().try_init().map_err(|e| anyhow::anyhow!(e))?;
```

## Panics

`panic!`, `unwrap()`, and `expect()` are for tests, documented impossible states,
and deliberate fatal programmer errors. Malformed input, I/O, and unavailable
services are recoverable and return errors.

For a justified production panic, use `expect("why this cannot happen")` stating
the invariant, and list caller-visible panics under `# Panics`. Tests may unwrap
freely.

## Fallbacks are a different contract

A default or sentinel value replaces error propagation, so use one only when the
caller explicitly wants that and the function's name or docs say so. Keep
missing, malformed, and forbidden values distinct when callers care.
`.ok()`, `filter_map(Result::ok)`, and `unwrap_or_default()` discard errors;
using them is a contract change, never a refactor.
