# Rust Code Review Checklist

Use this checklist when reviewing or generating Rust code to ensure adherence to conventions.

## Style and Formatting

- [ ] Run `cargo +nightly fmt --all` before commit
- [ ] Run `cargo clippy -- -D warnings` and fix all warnings
- [ ] Naming follows conventions:
  - [ ] Types/Traits/Enums: `UpperCamelCase`
  - [ ] Functions/Variables: `snake_case`
  - [ ] Constants: `SCREAMING_SNAKE_CASE`
- [ ] No name stutter (e.g., `user::UserId` not `user::UserUserId`)

## Error Handling

- [ ] Use `Result<T, E>` for recoverable errors
- [ ] No `unwrap()` or `expect()` in production code (tests OK)
- [ ] Libraries use `thiserror` for domain errors
- [ ] Binaries use `anyhow` for error aggregation
- [ ] Errors have context via `.context()` when propagated
- [ ] Custom error types are descriptive and actionable

## Documentation

- [ ] All public items have `///` documentation
- [ ] Documented: purpose, invariants, failure modes
- [ ] Includes `# Errors` section when returning `Result`
- [ ] Includes `# Panics` section when can panic
- [ ] Includes `# Safety` section for unsafe code
- [ ] Code examples in documentation are runnable

## Ownership and Borrowing

- [ ] Prefer borrowing (`&T`, `&str`) over cloning
- [ ] Accept `&str` not `String` when no mutation needed
- [ ] Accept `impl AsRef<Path>` for flexible path arguments
- [ ] Avoid unnecessary `.clone()` calls
- [ ] Make allocation costs obvious in API

## Functional Style

- [ ] Use iterator combinators instead of manual loops
- [ ] No `let mut vec = Vec::new()` followed by `for` loop to populate
- [ ] Prefer `map`, `filter`, `collect` over manual accumulation
- [ ] Use `fold` or `reduce` for aggregation
- [ ] Use expression-oriented code (minimize `let mut`)
- [ ] Chain Option/Result combinators instead of nested `match`

## Architecture

### Binary Structure
- [ ] `main` only does bootstrapping (config, logging, wiring)
- [ ] `main` delegates to `run()` function immediately
- [ ] Application logic lives in `lib.rs`, not `main.rs`
- [ ] Binary imports from internal library crate

### Library Structure
- [ ] Clear separation: `domain` → `app` → `infra`
- [ ] Domain has no external dependencies (no I/O, no async)
- [ ] Traits define ports at domain/app boundary
- [ ] Infrastructure implements traits
- [ ] Dependencies explicit via constructor injection
- [ ] No global state, no singletons

## Type Safety

- [ ] Use newtypes for domain concepts (not primitive types)
- [ ] Use enums over boolean flags for state
- [ ] Leverage `NonZeroUsize`, `NonZeroU64` when zero is invalid
- [ ] Use `Option<T>` when absence is meaningful
- [ ] Make illegal states unrepresentable
- [ ] No stringly-typed design

## Async/Concurrency

- [ ] Using `tokio` runtime (not async-std)
- [ ] Functions marked `async` only when they actually await
- [ ] **Never hold locks across `.await`** (causes deadlocks)
- [ ] Use `tokio::select!` for coordination
- [ ] Use `JoinSet` for bounded task spawning
- [ ] Prefer channels over shared mutable state

## Logging

- [ ] No `println!` in production code
- [ ] Using `tracing` crate for structured logging
- [ ] `#[instrument]` on key functions
- [ ] Appropriate log levels:
  - `error`: unrecoverable errors (500s, thread exits)
  - `warn`: recoverable errors (400s, invalid input)
  - `info`: important events
  - `debug`: execution steps with variables
  - `trace`: verbose details (not for production)
- [ ] Fields attached to spans/events

## Testing

- [ ] Unit tests for pure logic
- [ ] Integration tests for public APIs
- [ ] Tests are deterministic (no random values, control time)
- [ ] Tests don't rely on implementation details
- [ ] Mock external dependencies via traits

## Unsafe Code

- [ ] Unsafe code has clear justification (performance, FFI, low-level)
- [ ] Unsafe blocks are minimal
- [ ] Invariants documented with `# Safety`
- [ ] Tests would catch invariant violations

## Dependencies

- [ ] Dependency graph is minimal
- [ ] No unnecessary feature flags enabled
- [ ] Purpose of major dependencies documented
- [ ] No duplicate dependencies (check `cargo tree`)

## Module Visibility

- [ ] Default to private
- [ ] Only `pub` what's needed
- [ ] Use `pub(crate)` for internal visibility
- [ ] Curated public API re-exported from `lib.rs`

## Performance Considerations

- [ ] Avoid allocations in hot paths
- [ ] Use iterator chains to avoid intermediate collections
- [ ] Consider `&str` over `String`, `&[T]` over `Vec<T>`
- [ ] Profile before optimizing (don't guess)

## Common Anti-Patterns to Avoid

- [ ] ❌ Using `unwrap()` in production code
- [ ] ❌ Returning `String` for simple errors (use proper error types)
- [ ] ❌ Manual loops to filter/map/collect
- [ ] ❌ Holding locks across `.await`
- [ ] ❌ Global mutable state
- [ ] ❌ Deep module hierarchies exposed publicly
- [ ] ❌ Boolean flags instead of enums for state
- [ ] ❌ `println!` for logging
- [ ] ❌ Business logic in `main.rs`
- [ ] ❌ Domain code doing I/O

## Before Submitting

- [ ] `cargo fmt` (nightly)
- [ ] `cargo clippy -- -D warnings` (passes)
- [ ] `cargo test` (all tests pass)
- [ ] `cargo doc --no-deps --open` (docs look correct)
- [ ] No compiler warnings
- [ ] Added/updated tests for new functionality
- [ ] Updated public documentation
