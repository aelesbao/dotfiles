//! Explicit task admission, cancellation, and owned cleanup on a caller-provided Tokio runtime.
//!
//! The focused runner bounds tasks from admission through reaping, not just active workers.
//! Tests also show channel pressure, lock lifetimes, future drop, and blocking cancellation.

use std::{error::Error, future::Future, num::NonZeroUsize, sync::Arc};

use thiserror::Error;
use tokio::task::{JoinError, JoinSet};

/// Completed outputs and an admission-to-reaping measurement.
#[derive(Debug)]
pub struct RunReport<T> {
    /// Results in completion order, not input order.
    pub outputs: Vec<T>,
    /// Largest number admitted but not yet reaped, including completed tasks.
    pub peak_outstanding: usize,
}

/// The first observed failure; secondary outcomes during cleanup do not replace it.
#[derive(Debug, Error)]
#[non_exhaustive]
pub enum RunError<E: Error + 'static> {
    /// A worker returned a domain error.
    #[error("worker failed")]
    Worker(#[source] E),
    /// A spawned worker panicked or was cancelled unexpectedly.
    #[error("worker task failed")]
    Join(#[source] JoinError),
    /// The caller requested shutdown; all owned tasks have been reaped.
    #[error("shutdown requested")]
    Shutdown,
}

/// Run a finite batch with an explicit cap on admitted-but-unreaped tasks.
///
/// The caller supplies the runtime and a shutdown future (for example, a oneshot
/// receive). A nonzero limit makes invalid admission limits unrepresentable.
/// Shutdown wins when it polls ready. Join results that poll ready take priority
/// over new admissions; cooperative scheduling can defer a completed task's join.
/// Empty input succeeds without polling shutdown.
///
/// ```
/// use std::{future::pending, io, num::NonZeroUsize};
/// use rust_conventions_examples::async_concurrency::run_bounded;
///
/// # #[tokio::main(flavor = "current_thread")]
/// # async fn main() -> Result<(), Box<dyn std::error::Error>> {
/// let report = run_bounded(
///     vec![1, 2, 3],
///     NonZeroUsize::new(2).expect("constant is nonzero"),
///     pending(), // An application can supply a shutdown notification instead.
///     |value| async move { Ok::<_, io::Error>(value * 2) },
/// ).await?;
/// assert_eq!(report.outputs.len(), 3);
/// assert!(report.peak_outstanding <= 2);
/// # Ok(())
/// # }
/// ```
///
/// # Errors
/// Returns the first observed worker, join, or shutdown error after stopping
/// admissions, aborting the remaining async tasks, and awaiting every join.
/// Secondary cleanup outcomes do not replace the first error. Aborting is not a
/// rollback of external side effects. Workers must yield for cleanup to finish;
/// blocking work inside them must have its own ownership/cancellation policy.
///
/// # Cancellation
/// Signal shutdown and await this function for settled cleanup. Dropping its
/// future drops the `JoinSet`, which requests task abortion but cannot await it.
/// The input and result vectors are batch-sized; this is not a bound on memory
/// for an arbitrarily large stream. At most `limit` worker futures run at once.
/// Independently spawned children are outside this cap and this owner's cleanup.
#[tracing::instrument(skip_all, fields(limit = limit.get(), item_count = items.len()))]
pub async fn run_bounded<T, R, E, W, F>(
    items: Vec<T>,
    limit: NonZeroUsize,
    shutdown: impl Future<Output = ()>,
    worker: W,
) -> Result<RunReport<R>, RunError<E>>
where
    T: Send + 'static,
    R: Send + 'static,
    E: Error + Send + 'static,
    W: Fn(T) -> F + Send + Sync + 'static,
    F: Future<Output = Result<R, E>> + Send + 'static,
{
    let mut items = items.into_iter();
    let worker = Arc::new(worker);
    let mut tasks = JoinSet::new();
    let mut report = RunReport {
        outputs: Vec::new(),
        peak_outstanding: 0,
    };
    tokio::pin!(shutdown);

    // A loop is clearer than a combinator here: admission and reaping share state.
    let failure = loop {
        if items.len() == 0 && tasks.is_empty() {
            return Ok(report);
        }
        tokio::select! {
            biased;
            () = &mut shutdown => break RunError::Shutdown,
            Some(joined) = tasks.join_next(), if !tasks.is_empty() => {
                match joined {
                    Ok(Ok(output)) => report.outputs.push(output),
                    Ok(Err(error)) => break RunError::Worker(error),
                    Err(error) => break RunError::Join(error),
                }
            }
            () = std::future::ready(()), if items.len() > 0 && tasks.len() < limit.get() => {
                if let Some(item) = items.next() {
                    let worker = Arc::clone(&worker);
                    // Invoke the factory inside the task so its panics are JoinErrors too.
                    tasks.spawn(async move { worker(item).await });
                    report.peak_outstanding = report.peak_outstanding.max(tasks.len());
                }
            }
        }
    };

    tasks.abort_all();
    // Reap even completed tasks. Keep the first failure rather than replacing it
    // with expected cancellation errors (or secondary failures) during cleanup.
    while tasks.join_next().await.is_some() {}
    Err(failure)
}

#[cfg(test)]
mod tests {
    use std::{
        future::{Future, pending},
        io,
        num::NonZeroUsize,
        sync::{
            Arc, Mutex,
            atomic::{AtomicUsize, Ordering::SeqCst},
        },
        time::Duration,
    };

    use tokio::{
        sync::{Mutex as AsyncMutex, Semaphore, mpsc, oneshot},
        task::JoinSet,
        time::timeout,
    };

    use super::{RunError, run_bounded};

    // Timeouts detect deadlocks only; acknowledgments and gates establish ordering.
    async fn watchdog<T>(future: impl Future<Output = T>) -> T {
        timeout(Duration::from_secs(5), future)
            .await
            .expect("test stalled")
    }

    fn limit(value: usize) -> NonZeroUsize {
        NonZeroUsize::new(value).expect("test limit is nonzero")
    }

    struct Active(Arc<AtomicUsize>);

    impl Drop for Active {
        fn drop(&mut self) {
            self.0.fetch_sub(1, SeqCst);
        }
    }

    #[tokio::test]
    async fn empty_input_and_nonzero_limit_contract() {
        assert!(NonZeroUsize::new(0).is_none());
        let report = run_bounded(
            Vec::<()>::new(),
            limit(1),
            async {},
            |_| -> std::future::Ready<Result<(), io::Error>> {
                panic!("empty input must not invoke a worker");
            },
        )
        .await
        .unwrap();
        assert!(report.outputs.is_empty());
        assert_eq!(report.peak_outstanding, 0);
    }

    #[tokio::test]
    async fn measures_peak_active_work_separately_from_outstanding_tasks() {
        let active = Arc::new(AtomicUsize::new(0));
        let peak_active = Arc::new(AtomicUsize::new(0));
        let gate = Arc::new(Semaphore::new(0));
        let (started, mut starts) = mpsc::unbounded_channel();
        let task = tokio::spawn(run_bounded((0..9).collect(), limit(3), pending(), {
            let active = Arc::clone(&active);
            let peak_active = Arc::clone(&peak_active);
            let gate = Arc::clone(&gate);
            move |item| {
                let active = Arc::clone(&active);
                let peak_active = Arc::clone(&peak_active);
                let gate = Arc::clone(&gate);
                let started = started.clone();
                async move {
                    let current = active.fetch_add(1, SeqCst) + 1;
                    let _active = Active(active);
                    peak_active.fetch_max(current, SeqCst);
                    started.send(()).unwrap();
                    let permit = gate.acquire().await.unwrap();
                    permit.forget();
                    Ok::<_, io::Error>(item)
                }
            }
        }));
        for _ in 0..3 {
            watchdog(starts.recv()).await.unwrap();
        }
        assert_eq!(active.load(SeqCst), 3);
        assert!(matches!(
            starts.try_recv(),
            Err(mpsc::error::TryRecvError::Empty)
        ));
        gate.add_permits(9);
        let report = watchdog(task).await.unwrap().unwrap();
        assert_eq!(peak_active.load(SeqCst), 3);
        assert_eq!(active.load(SeqCst), 0);
        assert_eq!(report.peak_outstanding, 3);
        let mut outputs = report.outputs;
        outputs.sort_unstable();
        assert_eq!(outputs, (0..9).collect::<Vec<_>>());
    }

    #[tokio::test]
    async fn admission_to_reaping_counts_completed_tasks_not_only_active_work() {
        // Current-thread runtime: ready admissions fill the cap before spawned
        // tasks are polled. Immediately completing workers still occupy slots
        // until join_next reaps them. Repeat across many admission/reaping cycles.
        for cap in [1, 2, 4] {
            let report = watchdog(run_bounded((0..41).collect(), limit(cap), pending(), |i| {
                std::future::ready(Ok::<_, io::Error>(i))
            }))
            .await
            .unwrap();
            assert_eq!(report.outputs.len(), 41);
            assert_eq!(report.peak_outstanding, cap);
        }
    }

    #[tokio::test]
    async fn worker_and_join_errors_stop_admission_and_await_cleanup() {
        for panic_in_worker in [false, true] {
            let active = Arc::new(AtomicUsize::new(0));
            let admitted = Arc::new(AtomicUsize::new(0));
            let (started, mut starts) = mpsc::unbounded_channel();
            let (fail, failure) = oneshot::channel();
            let failure = Arc::new(Mutex::new(Some(failure)));
            let task = tokio::spawn(run_bounded((0..8).collect(), limit(2), pending(), {
                let active = Arc::clone(&active);
                let admitted = Arc::clone(&admitted);
                move |i| {
                    let active = Arc::clone(&active);
                    let started = started.clone();
                    admitted.fetch_add(1, SeqCst);
                    // Blocking guard is dropped synchronously before any await.
                    let failure = if i == 0 {
                        failure.lock().unwrap().take()
                    } else {
                        None
                    };
                    async move {
                        active.fetch_add(1, SeqCst);
                        let _active = Active(active);
                        started.send(()).unwrap();
                        if let Some(failure) = failure {
                            failure.await.unwrap();
                            assert!(!panic_in_worker, "intentional worker panic");
                            Err::<(), _>(io::Error::other("intentional domain failure"))
                        } else {
                            pending().await
                        }
                    }
                }
            }));
            for _ in 0..2 {
                watchdog(starts.recv()).await.unwrap();
            }
            fail.send(()).unwrap();
            let error = watchdog(task).await.unwrap().unwrap_err();
            if panic_in_worker {
                assert!(matches!(error, RunError::Join(error) if error.is_panic()));
            } else {
                assert!(
                    matches!(error, RunError::Worker(error) if error.to_string() == "intentional domain failure")
                );
            }
            assert_eq!(admitted.load(SeqCst), 2);
            // The pending sibling's guard has dropped before the runner returns.
            assert_eq!(active.load(SeqCst), 0);
        }
    }

    #[tokio::test]
    async fn shutdown_stops_admission_and_awaits_active_task_destruction() {
        let active = Arc::new(AtomicUsize::new(0));
        let (started, mut starts) = mpsc::unbounded_channel();
        let (stop, stopped) = oneshot::channel();
        let task = tokio::spawn(run_bounded(
            (0..9).collect(),
            limit(2),
            async {
                stopped.await.unwrap();
            },
            {
                let active = Arc::clone(&active);
                move |_| {
                    let active = Arc::clone(&active);
                    let started = started.clone();
                    async move {
                        active.fetch_add(1, SeqCst);
                        let _active = Active(active);
                        started.send(()).unwrap();
                        pending::<Result<(), io::Error>>().await
                    }
                }
            },
        ));
        for _ in 0..2 {
            watchdog(starts.recv()).await.unwrap();
        }
        stop.send(()).unwrap();
        assert!(matches!(
            watchdog(task).await.unwrap(),
            Err(RunError::Shutdown)
        ));
        assert_eq!(active.load(SeqCst), 0);
        assert_eq!(starts.recv().await, None);
    }

    #[tokio::test]
    async fn ready_shutdown_wins_before_admission() {
        let result = run_bounded(
            vec![1],
            limit(1),
            async {},
            |_| -> std::future::Ready<Result<(), io::Error>> {
                panic!("ready shutdown must win");
            },
        )
        .await;
        assert!(matches!(result, Err(RunError::Shutdown)));
    }

    #[tokio::test]
    async fn select_drops_in_progress_future_but_preserves_unreceived_message() {
        let (sender, mut receiver) = mpsc::channel(1);
        let (entered, entry) = oneshot::channel();
        let (stop, stopped) = oneshot::channel();
        let active = Arc::new(AtomicUsize::new(0));
        let task = tokio::spawn({
            let active = Arc::clone(&active);
            async move {
                // The guard is constructed only when this future is polled.
                let operation = async {
                    active.fetch_add(1, SeqCst);
                    let _active = Active(active);
                    entered.send(()).unwrap();
                    receiver.recv().await
                };
                tokio::select! {
                    biased;
                    _ = stopped => {},
                    _ = operation => panic!("no message sent yet"),
                }
                receiver
            }
        });
        watchdog(entry).await.unwrap();
        assert_eq!(active.load(SeqCst), 1);
        // Both branches become ready without yielding; biased shutdown wins.
        sender.send(7).await.unwrap();
        stop.send(()).unwrap();
        let mut receiver = watchdog(task).await.unwrap();
        assert_eq!(active.load(SeqCst), 0);
        assert_eq!(receiver.recv().await, Some(7));
    }

    #[tokio::test]
    async fn bounded_channel_pressure_and_owned_consumer_shutdown() {
        let (sender, mut receiver) = mpsc::channel(1);
        sender.send(10).await.unwrap();
        assert!(matches!(
            sender.try_send(20),
            Err(mpsc::error::TrySendError::Full(20))
        ));
        // reserve is pending while full. Cancelling reservation preserves our
        // value; cancelling send(value) would drop that owned value instead.
        let mut reservation = Box::pin(sender.reserve());
        assert!(matches!(
            std::future::poll_fn(|cx| { std::task::Poll::Ready(reservation.as_mut().poll(cx)) })
                .await,
            std::task::Poll::Pending
        ));
        drop(reservation);

        let (drain, drained) = oneshot::channel();
        let mut consumers = JoinSet::new();
        consumers.spawn(async move {
            drained.await.unwrap();
            let mut values = Vec::new();
            while let Some(value) = receiver.recv().await {
                values.push(value);
            }
            values
        });
        drain.send(()).unwrap();
        watchdog(sender.send(20)).await.unwrap();
        // Close admissions, let the consumer drain, and retain/await its owner.
        drop(sender);
        assert_eq!(
            watchdog(consumers.join_next()).await.unwrap().unwrap(),
            vec![10, 20]
        );
        assert!(consumers.is_empty());
    }

    #[tokio::test]
    async fn intentional_async_guard_across_await_and_short_blocking_guard() {
        let resource = Arc::new(AsyncMutex::new(Vec::new()));
        let (held, holding) = oneshot::channel();
        let (release, released) = oneshot::channel();
        let task = tokio::spawn({
            let resource = Arc::clone(&resource);
            async move {
                let mut transaction = resource.lock().await;
                transaction.push("begin");
                held.send(()).unwrap();
                // Intentional serialization of a simulated resource transaction.
                // The release sender must not need this same mutex.
                released.await.unwrap();
                transaction.push("commit");
            }
        });
        watchdog(holding).await.unwrap();
        assert!(resource.try_lock().is_err());
        release.send(()).unwrap();
        watchdog(task).await.unwrap();
        assert_eq!(*resource.lock().await, vec!["begin", "commit"]);

        let state = Mutex::new(vec![1, 2]);
        let snapshot = { state.lock().unwrap().clone() };
        tokio::task::yield_now().await; // No blocking guard survives this point.
        assert_eq!(snapshot, vec![1, 2]);
        assert!(state.try_lock().is_ok());
    }

    #[tokio::test]
    async fn abort_cannot_stop_already_running_spawn_blocking_work() {
        let (started, starting) = oneshot::channel();
        let (release, released) = std::sync::mpsc::channel();
        let task = tokio::task::spawn_blocking(move || {
            started.send(()).unwrap();
            released.recv().unwrap(); // Blocking only on the blocking pool.
            42
        });
        watchdog(starting).await.unwrap();
        task.abort(); // Too late: the closure acknowledged that it already started.
        release.send(()).unwrap();
        assert_eq!(watchdog(task).await.unwrap(), 42);
    }
}
