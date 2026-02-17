# Rust Conventions Skill for Claude Code

This skill teaches Claude Code to write Rust following battle-tested conventions used across popular open source projects.

## What This Skill Does

When you ask Claude Code to write Rust code, this skill automatically guides it to:

- ✅ Use proper error handling with `Result<T, E>` and context
- ✅ Follow idiomatic naming conventions
- ✅ Write functional-style code with iterator combinators
- ✅ Structure projects with clean hexagonal architecture
- ✅ Use `tokio` for async with proper concurrency patterns
- ✅ Add comprehensive documentation to public APIs
- ✅ Encode invariants in the type system
- ✅ Avoid common anti-patterns

## Installation

### For Personal Use (All Projects)

Copy this skill to your personal skills directory:

```bash
# Create the directory if it doesn't exist
mkdir -p ~/.claude/skills

# Copy the skill folder
cp -r rust-conventions-skill ~/.claude/skills/rust-conventions
```

### For Project-Specific Use

Copy to your project's skills directory:

```bash
# In your project root
mkdir -p .claude/skills
cp -r rust-conventions-skill .claude/skills/rust-conventions
```

### For Enterprise/Team Use

Your organization admin can install this in the shared enterprise skills location for all team members.

## Usage

### Automatic Invocation

Claude Code automatically uses this skill when you ask Rust-related questions:

```
"Create a new user service with proper error handling"
"Review this Rust code for best practices"
"Refactor this function to be more idiomatic"
"How should I structure my Rust web API?"
```

### Manual Invocation

You can explicitly invoke the skill with a slash command:

```
/rust-conventions - implement a user repository with clean architecture
```

### Example Prompts

**Generate new code:**
```
Create a Rust module for handling user authentication with proper error types
```

**Review existing code:**
```
Review this Rust file and suggest improvements based on best practices
```

**Architectural guidance:**
```
Help me structure a Rust microservice using hexagonal architecture
```

**Refactoring:**
```
Refactor this function to use iterator combinators instead of manual loops
```

## What's Included

```
rust-conventions/
├── SKILL.md                          # Main skill file with all guidelines
├── CHECKLIST.md                      # Code review checklist
├── README.md                         # This file
└── examples/
    ├── error-handling.rs             # Error handling patterns
    ├── hexagonal-architecture.rs     # Clean architecture example
    └── functional-patterns.rs        # Functional programming examples
```

## Key Conventions Enforced

### Code Style
- Run `rustfmt` with nightly toolchain
- Run `clippy` with `-D warnings`
- Follow Rust naming conventions

### Error Handling
- Use `Result<T, E>` for recoverable errors
- Libraries use `thiserror`, binaries use `anyhow`
- Always add context when propagating errors
- Avoid `unwrap()` in production code

### Architecture
- Separate domain, application, and infrastructure layers
- Define ports (traits) at boundaries
- Keep domain pure (no I/O)
- Make dependencies explicit via constructor injection

### Functional Style
- Prefer iterator combinators over manual loops
- Favor expressions over statements with mutation
- Use `Option` and `Result` combinators

### Async
- Always use `tokio` runtime
- Never hold locks across `.await` points
- Use structured concurrency patterns

### Documentation
- All public items have `///` docs
- Include `# Errors`, `# Panics`, `# Safety` sections
- Provide code examples

## Customization

You can customize this skill by editing `SKILL.md`:

1. Add project-specific conventions
2. Adjust error handling patterns for your domain
3. Add examples from your codebase
4. Modify architectural preferences

## Verification

To verify the skill is installed correctly:

```bash
# Check that the skill exists
ls ~/.claude/skills/rust-conventions/SKILL.md

# Start Claude Code in a Rust project
claude-code

# Ask: "What Rust conventions should I follow?"
# Claude should reference the guidelines from this skill
```

## Examples from the Skill

### Error Handling with Context

```rust
use anyhow::{Context, Result};

async fn load_config() -> Result<Config> {
    let content = tokio::fs::read_to_string("config.toml")
        .await
        .context("failed to read config file")?;
    
    toml::from_str(&content)
        .context("failed to parse config")
}
```

### Iterator Combinators

```rust
// Transform, filter, collect in one chain
let active_users: Vec<_> = users
    .into_iter()
    .filter(|user| user.is_active())
    .map(|user| user.name.to_uppercase())
    .collect();
```

### Hexagonal Architecture

```rust
// Domain - pure logic
pub struct User { id: UserId, name: String }

// Application - defines ports
#[async_trait]
pub trait UserRepository {
    async fn find(&self, id: UserId) -> Result<User>;
}

// Infrastructure - implements ports
pub struct PostgresUserRepository { pool: PgPool }

#[async_trait]
impl UserRepository for PostgresUserRepository {
    async fn find(&self, id: UserId) -> Result<User> {
        // database query
    }
}
```

## Troubleshooting

**Skill not being invoked?**
- Check that `SKILL.md` has proper YAML frontmatter
- Verify the file is in the correct directory
- Restart Claude Code

**Want to update the skill?**
- Edit the `SKILL.md` file
- Changes take effect immediately (no restart needed)

**Want to disable the skill temporarily?**
- Rename the folder (e.g., `rust-conventions.disabled`)
- Or remove it from the skills directory

## Contributing

If you find issues or have improvements:

1. Update `SKILL.md` with your changes
2. Add examples to the `examples/` directory
3. Update `CHECKLIST.md` if adding new checks
4. Test with Claude Code to ensure guidelines are followed

## License

These guidelines are based on public conventions from the Rust community and popular open source projects. Feel free to adapt them for your team's needs.

## Resources

- [Official Rust API Guidelines](https://rust-lang.github.io/api-guidelines/)
- [Rust by Example](https://doc.rust-lang.org/rust-by-example/)
- [The Rust Book](https://doc.rust-lang.org/book/)
- [Tokio Documentation](https://tokio.rs/)
- [Effective Rust](https://www.lurklurk.org/effective-rust/)
