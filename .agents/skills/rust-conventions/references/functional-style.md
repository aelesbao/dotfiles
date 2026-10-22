# Functional style, ownership, and mutation

Read this reference when transforming collections, simplifying branching,
reviewing allocation/ownership, or comparing implementation styles.

## Prefer functional style, with readable steps

Prefer functional style as much as possible: iterator adapters for transformations
and expression-oriented code for decisions. Use `map`, `filter`, `flat_map`,
`collect`, `fold`, and `reduce` instead of manually mapping/filtering into a mutable
buffer where the transformation remains readable. Prefer `let` to `let mut` unless
mutation is needed; keep necessary mutation local.

Break long transformations into reasonable steps with named intermediate
variables. A roughly ten-line transformation is a cue to review readability, not
a hard limit. Name intermediate **iterators** when useful; naming a step does not
require collecting it into a temporary `Vec`.

Use loops only when the functional version would introduce substantially
harder-to-read inference or control flow, such as complex early exits, intertwined
state transitions, or async coordination. A valid loop is not a correctness defect.
Explain a house-style suggestion as a preference with a concrete readability
reason, not as a compiler or performance fix. Do not rewrite unrelated loops.

Expression-oriented `match`, `if`, and `if let` remain useful; combinators should
clarify the control flow, not hide it. Use `Option`/`Result` adapters (`map`,
`and_then`, `ok_or_else`, `unwrap_or_else`) when they make the contract clearer.
Use lazy closures for expensive fallback construction; do not confuse a default
value with a preserved error.

## Preserve semantics before comparing style

A functional rewrite must preserve ordering, short-circuiting, errors, ownership,
and relevant side effects. Test both alternatives on meaningful inputs rather
than assuming visually similar expressions are equivalent.

- `.collect::<Result<Vec<_>, _>>()` preserves the first error and short-circuits;
  `.filter_map(Result::ok)` discards errors and continues. Use the latter only
  when that loss is explicitly the intended contract.
- `fold` starts from an explicit accumulator and handles empty input with that
  initial value. `reduce` uses the input item type as its accumulator and returns
  `None` for an empty iterator. Define empty-input behavior explicitly.
- Adapter order matters: `skip(1).take(5)` skips one item and keeps up to five;
  `take(5).skip(1)` can keep at most four.
- Iterator adapters are lazy. An unconsumed `map` does no processing; do not use it
  to disguise effects. Keep transformation closures focused on returned values.
- Do not hide logging, I/O, or unrelated shared-state mutation inside `map`.
  `inspect` can help temporary debugging, but should not carry required business
  effects. Make intentional sequential effects explicit through clear control
  flow or a suitable fallible adapter such as `try_for_each`.
- Mutating an owned item and returning it from `map` can be a readable localized
  transformation. Moving the same mutation from a loop into a closure does not
  inherently reduce allocations or make the loop incorrect.

Read [error handling](error-handling.md) when changing fallback, validation, or
error-preservation behavior; its panic policy also applies inside closures.

## Ownership follows the API contract

Borrow when ownership is unnecessary, not merely when mutation is unnecessary.
Prefer `&str` and `&[T]` for borrowed text and slices; use `&mut T` for intended
in-place updates. Accept owned values when storing, transferring, or consuming
them is part of the API contract, even if the function never mutates them.

For example, a function computing a name's length can accept `&str`; a function
storing the name may appropriately accept `String`. A consuming transformation
can use `into_iter()` to move values without cloning. Use `iter()` for shared
borrows and `iter_mut()` for intentional in-place changes.

Choose `impl AsRef<Path>` or `impl AsRef<str>` when accepting multiple input forms
actually helps callers, not as a mandatory abstraction. Avoid unnecessary
`.clone()` calls, but do not complicate lifetimes solely to remove a justified
clone. Do not label all owned parameters or clones as defects.

## Allocation and deterministic processing

Prefer streaming adapters to unnecessary intermediate collections. Collect when
a buffer is part of the contract, needed for reuse, or makes the work clearer.
Keep material allocation costs visible in the API or documentation when relevant.
Do not claim iterator syntax alone guarantees an allocation or speed improvement;
profile relevant hot paths before optimizing.

Pass time and randomness into processing that must be deterministic. Use suitable
representations for invariants (for example integer cents rather than floating
point for the teaching discount calculation). Return warnings or other outcomes
for the caller to handle rather than printing as a hidden transformation effect.

## Checked examples

Read the [example guide](../examples/GUIDE.md) before copying patterns. Its
combinator table covers selection, aggregation, partitioning, search, and fallible
collection. [The functional source](../examples/src/functional_patterns.rs)
contains sibling `imperative` and `functional` implementations with equivalence
and boundary tests. The imperative versions are valid alternatives, not negative
compile examples. Concrete order/rule types are teaching stand-ins, not a required
application structure.
