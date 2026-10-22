# Async and concurrency

## Keep the execution model

Keep the existing runtime and synchronous code unless the task is to change them.
Tokio is the house choice for new async applications. A synchronous CLI stays
synchronous. Libraries return futures; they never create a hidden runtime or
call `block_on` inside a caller's executor. Check APIs against the project's
pinned Tokio version and features on docs.rs.

## Bounds are four different properties

| Property | Established by | Not established by |
| --- | --- | --- |
| Task tracking | Retaining a `JoinHandle` or owning a `JoinSet`, and reaping every result | Spawning and dropping the handle |
| Bounded outstanding tasks | Checking a cap before spawning, counting tasks until reaped | An unbounded spawn loop into a `JoinSet`; a semaphore acquired inside each task |
| Bounded active work | A permit held around exactly the scarce operation | Task tracking, if tasks fan out or release permits early |
| Backpressure | A bounded queue whose producers await capacity, or an explicit reject/drop policy | A bounded queue fed by unbounded tasks waiting to send |

State which property a concurrency claim covers. A task cap is not a memory
bound: also bound pending input, retained results, and message size for streams.

Admission cap with owned cleanup:

```rust
use std::{future::Future, num::NonZeroUsize};
use tokio::task::{JoinError, JoinSet};

pub enum RunError<E> {
    Worker(E),
    Join(JoinError),
}

pub async fn run_bounded<T, R, E, F, Fut>(
    items: Vec<T>,
    limit: NonZeroUsize,
    worker: F,
) -> Result<Vec<R>, RunError<E>>
where
    F: Fn(T) -> Fut,
    Fut: Future<Output = Result<R, E>> + Send + 'static,
    R: Send + 'static,
    E: Send + 'static,
{
    let mut items = items.into_iter();
    let mut tasks = JoinSet::new();
    let mut outputs = Vec::new();
    loop {
        // len() includes completed-but-unreaped tasks: this caps spawn-to-reap.
        while tasks.len() < limit.get() {
            let Some(item) = items.next() else { break };
            tasks.spawn(worker(item));
        }
        let Some(joined) = tasks.join_next().await else {
            return Ok(outputs);
        };
        let failure = match joined {
            Ok(Ok(output)) => {
                outputs.push(output);
                continue;
            }
            Ok(Err(err)) => RunError::Worker(err),
            Err(err) => RunError::Join(err),
        };
        tasks.abort_all();
        // Await every abort so cleanup is settled before returning.
        while tasks.join_next().await.is_some() {}
        return Err(failure);
    }
}
```

For shutdown, add a `biased;` `select!` with the shutdown future first and
`join_next` second.

## Task ownership and shutdown

- Dropping a `JoinHandle` detaches the task; it keeps running.
- Awaiting a handle yields `Result<T, JoinError>`. When `T` is a `Result`, handle
  both layers: a domain error, a panic, and a cancellation are distinct outcomes.
- Shutdown in stages: stop admitting and notify producers; finish or
  cooperatively stop accepted work and drain channels as the contract requires;
  after a grace period, abort and **await** remaining tasks.
- Dropping a `JoinSet` requests aborts but does not wait for them. A timeout that
  drops the owner is not a shutdown. Keep ownership while timing the grace
  period, then clean up.
- Aborts take effect only at `.await` points. CPU loops and blocking calls delay
  them. Aborting never rolls back external side effects.

## `select!` and cancellation safety

- The winning branch drops the losing futures that the `select!` owns. Selecting
  on `&mut fut` or `&mut handle` drops only the borrow.
- Dropping a future stops polling; it does not undo writes or restore consumed
  input.
- Cancellation-safe: `mpsc::Receiver::recv`, `JoinSet::join_next`. Not safe:
  `read_exact`, `write_all` (progress is lost when recreated in a loop).
- A losing `send(value)` drops `value`. To keep it, `reserve()` first, then send
  through the permit without another await.
- Cancelling a `reserve`, lock, or semaphore wait loses queue position.
- Branch order is random by default. `biased;` sets priority explicitly; review
  it for starvation.
- Producers that await capacity must not hold anything consumers need, or a
  bounded queue deadlocks.

## Blocking work

- Keep executor threads free of blocking I/O, long CPU work,
  `std::thread::sleep`, and contended blocking locks. Short bounded sync work is
  fine.
- `spawn_blocking` moves work to the blocking pool. Cap it separately; it is not
  a CPU executor. Keep an existing dedicated CPU pool.
- A running `spawn_blocking` closure cannot be aborted. Dropping or timing out
  its handle does not stop it, and `shutdown_timeout` only stops waiting. Use a
  cooperative stop flag or I/O deadlines, and retain and await the handle.

## Locks

- Blocking mutex: short sync access, guard scoped to end before any `.await`.
  Take a snapshot or finish the update first.
- Async mutex: holding the guard across `.await` is its purpose. Keep critical
  sections short, check lock ordering, and make sure the awaited operation never
  needs the held lock. Dropping the guard does not repair half-updated state.
- An owning task plus messages is often clearer than a shared lock.

## Observability

- `#[instrument(skip_all, fields(...))]` with only safe operational fields such
  as counts. Never record inputs, closures, credentials, or outputs by default.
- Avoid `err`/`ret` capture where values may contain secrets.
- For manual spans, `.instrument(span)` the future instead of holding an entered
  guard across `.await`.
