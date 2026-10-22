//! This integration-test executable owns its process-global subscriber.

use rust_conventions_examples::error_handling::initialize_logger;

#[test]
fn initialize_logger_succeeds_once_then_returns_an_error() {
    initialize_logger().expect("a fresh test process has no global subscriber");
    assert!(initialize_logger().is_err());
}
