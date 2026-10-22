# Checked Rust teaching examples

This is one unpublished Cargo package, not an application framework. Repository
instructions take precedence over the skill's defaults. Topic modules expose
teaching functions so readers can navigate sibling alternatives by name; this is
not a recommendation to expose an application's entire module tree.

- `src/error_handling.rs`: typed library errors (`thiserror`), application error
  aggregation (`anyhow`), lazy allocated context, explicit fallback policy,
  equivalent positive-ID validation styles, and fallible logger setup.
- `src/functional_patterns.rs`: transformations, integer-cent discounts,
  validation, deterministic order processing, aggregation, flattening,
  partitioning, and sequential rules with returned warnings.
- `src/async_concurrency.rs`: a finite-batch runner with explicit task admission,
  typed worker/join/shutdown errors, abort-and-await cleanup, and safe span fields.
  Gated tests also demonstrate peak active work, admitted-to-reaped task bounds,
  cancellation, bounded-channel pressure/draining, lock lifetimes, and blocking
  work's cancellation limits.
- `tests/`: a config fixture and an isolated-process logger test.

All Rust in the source modules is runnable and tested. `imperative` examples are
valid alternatives, **not defects**. `functional` is the house style where it
stays readable. There is no allocation-performance claim for moving mutation
inside `map`; order processing also demonstrates consuming ownership deliberately.
The concrete repository, rule, payment-error and config types are **teaching
stand-ins/sketches**, not production persistence, pricing, payment, or validation
frameworks. The error/functional topics remain synchronous; they do not need
SQL, networking, an async runtime, or architecture layers. The async topic uses
Tokio only where concurrency is the lesson, preserving the caller's runtime.
Real systems should avoid exposing sensitive input in error messages; the example
email strings and numeric IDs are non-secret test data.

## Reproducible checks

The installed fixed toolchain and declared MSRV are Rust 1.89.0 (edition 2024).
Direct dependencies are exact-pinned and `Cargo.lock` pins the full graph. `serde`
and `toml` support the real config parsing lesson; `tracing-subscriber` supports
fallible initialization. Only its formatting/std features are needed. Offline
preflight selected cached Tokio `=1.48.0` (`macros`, `rt`, `sync`, `time`) and
tracing `=0.1.44` (`attributes`, `std`) for the async lesson. Tokio's selected
version requires Rust 1.71; tracing requires Rust 1.65, both below this package's
MSRV. No multithread-runtime or networking features are needed. Do not silently
install toolchains, components, or dependencies. From this directory:

```sh
cargo +nightly fmt --all
cargo +nightly fmt --all -- --check
cargo test --offline --locked
cargo clippy --offline --locked --all-targets -- -D warnings
RUSTDOCFLAGS="-D warnings" cargo doc --offline --locked --no-deps
```

Nightly is used for formatting only; compilation and tests use the pinned
`rust-toolchain.toml`. If prerequisites are missing, report them before fetching.
The async runner's public doctest is runnable. Its cap includes completed tasks
until reaped, while a separate atomic counter measures active workers. It returns
the first observed failure after aborting and awaiting remaining tasks; secondary
cleanup failures do not replace it. Shutdown uses immediate abort-and-await, not a
grace period or rollback. For settled cleanup, signal shutdown and await the
runner instead of dropping its future. Inputs/results remain batch-sized, and
workers' independently spawned children or already-running blocking work are not
covered by the cap or abort policy. For runtime preservation, cancellation
safety, graceful draining, and versioned API sources, read the parent skill's
`references/async-and-concurrency.md` through its core or README navigation.

## Combinators quick reference (replaces old example 10)

| Operation | Adapter | Meaning / constraint |
| --- | --- | --- |
| Transform | `map` | One output per input; keep diagnostics out of the transformation. |
| Select | `filter` | Keep matching elements. |
| Optional transform | `filter_map` | Keep `Some`; using `.ok()` here deliberately discards errors. |
| Flatten | `flat_map` | Turn each element into an iterator, then flatten. |
| Aggregate | `fold` | Accumulate from an explicitly typed initial value, even when empty. |
| Optional aggregate | `reduce` | Same input/accumulator type; returns `None` when empty. |
| Separate | `partition` | Split by a predicate in one pass. |
| Search | `find`, `any`, `all` | Short-circuit; `all` on empty input is `true`. |
| Slice a stream | `skip(1).take(5)` | Skip one, then keep at most five; order matters. |
| Collect fallibly | `collect::<Result<Vec<_>, _>>()` | Stop at the first error, preserving it. |

## Intentionally invalid examples

These negative examples are isolated as `compile_fail` doctests. They must not
be copied into runnable modules. Error policy and style contrasts elsewhere are
valid code, not compile errors.

A reduction cannot change an `f64` accumulator into `Stats`:

```compile_fail,E0610
let values = vec![1.0_f64, 2.0];
let _ = values.into_iter().reduce(|stats, value| stats.total + value);
```

`fmt::init()` returns `()`, not a fallible result; use `try_init()` instead:

```compile_fail,E0599
tracing_subscriber::fmt::init().expect("logger initialization failed");
```

Do not erase a parse error and then pretend it still has the declared error type:

```compile_fail,E0308
fn parse(input: Option<&str>) -> Result<u32, String> {
    input.ok_or("missing")?.parse::<u32>().map_err(|_| "invalid")
}
```

A panicking parser is deliberately **not** offered as a positive implementation:
`input.parse::<u64>().unwrap()` compiles, but panics on malformed input. See the
fallible sibling and explicit sentinel fallback, which have different contracts.
