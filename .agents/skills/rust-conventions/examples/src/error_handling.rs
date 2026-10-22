//! Typed library errors, application context, explicit fallbacks, and fallible setup.
//!
//! The repository below is an in-memory teaching stand-in, not a database adapter.
//! Config loading is synchronous: error context does not require an async runtime.

use std::{fmt, num::NonZeroU64, path::Path};

use anyhow::Context;
use serde::Deserialize;
use thiserror::Error;

/// A user identifier; zero is allowed here so parsing and validation remain separate lessons.
#[derive(Debug, Clone, Copy, Default, PartialEq, Eq)]
pub struct UserId(pub u64);

impl fmt::Display for UserId {
    fn fmt(&self, formatter: &mut fmt::Formatter<'_>) -> fmt::Result {
        self.0.fmt(formatter)
    }
}

/// A typed stand-in for a repository transport failure.
#[derive(Debug, Error)]
#[error("repository unavailable")]
pub struct RepositoryError;

/// Library callers can match domain errors without parsing their display text.
#[derive(Debug, Error)]
#[non_exhaustive]
pub enum UserError {
    /// No matching user exists.
    #[error("user not found: {0}")]
    NotFound(UserId),
    /// The supplied email is invalid.
    #[error("invalid email format: {0}")]
    InvalidEmail(String),
    /// The identifier is already registered.
    #[error("user already exists: {0}")]
    AlreadyExists(UserId),
    /// The storage boundary failed; the source is preserved.
    #[error("repository error")]
    Repository(#[from] RepositoryError),
}

/// Order states relevant to the contextual-error lesson.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum OrderStatus {
    /// Awaiting confirmation.
    Pending,
    /// Already confirmed.
    Confirmed,
}

/// A typed payment failure, standing in for a payment provider's error.
#[derive(Debug, Error)]
#[error("payment declined")]
pub struct PaymentError;

/// Structured fields let callers inspect failures without parsing strings.
#[derive(Debug, Error)]
#[non_exhaustive]
pub enum OrderError {
    /// The order was absent.
    #[error("order not found: {id}")]
    NotFound {
        /// Missing order identifier (a primitive suffices for this focused sketch).
        id: u64,
    },
    /// Stock cannot satisfy the request.
    #[error("insufficient inventory for item {item_id}: needed {needed}, available {available}")]
    InsufficientInventory {
        /// Item identifier.
        item_id: u64,
        /// Requested count.
        needed: u32,
        /// Available count.
        available: u32,
    },
    /// The operation is not valid in this state.
    #[error("order already {status:?}")]
    InvalidStatus {
        /// Current state.
        status: OrderStatus,
    },
    /// Payment failed; callers can inspect the source.
    #[error("payment processing failed")]
    PaymentFailed(#[from] PaymentError),
}

/// A deliberately small TOML configuration; production validation is outside this lesson.
#[derive(Debug, Deserialize, PartialEq, Eq)]
#[serde(deny_unknown_fields)]
pub struct UserConfig {
    /// Name used by the application.
    pub name: String,
}

/// Read and parse a config at an application boundary.
///
/// # Errors
/// Returns an I/O or TOML error with context. Allocated path context is built only on failure.
pub fn load_user_config(path: &Path) -> anyhow::Result<UserConfig> {
    let content = std::fs::read_to_string(path)
        .with_context(|| format!("failed to read config file: {}", path.display()))?;
    parse_user_config(&content)
}

/// Parse TOML, preserving the parser error under a static contextual message.
///
/// # Errors
/// Returns an error if TOML is malformed or does not match [`UserConfig`].
pub fn parse_user_config(content: &str) -> anyhow::Result<UserConfig> {
    toml::from_str(content).context("failed to parse TOML config")
}

/// Minimal user record for the boundary-context lesson.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct User {
    /// Identifier used to look up this user.
    pub id: UserId,
    /// Display name, not logged as an unexpected side effect.
    pub name: String,
}

/// Concrete, synchronous stand-in: no SQL, networking, or architectural framework required.
pub struct Repository {
    /// Records available to the example.
    pub users: Vec<User>,
    /// Simulates a storage failure for deterministic tests.
    pub unavailable: bool,
}

impl Repository {
    /// Look up a record, keeping domain and transport errors distinct.
    ///
    /// # Errors
    /// Returns [`UserError::Repository`] when unavailable, otherwise [`UserError::NotFound`] if absent.
    pub fn find_user(&self, id: UserId) -> Result<User, UserError> {
        if self.unavailable {
            return Err(RepositoryError.into());
        }
        self.users
            .iter()
            .find(|user| user.id == id)
            .cloned()
            .ok_or(UserError::NotFound(id))
    }
}

/// Application aggregation adds useful boundary context without logging and re-returning an error.
///
/// # Errors
/// Returns a contextualized lookup error, preserving the typed source for downcasting.
pub fn process_user_request(repository: &Repository, id: UserId) -> anyhow::Result<User> {
    repository
        .find_user(id)
        .with_context(|| format!("failed to fetch user {id}"))
}

/// Parsing failed; this intentionally retains a stable domain classification rather than parser details.
#[derive(Debug, Error, PartialEq, Eq)]
pub enum ParseError {
    /// Invalid or out-of-range integer syntax.
    #[error("invalid integer format")]
    InvalidFormat,
}

/// Prefer a fallible API when invalid input is recoverable.
pub mod fallible {
    use super::{ParseError, UserId};

    /// Parse a user ID, including zero; use the validation examples to require a positive ID.
    ///
    /// # Errors
    /// Returns [`ParseError::InvalidFormat`] on malformed or out-of-range input.
    pub fn parse_user_id(input: &str) -> Result<UserId, ParseError> {
        input
            .parse::<u64>()
            .map(UserId)
            .map_err(|_| ParseError::InvalidFormat)
    }
}

/// An explicit alternative contract, not a replacement for error reporting.
pub mod fallback {
    use super::UserId;

    /// Invalid input maps to the documented sentinel ID zero, losing the failure information.
    /// Only use this policy when the caller explicitly wants a sentinel.
    pub fn parse_user_id_or_default(input: &str) -> UserId {
        input.parse::<u64>().map(UserId).unwrap_or_default()
    }
}

/// Missing, malformed, and zero input remain distinguishable in both styles.
#[derive(Debug, Error, PartialEq, Eq)]
pub enum ValidationError {
    /// No input was supplied.
    #[error("missing input")]
    Missing,
    /// Input was not an in-range unsigned integer.
    #[error("invalid integer format")]
    InvalidFormat,
    /// A valid integer was zero.
    #[error("zero is not allowed")]
    ZeroNotAllowed,
}

/// Valid imperative alternative: early returns express the validation directly.
pub mod imperative {
    use super::{UserId, ValidationError};

    /// Parse a required positive identifier.
    ///
    /// # Errors
    /// Distinguishes missing, malformed/out-of-range, and zero input.
    pub fn validate_and_parse(input: Option<&str>) -> Result<UserId, ValidationError> {
        let input = input.ok_or(ValidationError::Missing)?;
        let id = input
            .parse::<u64>()
            .map_err(|_| ValidationError::InvalidFormat)?;
        if id == 0 {
            return Err(ValidationError::ZeroNotAllowed);
        }
        Ok(UserId(id))
    }
}

/// Combinator preference with exactly the same error contract as [`imperative`].
pub mod functional {
    use super::{NonZeroU64, UserId, ValidationError};

    /// Parse a required positive identifier without discarding parse errors.
    ///
    /// # Errors
    /// Distinguishes missing, malformed/out-of-range, and zero input.
    pub fn validate_and_parse(input: Option<&str>) -> Result<UserId, ValidationError> {
        let id = input
            .ok_or(ValidationError::Missing)?
            .parse::<u64>()
            .map_err(|_| ValidationError::InvalidFormat)?;
        NonZeroU64::new(id)
            .map(|id| UserId(id.get()))
            .ok_or(ValidationError::ZeroNotAllowed)
    }
}

/// Initialize the global logger once at the application boundary.
///
/// # Errors
/// Returns an error if a global subscriber/logging integration has already been installed.
/// Libraries should not call this on behalf of their callers.
pub fn initialize_logger() -> Result<(), Box<dyn std::error::Error + Send + Sync + 'static>> {
    tracing_subscriber::fmt().try_init()
}

#[cfg(test)]
mod tests {
    use std::error::Error;
    use std::sync::atomic::{AtomicBool, Ordering};

    use super::*;

    #[test]
    fn validate_and_parse_styles_agree_on_boundaries_and_errors() {
        for (input, expected) in [
            (None, Err(ValidationError::Missing)),
            (Some(""), Err(ValidationError::InvalidFormat)),
            (Some("oops"), Err(ValidationError::InvalidFormat)),
            (Some("-1"), Err(ValidationError::InvalidFormat)),
            (
                Some("18446744073709551616"),
                Err(ValidationError::InvalidFormat),
            ),
            (Some("0"), Err(ValidationError::ZeroNotAllowed)),
            (Some("42"), Ok(UserId(42))),
            (Some("18446744073709551615"), Ok(UserId(u64::MAX))),
        ] {
            assert_eq!(imperative::validate_and_parse(input), expected);
            assert_eq!(functional::validate_and_parse(input), expected);
        }
    }

    #[test]
    fn parse_user_id_and_explicit_fallback_have_different_contracts() {
        assert_eq!(fallible::parse_user_id("7"), Ok(UserId(7)));
        assert_eq!(fallible::parse_user_id("0"), Ok(UserId(0)));
        assert_eq!(
            fallible::parse_user_id("bad"),
            Err(ParseError::InvalidFormat)
        );
        assert_eq!(fallback::parse_user_id_or_default("bad"), UserId(0));
        assert_eq!(fallback::parse_user_id_or_default("7"), UserId(7));
    }

    #[test]
    fn typed_errors_display_fields_and_preserve_sources() {
        assert_eq!(
            UserError::NotFound(UserId(5)).to_string(),
            "user not found: 5"
        );
        assert_eq!(
            UserError::AlreadyExists(UserId(5)).to_string(),
            "user already exists: 5"
        );
        assert_eq!(
            UserError::InvalidEmail("bad".into()).to_string(),
            "invalid email format: bad"
        );
        let storage: UserError = RepositoryError.into();
        assert!(storage.source().unwrap().is::<RepositoryError>());
        let payment: OrderError = PaymentError.into();
        assert!(payment.source().unwrap().is::<PaymentError>());
        assert_eq!(
            OrderError::NotFound { id: 2 }.to_string(),
            "order not found: 2"
        );
        assert_eq!(
            OrderError::InsufficientInventory {
                item_id: 3,
                needed: 4,
                available: 1
            }
            .to_string(),
            "insufficient inventory for item 3: needed 4, available 1"
        );
        assert_eq!(
            OrderError::InvalidStatus {
                status: OrderStatus::Confirmed
            }
            .to_string(),
            "order already Confirmed"
        );
    }

    #[test]
    fn request_context_preserves_typed_errors_and_success() {
        let mut repository = Repository {
            users: vec![User {
                id: UserId(1),
                name: "Ada".into(),
            }],
            unavailable: false,
        };
        assert_eq!(
            process_user_request(&repository, UserId(1)).unwrap().name,
            "Ada"
        );
        let error = process_user_request(&repository, UserId(2)).unwrap_err();
        assert_eq!(error.to_string(), "failed to fetch user 2");
        assert!(matches!(
            error.downcast_ref::<UserError>(),
            Some(UserError::NotFound(UserId(2)))
        ));
        repository.unavailable = true;
        let error = process_user_request(&repository, UserId(1)).unwrap_err();
        assert!(matches!(
            error.downcast_ref::<UserError>(),
            Some(UserError::Repository(_))
        ));
    }

    #[test]
    fn config_parsing_and_read_errors_keep_context_and_source() {
        assert_eq!(
            parse_user_config("name = 'Ada'").unwrap(),
            UserConfig { name: "Ada".into() }
        );
        for invalid in ["name = [", "name = 4", "other = 'Ada'"] {
            let error = parse_user_config(invalid).unwrap_err();
            assert_eq!(error.to_string(), "failed to parse TOML config");
            assert!(error.downcast_ref::<toml::de::Error>().is_some());
        }
        // A child of a regular file cannot be read as a file, independently of the host's files.
        let path = Path::new(env!("CARGO_MANIFEST_DIR")).join("Cargo.toml/child");
        let error = load_user_config(&path).unwrap_err();
        assert!(
            error
                .to_string()
                .starts_with("failed to read config file: ")
        );
        assert!(error.downcast_ref::<std::io::Error>().is_some());
        let path = Path::new(env!("CARGO_MANIFEST_DIR")).join("tests/fixtures/user.toml");
        assert_eq!(load_user_config(&path).unwrap().name, "Ada");
    }

    #[test]
    fn allocated_context_is_lazy_on_success() {
        let called = AtomicBool::new(false);
        let value = Ok::<_, RepositoryError>(1).with_context(|| {
            called.store(true, Ordering::Relaxed);
            format!("failed to fetch user {}", UserId(1))
        });
        assert_eq!(value.unwrap(), 1);
        assert!(!called.load(Ordering::Relaxed));
        let _ = Err::<(), _>(RepositoryError).with_context(|| {
            called.store(true, Ordering::Relaxed);
            format!("failed to fetch user {}", UserId(1))
        });
        assert!(called.load(Ordering::Relaxed));
    }
}
