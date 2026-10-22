# Async and concurrency

Read this when adding or reviewing async execution, spawning, cancellation,
locks, queues, or shutdown. Start with the repository-first workflow in
[the core skill](../SKILL.md); error policy belongs in
[error handling](error-handling.md), readability in
[functional style](functional-style.md), and finding labels in
[review](review.md). This reference is not a runtime-migration instruction.

## Preserve the repository's execution model

Keep an existing runtime and synchronous code unless the task justifies changing
them. Tokio is the house preference for suitable **new** async applications, not
a Rust correctness requirement. Inspect the repository's runtime, MSRV, feature
flags, targets, tests, and dependency policy before choosing APIs. A library
normally returns futures rather than creating a hidden runtime or nesting
`block_on` inside its caller's executor. Do not add async to a synchronous CLI
merely to follow a preference.

The [checked package guide](../examples/GUIDE.md) records exact dependencies and
commands. Its [async module](../examples/src/async_concurrency.rs) is a small,
runnable finite-batch example on a caller-provided Tokio runtime, not a service
framework. Its public `run_bounded` doctest is a runnable entry point. Test-only
channels and simulated transactions illustrate mechanisms, not production I/O.
No snippets here require copying an uncompiled application sketch.

## Tracking, task count, active work, and pressure are different

| Property | What establishes it | What does **not** establish it alone |
| --- | --- | --- |
| Task ownership/tracking | Retain a `JoinHandle`, or own a `JoinSet`, and define how every result is reaped | Spawning a task, then dropping its handle |
| Bounded outstanding tasks | Check an admission cap **before spawning**, counting every admitted task until reaped, including completed tasks | A `JoinSet` with unbounded spawning; a semaphore acquired inside every spawned task |
| Bounded active work | Acquire a permit around precisely the scarce operation; or cap tasks that each run one such operation | Task tracking, if tasks fan out into child tasks or release permits too early |
| Backpressure | Bounded queue plus producers that await admission (or an explicit reject/drop policy) | A bounded queue whose producer spawns unbounded tasks waiting to send |

`JoinSet::len` includes completed-but-unreaped tasks. `run_bounded` checks
`len < limit` before each spawn and measures the largest length immediately
after admission. Its biased select prioritizes join results that poll ready over
new admissions. Cooperative scheduling may defer a completed task's join even
while admission is ready. Each task runs one worker; therefore active workers
are also at most the task cap, **if
workers do not fan out**. A semaphore is not needed for this runner. If active
operations need a different limit, use a separate permit around those operations
without confusing it with the task admission cap.

The tests measure both dimensions, not just output correctness:

- `measures_peak_active_work_separately_from_outstanding_tasks` holds workers on
  a gate, acknowledges three starts at cap three, measures peak active work with
  atomics and drop guards, then releases them and checks all nine results.
- `admission_to_reaping_counts_completed_tasks_not_only_active_work` measures the
  peak admitted-but-unreaped count for 41 immediately completing workers at caps
  one, two, and four. The runner records `JoinSet::len`, not semaphore permits or
  a counter decremented when work finishes. Completed tasks still occupy slots
  until reaped; each test observes a peak exactly equal to its cap.

These are different measurements; neither proves a process-wide memory bound.
This finite-batch API owns input and output vectors proportional to batch size.
For streaming systems also bound pending input, retained results, message size,
and every producer/consumer path. State the scope of any concurrency claim.

`bounded_channel_pressure_and_owned_consumer_shutdown` fills a capacity-one
queue, observes `try_send` returning `Full`, polls `reserve` to establish it is
pending, then cancels that reservation. It retains the consumer in a `JoinSet`,
releases a drain gate, awaits a second send, drops the sender, and awaits the
consumer's complete drain. Producers must not hold a resource needed by consumers
while awaiting capacity; bounded queues can otherwise deadlock too.

## Own tasks and define failure and shutdown behavior

`tokio::spawn` starts independently scheduled work. Dropping its `JoinHandle`
**detaches** it; it does not cancel the task. Awaiting the handle yields a
`Result<T, JoinError>`; when `T` is itself a `Result`, handle both layers. A worker
error is not a panic, and a panic or unexpected cancellation is not a domain
error. Preserve these distinctions instead of using `filter_map(Result::ok)`.

`run_bounded` returns typed `RunError::Worker`, `RunError::Join`, or
`RunError::Shutdown`. The first **observed** failure wins, not necessarily the
first chronologically occurring one. It stops admission, calls `abort_all`, then
awaits joins until the set is empty. Expected cancellation results and secondary
failures during cleanup do not replace the chosen failure. It returns no partial
success report on failure. Its tests acknowledge two running workers before
triggering a domain failure, panic, or shutdown; drop guards establish that the
pending sibling is destroyed before the runner returns, with no further workers
started. Shutdown already ready before admission starts no workers. Empty input
succeeds without polling shutdown; zero is excluded by `NonZeroUsize`.

A shutdown policy usually has these stages:

1. Stop accepting new work and notify producers/owned workers.
2. Finish accepted work or cooperatively stop it according to the operation's
   contract; close senders or receivers intentionally and drain when required.
3. If the grace period expires, abort remaining abortable tasks and **await**
   their termination. Preserve or explicitly aggregate failures at the boundary.

The channel test demonstrates graceful draining. The batch runner deliberately
uses **immediate abort-and-await**, not a grace period or transactional rollback.
Choose a different policy for work that must finish an accepted transaction.
Async destructors cannot await: dropping a `JoinSet` requests abortion but is
not settled cleanup. Signal the runner's shutdown input and await it instead of
dropping its future. A timeout that drops the whole owner is not equivalent to
this shutdown protocol; retain ownership while timing a grace period and perform
cleanup afterward. Abort requests only take effect when async tasks yield, so
CPU loops or blocking calls can prevent termination. A runtime shutdown is not
an application-level guarantee that side effects have completed or rolled back.

## `select!`, future drop, and cancellation safety

`select!` polls branches concurrently on the current task, not in parallel. A
winning branch drops the losing branch futures **owned by that select**. Selecting
on a borrowed pinned future or `&mut JoinHandle` drops the borrow, not the
underlying future/task; its owner must decide what happens next. Dropping a
future stops future polling and runs synchronous drop code; it does not undo
writes, restore consumed input, or stop a separately spawned task.

Cancellation safety is operation-specific: ask what happens if an operation is
partly polled, loses, and is recreated on the next loop iteration. Tokio documents
`mpsc::Receiver::recv` and `JoinSet::join_next` as cancellation-safe: a losing
receive does not consume a message, and a losing join does not remove a task.
In contrast, a partially progressed `read_exact`/`write_all` can lose progress if
recreated. Preserve progress explicitly, use a documented cancellation-safe
operation, or let the operation finish under an owned shutdown policy.

`send(value)` losing a select does not enqueue the value, but drops that owned
value with the send future. Reserve capacity first if the caller must retain a
value on cancellation, and send through the acquired permit without another
await. Cancelling a `reserve`, mutex-lock, or semaphore-acquire wait loses its
place in the fairness queue; being safe for data does not mean preserving queue
position. Avoid accumulating permits across cancellation paths.

Default `select!` branch ordering is randomized for fairness. `biased;` makes
priority explicit, but requires reviewing starvation. The batch runner puts
shutdown first, completion second, admission last. Shutdown wins when multiple
branches are ready; a cancelled `join_next` does not lose a task. For a nonempty
batch, even already-ready shutdown is checked before admission. The
`select_drops_in_progress_future_but_preserves_unreceived_message` test waits for
a future to start, then makes shutdown and receive ready without yielding.
Shutdown deterministically wins, the losing future's guard drops, and the message
remains receivable. Acknowledgments and gates establish ordering; timeouts in
these tests are only deadlock watchdogs, not sleeps used to infer scheduling.

## Blocking operations and cancellation limits

Do not block executor worker threads with synchronous network/file operations,
long CPU work, `std::thread::sleep`, or contended blocking locks. Short bounded
synchronous work may be reasonable; assess whether it prevents other tasks from
making progress. Prefer existing async APIs for I/O. For unavoidable blocking
work, `spawn_blocking` moves a closure to Tokio's blocking pool, but this is not
an unlimited CPU executor: separately cap admissions and active CPU work as
needed, or preserve a repository's dedicated CPU pool.

An already-running `spawn_blocking` closure cannot be aborted. Aborting before it
starts **may** prevent execution; do not rely on that race. Dropping or timing out
its handle does not stop it. Use a cooperative stop flag checked by the closure,
finite I/O deadlines, or another operation-specific interruption mechanism, and
retain/await the handle. If interruption is impossible, document that shutdown
may wait for completion. Runtime `shutdown_timeout` stops waiting, not the work.

`abort_cannot_stop_already_running_spawn_blocking_work` waits for an explicit
started acknowledgment, requests abort, opens a blocking-thread gate, and awaits
the normal result. This demonstrates the cancellation limit rather than promising
that an async task owner can forcibly stop blocking work it started. The runner
does not own workers' independently spawned children or blocking closures.

## Locks: review the guard, not just the type name

Use a blocking mutex for short synchronous data access when appropriate. Keep its
guard in a lexical scope ending **before** any `.await`; extract a snapshot or
complete the update first. Even where a guard happens to be `Send` or a local task
accepts it, blocking while another task needs the same lock can deadlock the
executor. Contention may justify async coordination even for simple data.

An async mutex guard is designed to cross `.await` and may intentionally serialize
access to an async resource/transaction. That is not a blanket prohibition or a
blanket endorsement: keep critical sections short, avoid reentrant lock waits,
review lock ordering and cancellation invariants, and ensure the awaited operation
does not depend on someone acquiring the held lock. Dropping the guard releases
the lock; it does not repair partially mutated protected state. Prefer a single
owning task and messages if that makes resource ownership clearer.

`intentional_async_guard_across_await_and_short_blocking_guard` demonstrates both
lifetimes with a simulated transaction. The async guard stays held across an
acknowledged wait; the test verifies exclusion and releases it through an
independent channel. A separate blocking guard produces a snapshot before an
await. The transaction is a teaching stand-in, not a cancellation-atomic database
transaction.

## Safe observability

Follow the repository's diagnostic system. The runner uses
`#[tracing::instrument(skip_all, fields(limit = limit.get(), item_count = items.len()))]`:
only explicit operational counts are recorded, never worker inputs, closures,
shutdown payloads, credentials, tokens, or outputs. Review whether even counts or
identifiers are sensitive for the actual application. Do not add `Debug` bounds
just to log generic requests. Do not automatically record errors or returns that
may contain secrets. For manually created spans, instrument the future rather
than keeping an entered-span guard across an await.

The runner returns errors without logging them. Log once at the boundary that
actually handles the error, with approved fields and redaction, rather than
logging and returning the same failure at every layer. `skip_all` is an
allowlist starting point, not a guarantee that manually added fields are safe.

## Versioned official API references

These links match the package's **Tokio 1.48.0** and **tracing 0.1.44** pins,
not `latest`. Recheck version/feature/MSRV compatibility when adopting the pattern
elsewhere. The package enables Tokio `macros`, `rt`, `sync`, and `time`; it uses
current-thread tests, not multithread-runtime or networking APIs.

- [JoinSet](https://docs.rs/tokio/1.48.0/tokio/task/struct.JoinSet.html): spawning,
  length including completed tasks, cancellation-safe joining, aborting and drop.
- [spawn](https://docs.rs/tokio/1.48.0/tokio/task/fn.spawn.html),
  [JoinHandle](https://docs.rs/tokio/1.48.0/tokio/task/struct.JoinHandle.html),
  [JoinError](https://docs.rs/tokio/1.48.0/tokio/task/struct.JoinError.html):
  independent task lifetime, detach versus abort, and join failure inspection.
- [select!](https://docs.rs/tokio/1.48.0/tokio/macro.select.html),
  [pin!](https://docs.rs/tokio/1.48.0/tokio/macro.pin.html): branch ordering,
  cancellation-safety table, owned versus pinned futures.
- [mpsc module](https://docs.rs/tokio/1.48.0/tokio/sync/mpsc/index.html),
  [channel](https://docs.rs/tokio/1.48.0/tokio/sync/mpsc/fn.channel.html),
  [Sender](https://docs.rs/tokio/1.48.0/tokio/sync/mpsc/struct.Sender.html),
  [Receiver](https://docs.rs/tokio/1.48.0/tokio/sync/mpsc/struct.Receiver.html):
  queue bounds, reserve/send cancellation, pressure, closure, and draining.
  Test-only unbounded acknowledgment channels have finitely many senders/events;
  they are not the backpressured work-queue example.
- [oneshot](https://docs.rs/tokio/1.48.0/tokio/sync/oneshot/index.html),
  [Semaphore](https://docs.rs/tokio/1.48.0/tokio/sync/struct.Semaphore.html):
  test acknowledgments/gates and permit cancellation behavior.
- [Mutex](https://docs.rs/tokio/1.48.0/tokio/sync/struct.Mutex.html),
  [std Mutex (Rust 1.89)](https://doc.rust-lang.org/1.89.0/std/sync/struct.Mutex.html):
  guard lifetimes and costs.
- [spawn_blocking](https://docs.rs/tokio/1.48.0/tokio/task/fn.spawn_blocking.html),
  [runtime shutdown_timeout](https://docs.rs/tokio/1.48.0/tokio/runtime/struct.Runtime.html#method.shutdown_timeout):
  blocking-pool limits and shutdown semantics.
- [timeout](https://docs.rs/tokio/1.48.0/tokio/time/fn.timeout.html),
  [yield_now](https://docs.rs/tokio/1.48.0/tokio/task/fn.yield_now.html),
  [test](https://docs.rs/tokio/1.48.0/tokio/attr.test.html),
  [main](https://docs.rs/tokio/1.48.0/tokio/attr.main.html): checked test/doctest
  runtime, watchdog, and yield APIs.
- [instrument](https://docs.rs/tracing/0.1.44/tracing/attr.instrument.html),
  [Instrument](https://docs.rs/tracing/0.1.44/tracing/trait.Instrument.html):
  explicit span fields, async spans, and sensitive argument exclusion.
