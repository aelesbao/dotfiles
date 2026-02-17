---
name: rust-conventions
description: Battle-tested Rust coding conventions and architectural patterns. Use when writing, reviewing, or refactoring Rust code, creating new Rust projects, debugging Rust issues, or when the user asks about Rust best practices, project structure, error handling, async patterns, testing, or code design. Apply these conventions to all Rust code generation and analysis tasks.
---

# Rust Conventions

These guidelines reflect battle-tested conventions used across popular Rust open source projects. Apply them to all Rust code you write, review, or refactor.

## Code Style Guidelines

### Formatting and Linting

**Critical Requirements:**
- **ALWAYS run `rustfmt` on generated code** using nightly toolchain: `cargo +nightly fmt --all`
- **ALWAYS run `clippy` with `-D warnings`** to treat warnings as errors in CI
- After generating code, recommend the user run these tools

### Naming Conventions

Follow Rust API conventions strictly:

- **Types, traits, enums:** `UpperCamelCase`
- **Functions, methods, modules, variables:** `snake_case`
- **Constants, statics:** `SCREAMING_SNAKE_CASE`
- **Use descriptive names** - avoid abbreviations unless domain-standard
- **Avoid stutter** - `user::UserId` instead of `user::UserUserId`

Design APIs to feel idiomatic and composable, mirroring patterns in `serde`, `tokio`, `tracing`, and the standard library.

### Error Handling

Model failures explicitly. Keep panics exceptional.

**Core Principles:**
- Use `Result<T, E>` for recoverable failures
- Reserve `panic!`, `unwrap()`, and `expect()` for:
  - Tests
  - Truly impossible states with documented invariants
  - Fatal programmer errors

**Common Error Patterns:**

**For Libraries:**
```rust
// Define domain-specific errors with thiserror
use thiserror::Error;

#[derive(Error, Debug)]
pub enum UserError {
    #[error("user not found: {0}")]
    NotFound(UserId),
    #[error("invalid email format")]
    InvalidEmail,
    #[error("database error")]
    Database(#[from] sqlx::Error),
}
```

**For Binaries:**
```rust
// Aggregate errors with anyhow
use anyhow::{Context, Result};

fn load_config() -> Result<Config> {
    let content = std::fs::read_to_string("config.toml")
        .context("failed to read config file")?;
    toml::from_str(&content)
        .context("failed to parse config")
}
```

**Always add context when propagating errors:**
```rust
// Good - provides context
db.get_user(id)
    .await
    .context("failed to fetch user from database")?;

// Bad - no context
db.get_user(id).await?;
```

### Clippy Configuration

- Run `clippy` in CI with `-D warnings`
- Do NOT blindly enable `clippy::restriction` group
- Cherry-pick lints that reflect intentional policy
- Use `#[allow]` sparingly and document why deviations are justified

### Module Layout and Visibility

**Core Principles:**
- Keep modules cohesive and focused
- **Default to private** - do not add visibility modifiers first
- Widen to `pub(crate)` or `pub` only when required
- Re-export a curated public API from `lib.rs` instead of exposing deep module trees
- Maintain clear architectural layering to prevent circular dependencies

**Example Library Structure:**
```rust
// lib.rs - curated public API
pub use domain::{User, UserId};
pub use app::UserService;

mod domain;
mod app;
mod infra;
```

### Ownership, Borrowing, and Allocation

**Prefer borrowing over cloning:**
```rust
// Good - borrows
fn process_name(name: &str) { ... }

// Bad - unnecessary allocation
fn process_name(name: String) { ... }
```

**Avoid unnecessary allocations:**
- Accept `&str` or `impl AsRef<str>` when mutation is not required
- Prefer iterator chains over intermediate `Vec` buffers
- Make allocation costs obvious in naming or documentation

**Example - Iterator chains avoid allocations:**
```rust
// Good - no intermediate allocation
let result: Vec<_> = items
    .iter()
    .filter(|x| x.is_valid())
    .map(|x| x.value())
    .collect();

// Bad - unnecessary intermediate Vec
let filtered: Vec<_> = items.iter().filter(|x| x.is_valid()).collect();
let result: Vec<_> = filtered.iter().map(|x| x.value()).collect();
```

### Trait Usage and Generics

- Use generics to encode invariants and enable reuse, not for abstraction's sake
- Prefer `impl Trait` in argument and return positions when it improves readability
- Use `where` clauses for complex bounds
- Avoid deep trait bound nesting that reduces clarity

**Example:**
```rust
// Good - clear and readable
pub fn process<T>(items: impl Iterator<Item = T>) -> Vec<T>
where
    T: Clone + Debug,
{
    // ...
}

// Avoid - overly complex nesting
pub fn process<T, I, F>(items: I, filter: F) -> Vec<T>
where
    I: Iterator<Item = T>,
    T: Clone + Debug + PartialEq,
    F: Fn(&T) -> bool + Clone,
{
    // ...
}
```

### Documentation Standards

**ALL public items MUST have `///` documentation.**

**Document:**
- Purpose of the item
- Invariants that must be maintained
- Failure modes (when applicable)
- Performance characteristics if relevant

**Use explicit sections:**
```rust
/// Fetches a user from the repository.
///
/// # Errors
///
/// Returns `UserError::NotFound` if the user doesn't exist.
/// Returns `UserError::Database` if the database query fails.
///
/// # Example
///
/// ```
/// let user = repo.get_user(user_id).await?;
/// ```
pub async fn get_user(&self, id: UserId) -> Result<User, UserError> {
    // ...
}
```

**For unsafe code, always include `# Safety` section:**
```rust
/// # Safety
///
/// The caller must ensure that `ptr` points to a valid `User` instance
/// and that no other references to this memory exist.
pub unsafe fn from_raw(ptr: *mut User) -> User {
    // ...
}
```

### Testing Conventions

- Write small, focused unit tests close to the code
- Use integration tests for public API boundaries
- Prefer deterministic tests - control randomness and time
- Use property testing for invariants where appropriate
- Avoid testing implementation details

**Example:**
```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_user_creation() {
        let user = User::new("alice", "alice@example.com");
        assert_eq!(user.name(), "alice");
        assert_eq!(user.email(), "alice@example.com");
    }

    #[tokio::test]
    async fn test_user_repository() {
        let repo = MockUserRepository::new();
        let user = repo.get_user(UserId::new(1)).await.unwrap();
        assert_eq!(user.name(), "test_user");
    }
}
```

### Async and Concurrency

**Critical Rules:**
- **ALWAYS use `tokio` for async execution** (not async-std or others)
- Do NOT mark functions `async` unless they actually await
- **NEVER hold locks across `.await`** points - this causes deadlocks
- Prefer structured concurrency

**Structured Concurrency Patterns:**
```rust
// Good - use tokio::select! for coordination
tokio::select! {
    result = task1 => handle_result(result),
    _ = shutdown.recv() => return Ok(()),
}

// Good - use JoinSet for bounded task spawning
let mut set = JoinSet::new();
for item in items {
    set.spawn(async move { process(item).await });
}
while let Some(result) = set.join_next().await {
    handle_result(result?)?;
}

// Avoid - unbounded task spawning
for item in items {
    tokio::spawn(async move { process(item).await });
}
```

**Prefer channels over shared mutable state:**
```rust
// Good - message passing
let (tx, mut rx) = tokio::sync::mpsc::channel(32);
tokio::spawn(async move {
    while let Some(msg) = rx.recv().await {
        handle(msg).await;
    }
});

// Avoid - complex shared state with locks
let state = Arc::new(Mutex::new(HashMap::new()));
```

### Logging and Observability

**Rules:**
- **NEVER use `println!` in production code**
- Use `tracing` crate for structured logging in services and async systems
- Instrument logical operations with spans
- Attach relevant fields to events

**Log Levels:**
- `error`: Unrecoverable errors that halt execution (500 errors, thread exits)
- `warn`: Recoverable errors or unexpected conditions (400 errors, invalid parameters)
- `info`: Important events
- `debug`: Function execution steps with relevant variables
- `trace`: Verbose details (should not be enabled in production)

**Example:**
```rust
use tracing::{info, debug, error, instrument};

#[instrument(skip(db), fields(user_id = %id))]
async fn get_user(db: &Database, id: UserId) -> Result<User> {
    debug!("fetching user from database");
    
    match db.query_user(id).await {
        Ok(user) => {
            info!(user_name = %user.name(), "user fetched successfully");
            Ok(user)
        }
        Err(e) => {
            error!(error = %e, "failed to fetch user");
            Err(e)
        }
    }
}
```

### Unsafe Code Policy

- **Avoid `unsafe` unless it provides clear value** (performance, FFI, low-level primitives)
- If used:
  - Keep unsafe blocks minimal
  - Document invariants locally with `# Safety` comments
  - Add tests that would fail if invariants are broken

### Cargo and Repository Hygiene

- Use a Cargo workspace for multi-crate repositories
- Keep the dependency graph minimal and intentional
- Avoid enabling unnecessary feature flags
- Do not depend on broad, all-in-one crates when narrower alternatives exist
- Document the purpose of major dependencies
- Regularly audit dependencies for redundancy

## Functional Programming Guidelines

### Prefer Iterator Combinators Over Manual Loops

**Always prefer iterator adapters instead of explicit loops with mutable buffers.**

**Avoid:**
```rust
let mut out = Vec::new();
for item in items {
    if predicate(item) {
        out.push(transform(item));
    }
}
```

**Prefer:**
```rust
let out: Vec<_> = items
    .into_iter()
    .filter(|item| predicate(item))
    .map(|item| transform(item))
    .collect();
```

**Key Point:** Do not loop over iterators to manually map, filter, or reduce into a `mut Vec<T>`. Use `iter()`, `into_iter()`, `map`, `filter`, `fold`, `flat_map`, `collect`, etc.

### Favor Expressions Over Statements

- Prefer expression-oriented code
- Minimize mutable state
- Use `match`, `if let`, and combinators like `map`, `and_then`, `ok_or` instead of imperative branching

**Avoid:**
```rust
let value;
if let Some(v) = opt {
    value = transform(v);
} else {
    value = default();
}
```

**Prefer:**
```rust
let value = opt.map(transform).unwrap_or_else(default);
```

### Prefer Immutability by Default

- Bind variables with `let`, not `let mut`, unless mutation is required
- Keep mutation localized and minimal
- Avoid reassigning variables when expressions can produce new values

### Use Option and Result Combinators

Prefer chaining over nested matching when it improves clarity:

```rust
let result = input
    .parse::<u32>()
    .ok()
    .filter(|n| *n > 0)
    .ok_or(MyError::InvalidInput)?;
```

**Common Combinators:**
- `map` - transform the value inside
- `and_then`/`flat_map` - chain operations that return Option/Result
- `filter` - keep only values matching a predicate
- `ok_or`/`ok_or_else` - convert Option to Result
- `unwrap_or`/`unwrap_or_else` - provide defaults

### Avoid Side Effects Inside Iterator Chains

Iterator chains should be declarative. Avoid mixing mutation and logic in `map` closures.

**Avoid:**
```rust
// Bad - side effect in iterator
items.iter().map(|x| {
    println!("Processing {}", x); // side effect
    x * 2
}).collect()
```

Use `inspect` only for debugging, not production logic.

### Balance Readability

Functional style is preferred when it improves clarity and reduces mutation. **Do not force dense combinator chains when a simple loop is clearer.**

The goal is not abstraction, but **correctness, composability, and minimal state.**

## Code Design and Architectural Patterns

### Binary Structure

Binaries are composition layers. They assemble the system but **do not implement core logic.**

#### `main` is for Bootstrapping

The `main` function is an orchestration boundary. It **must not contain business logic.**

**Typical responsibilities:**
- Parse CLI arguments
- Load configuration
- Initialize logging and tracing
- Construct top-level services
- Start runtime components (HTTP servers, background workers)
- Handle graceful shutdown

**Pattern:**
```rust
// main.rs
#[tokio::main]
async fn main() -> anyhow::Result<()> {
    // Initialize tracing
    tracing_subscriber::fmt::init();

    // Load config
    let config = Config::load()?;

    // Delegate to run function
    run(config).await
}

async fn run(config: Config) -> anyhow::Result<()> {
    // Application logic here
    Ok(())
}
```

**Keep `main` minimal.** Move all logic into library code. The smaller `main` is, the smaller the test "dead zone" surface area.

#### Binaries are First-Class Consumers of the Internal Library

- Treat the binary as a consumer of your own library crate
- **Do NOT define application modules inside `main.rs`**
- Place application logic in `lib.rs` and submodules
- Import and compose functionality from the library into the binary

**Example Structure:**
```
my-app/
├── Cargo.toml
├── src/
│   ├── lib.rs          # Application logic lives here
│   ├── domain/
│   ├── app/
│   ├── infra/
│   └── main.rs         # Thin orchestration layer
```

```rust
// lib.rs
pub mod domain;
pub mod app;
pub mod infra;

pub use app::run;

// main.rs
use my_app::run;

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    run().await
}
```

This enforces separation of concerns, improves testability, and enables reuse.

### Library Architecture

Libraries must enforce clear dependency direction and isolate domain logic from infrastructure concerns.

#### Separate Domain from Infrastructure

Adopt a minimal hexagonal structure:

**Layers:**
1. **`domain`** - Pure business logic. No external IO. No framework dependencies.
2. **`app`** - Use cases. Coordinates domain and ports.
3. **`infra`** - Concrete implementations of external systems (databases, HTTP clients, filesystem, message brokers)

**Dependency Rule:**
- `domain` depends on **nothing**
- `app` depends on `domain`
- `infra` depends on `app` and `domain`

Define traits at the domain boundary. Implement infrastructure adapters separately.

#### Use Traits as Ports

Define behavior as traits in the domain or application layer.

**Example:**
```rust
// domain/user.rs
pub trait UserRepository {
    async fn find(&self, id: UserId) -> Result<User, UserError>;
    async fn save(&self, user: User) -> Result<(), UserError>;
}

// infra/postgres_user_repository.rs
pub struct PostgresUserRepository {
    pool: PgPool,
}

#[async_trait]
impl UserRepository for PostgresUserRepository {
    async fn find(&self, id: UserId) -> Result<User, UserError> {
        // database logic
    }

    async fn save(&self, user: User) -> Result<(), UserError> {
        // database logic
    }
}
```

**Guidelines:**
- Traits define contracts
- Implementations live at the edges
- Avoid leaking infrastructure types into domain logic

#### Make Dependencies Explicit

- **Inject dependencies explicitly via constructors**
- Avoid global state
- Avoid implicit singletons
- Avoid hidden dependencies
- Avoid thread-local coupling

**Example:**
```rust
// Good - explicit dependencies
pub struct UserService {
    repository: Arc<dyn UserRepository>,
    email_service: Arc<dyn EmailService>,
}

impl UserService {
    pub fn new(
        repository: Arc<dyn UserRepository>,
        email_service: Arc<dyn EmailService>,
    ) -> Self {
        Self { repository, email_service }
    }

    pub async fn register_user(&self, name: &str, email: &str) -> Result<User> {
        let user = User::new(name, email);
        self.repository.save(user.clone()).await?;
        self.email_service.send_welcome(email).await?;
        Ok(user)
    }
}
```

Constructor injection is preferred over mutable global configuration.

#### Prefer Composition Over Inheritance-Style Patterns

Rust does not support inheritance. **Do not simulate it.**

- Use traits to express behavior
- Compose structs instead of building deep abstraction hierarchies
- Avoid trait objects unless dynamic dispatch is required

Favor explicit wiring over hidden coupling.

#### Keep Domain Pure

**Domain functions should NOT perform I/O.**

- Avoid side effects inside core logic
- Avoid `async` unless inherent to the domain
- Avoid framework types
- Push I/O to the outer layers
- Avoid logging side effects in domain code

Domain types should be simple structs, enums, and pure functions. This keeps business logic testable and deterministic.

**Example:**
```rust
// domain/order.rs - Pure logic
pub struct Order {
    id: OrderId,
    items: Vec<OrderItem>,
    status: OrderStatus,
}

impl Order {
    pub fn new(items: Vec<OrderItem>) -> Self {
        Self {
            id: OrderId::generate(),
            items,
            status: OrderStatus::Pending,
        }
    }

    pub fn total(&self) -> Money {
        self.items.iter().map(|item| item.price()).sum()
    }

    pub fn confirm(&mut self) -> Result<(), OrderError> {
        if self.items.is_empty() {
            return Err(OrderError::EmptyOrder);
        }
        self.status = OrderStatus::Confirmed;
        Ok(())
    }
}
```

#### Minimize Public Surface Area

- Expose only what must be public
- Re-export intentionally from `lib.rs`
- Keep internal modules private

A small API surface improves maintainability and evolution.

**Example:**
```rust
// lib.rs - Curated public API
pub use domain::{User, UserId, Order, OrderId};
pub use app::{UserService, OrderService};

// Keep these private
mod domain;
mod app;
mod infra;
```

#### Avoid Over-Engineering

- **Start concrete**
- Avoid premature abstraction
- Do NOT introduce traits, generics, or indirection before they are required
- Extract abstractions when duplication or variation appears
- Keep boundaries explicit but minimal

Architecture should reflect **real complexity, not anticipated complexity.**

#### Encode Invariants in Types

Use the type system to prevent invalid states at compile-time.

**Principles:**
- Model constraints in types, not in runtime checks
- Make illegal states unrepresentable
- Prefer newtypes over primitives
- Use `enum` instead of boolean flags to make states explicit

**Examples:**

**Newtypes for domain concepts:**
```rust
// Good - type safety
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub struct UserId(u64);

impl UserId {
    pub fn new(id: u64) -> Self {
        Self(id)
    }
}

// Bad - primitive obsession
type UserId = u64;
```

**Enums over booleans:**
```rust
// Good - explicit states
pub enum OrderStatus {
    Pending,
    Confirmed,
    Shipped,
    Delivered,
}

// Bad - boolean flags can conflict
struct Order {
    is_confirmed: bool,
    is_shipped: bool,
    is_delivered: bool,
}
```

**Leverage types that encode guarantees:**
```rust
use std::num::NonZeroUsize;

// Good - zero is unrepresentable
pub struct PageSize(NonZeroUsize);

// Good - absence is meaningful
pub struct User {
    id: UserId,
    name: String,
    email: Option<EmailAddress>, // None = email not verified
}
```

**Avoid stringly-typed design:**
```rust
// Bad - structured meaning inside String
pub struct User {
    status: String, // "pending" | "active" | "banned"
}

// Good - use enums
pub enum UserStatus {
    Pending,
    Active,
    Banned,
}

pub struct User {
    status: UserStatus,
}
```

## Code Generation Checklist

When generating Rust code, ensure you:

- [ ] Apply proper naming conventions (snake_case, UpperCamelCase, SCREAMING_SNAKE_CASE)
- [ ] Use `Result<T, E>` for recoverable errors, avoid `unwrap()`
- [ ] Add `///` documentation to all public items with purpose, errors, panics, examples
- [ ] Prefer borrowing (`&str`, `&T`) over cloning
- [ ] Use iterator combinators instead of manual loops
- [ ] Make dependencies explicit via constructor injection
- [ ] Keep domain logic pure (no I/O, no side effects)
- [ ] Use `async`/`await` only with `tokio` runtime
- [ ] Never hold locks across `.await` points
- [ ] Use `tracing` for logging, never `println!`
- [ ] Encode invariants in types (newtypes, enums over booleans)
- [ ] Keep `main` minimal, put logic in `lib.rs`
- [ ] Follow hexagonal architecture (domain → app → infra)
- [ ] Recommend running `cargo fmt` and `cargo clippy` after generation

## Summary

These conventions prioritize:
- **Correctness** - Use the type system to prevent errors
- **Composability** - Build with reusable, well-defined components
- **Clarity** - Write code that clearly expresses intent
- **Testability** - Keep logic pure and dependencies explicit
- **Maintainability** - Minimize public surface, avoid premature abstraction

Follow these guidelines for all Rust code you generate, review, or refactor.
