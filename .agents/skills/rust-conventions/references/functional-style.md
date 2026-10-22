# Functional style, ownership, and mutation

## House preference

- Prefer iterator adapters (`map`, `filter`, `flat_map`, `fold`, `collect`) over
  pushing into a mutable buffer, and expression-oriented `match`/`if`.
- Prefer `let` to `let mut`; keep necessary mutation local.
- Break long chains into named intermediate iterators. Naming a step does not
  require collecting it.
- Use a loop when the chain would obscure complex early exits, intertwined state,
  or async coordination. A loop is valid code: in review it is at most a
  convention finding with a concrete readability reason.
- Rewrite only the code the task touches.

## Rewrites must preserve semantics

Check ordering, short-circuiting, errors, ownership, and side effects, and test
both versions on meaningful inputs.

- `collect::<Result<Vec<_>, _>>()` stops at and returns the first error.
  `filter_map(Result::ok)` silently drops errors and continues.
- `fold` returns its initial value on empty input. `reduce` returns `None` and
  keeps the item type as accumulator. `all` on empty input is `true`.
- Adapter order matters: `skip(1).take(5)` keeps up to five items,
  `take(5).skip(1)` at most four.
- Adapters are lazy; an unconsumed `map` does nothing. Closures in `map` return
  values. Put required effects (logging, I/O, shared-state mutation) in explicit
  control flow or `try_for_each`. `inspect` is for temporary debugging.
- Moving a mutation from a loop into a closure does not reduce allocations.

## Ownership follows the API contract

- Borrow (`&str`, `&[T]`) when the function does not keep the value. Take owned
  values when storing, transferring, or consuming them is the contract, even
  without mutation.
- `into_iter()` to move without cloning, `iter()` to share, `iter_mut()` for
  intended in-place changes.
- `impl AsRef<Path>` and similar only when callers benefit.
- Remove unnecessary `.clone()`, but keep a justified clone over complex
  lifetimes. Owned parameters and clones are not defects by themselves.

## Allocation and determinism

- Stream through adapters; collect when the buffer is part of the contract,
  reused, or clearer.
- Iterator syntax alone does not prove a speedup. Profile hot paths first.
- Pass time and randomness in as parameters to logic that must be deterministic.
- Use exact representations for invariants, such as integer cents for money.
- Return warnings or outcomes to the caller instead of printing inside a
  transformation.
