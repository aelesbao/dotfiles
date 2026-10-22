# Rust conventions

A portable agent skill for Rust implementation, debugging, refactoring, and review.
It uses repository policy first, then explicit house defaults for areas such as
error handling and functional style. It does not prescribe application architecture
or require moving binary logic into a library.

Start with [SKILL.md](SKILL.md) for the inspect/change/test/report workflow and
cross-cutting conventions. The description supports skill discovery; this README
does not promise automatic selection, universal enforcement, or host reload behavior.

## Where to read each topic

| Resource | Read it when |
| --- | --- |
| [SKILL.md](SKILL.md) | Beginning Rust work: inspect repository policy, compatibility, scope, and validation needs. |
| [Error handling](references/error-handling.md) | Designing typed errors, adding context, choosing fallbacks, or assessing a deliberate panic. |
| [Async and concurrency](references/async-and-concurrency.md) | Changing runtimes, locks, bounded work, cancellation, or shutdown. |
| [Functional style](references/functional-style.md) | Transforming data or assessing ownership, mutation, allocations, and equivalent behavior. |
| [Review](references/review.md) | Reviewing a change and labeling findings as defect, convention, or nit. Replaces the old checklist. |
| [Example guide](examples/GUIDE.md) | Running the teaching package or distinguishing runnable code, stand-ins, and compile-fail snippets. |
| [Error source](examples/src/error_handling.rs) | Looking for tested typed-error, lazy-context, validation, and logger-setup examples. |
| [Functional source](examples/src/functional_patterns.rs) | Looking for tested transformation, aggregation, deterministic processing, and warning-return patterns. |
| [Async source](examples/src/async_concurrency.rs) | Looking for measured task/work bounds, owned shutdown, cancellation, backpressure, and lock examples. |

## Directory layout

```text
rust-conventions/
├── SKILL.md
├── README.md
├── references/
│   ├── async-and-concurrency.md
│   ├── error-handling.md
│   ├── functional-style.md
│   └── review.md
└── examples/
    ├── .gitignore
    ├── Cargo.toml
    ├── Cargo.lock
    ├── rust-toolchain.toml
    ├── GUIDE.md
    ├── src/
    │   ├── lib.rs
    │   ├── async_concurrency.rs
    │   ├── error_handling.rs
    │   └── functional_patterns.rs
    └── tests/
        ├── fixtures/user.toml
        └── logger_initialization.rs
```

The tree lists maintained files, not ignored Cargo output in `examples/target/`.
The former loose Rust sources and architecture example have been removed; the
examples are now one unpublished Cargo package, not an application framework.

## Filesystem installation

Keep the complete `rust-conventions/` directory together so relative resource
links work. Choose a skill location supported by your agent's documented setup.
Check for an existing file, directory, or symlink before copying or linking; do
not overwrite another installed copy without approval.

For a host whose documented skills directory accepts symlinks, a portable setup
is to link the source directory after checking the destination. Set both paths
explicitly for that host:

```sh
SOURCE=/absolute/path/to/rust-conventions
SKILLS_DIR=/absolute/path/to/host/skills
# Inspect the destination, including dangling symlinks, before creating anything.
ls -ld "$SOURCE" "$SKILLS_DIR"
if [ -e "$SKILLS_DIR/rust-conventions" ] || [ -L "$SKILLS_DIR/rust-conventions" ]; then
    printf '%s\n' 'Destination exists; inspect it and stop.' >&2
else
    ln -s "$SOURCE" "$SKILLS_DIR/rust-conventions"
fi
```

This procedure assumes the source and destination parent already exist. It only
sets up files; it does not verify agent discovery or refresh behavior.

In this dotfiles checkout, the verified local layout is:

```text
~/.claude/skills/rust-conventions -> ../../.agents/skills/rust-conventions
```

You can inspect this filesystem relationship without changing host configuration:

```sh
ls -ld ~/.claude/skills/rust-conventions
readlink ~/.claude/skills/rust-conventions
test -f ~/.claude/skills/rust-conventions/SKILL.md
```

Do not infer invocation commands or reload behavior from the presence of this link.
For another host, consult that host's documentation rather than copying a
host-specific directory assumption into the core skill.

## Contributing and validation

1. Read the repository's instructions and the relevant primary topic reference.
   Keep substantive rules in one place; update navigation when resources move.
2. Preserve the skill name `rust-conventions`. Keep the core focused on workflow
   and defaults (roughly 150-250 lines), with detailed topic guidance in references.
3. Check policy consistency: repository exceptions, documented panic invariants,
   unsafe API versus block explanations, accurate ownership/stdout guidance, and
   stable/unstable feature gates. Check every local link and reconcile the
   directory layout whenever resources change.
4. If examples change, follow [GUIDE.md](examples/GUIDE.md) and run its formatting,
   tests, Clippy, and documentation checks. Preserve MSRV, edition, and pinned
   dependency compatibility; do not install missing prerequisites silently.
5. Validate frontmatter with the sibling skill-creator helper if available:

   ```sh
   # From this skill directory; requires Python 3 and an existing PyYAML install.
   python3 ../skill-creator/scripts/validate_skill.py .
   wc -l SKILL.md
   ```

   The helper checks the portable frontmatter profile, not links, Rust claims,
   discovery, or task quality. Inspect whitespace and actual on-disk layout too.
6. Report changed files, commands actually run, outcomes, and remaining blockers.
   Behavioral comparisons and discovery probes need separate, approved trials;
   keep their artifacts outside the installed skill and do not claim unmeasured
   improvements.

For general API background, see the
[Rust API Guidelines](https://rust-lang.github.io/api-guidelines/). Technical claims
must match the project's tool/dependency versions; house preferences are not
presented as universal community requirements.
