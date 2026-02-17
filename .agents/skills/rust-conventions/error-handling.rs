// Good Error Handling Examples

// ============================================================================
// Example 1: Library Error Types with thiserror
// ============================================================================

use thiserror::Error;

#[derive(Error, Debug)]
pub enum UserError {
    #[error("user not found: {0}")]
    NotFound(UserId),
    
    #[error("invalid email format: {0}")]
    InvalidEmail(String),
    
    #[error("user already exists: {0}")]
    AlreadyExists(UserId),
    
    #[error("database error")]
    Database(#[from] sqlx::Error),
}

// ============================================================================
// Example 2: Binary Error Handling with anyhow
// ============================================================================

use anyhow::{Context, Result};

async fn load_user_config(path: &str) -> Result<UserConfig> {
    let content = tokio::fs::read_to_string(path)
        .await
        .context(format!("failed to read config file: {}", path))?;
    
    toml::from_str(&content)
        .context("failed to parse TOML config")
}

// ============================================================================
// Example 3: Adding Context to Errors
// ============================================================================

pub async fn process_user_request(user_id: UserId) -> Result<Response> {
    // Good - provides context at each layer
    let user = repository
        .find_user(user_id)
        .await
        .context(format!("failed to fetch user {}", user_id))?;
    
    let profile = profile_service
        .get_profile(user.profile_id)
        .await
        .context("failed to fetch user profile")?;
    
    let preferences = preference_service
        .load_preferences(user_id)
        .await
        .context("failed to load user preferences")?;
    
    Ok(Response::new(user, profile, preferences))
}

// ============================================================================
// Example 4: Custom Error Types with Context
// ============================================================================

#[derive(Error, Debug)]
pub enum OrderError {
    #[error("order not found: {id}")]
    NotFound { id: OrderId },
    
    #[error("insufficient inventory for item {item_id}: needed {needed}, available {available}")]
    InsufficientInventory {
        item_id: ItemId,
        needed: u32,
        available: u32,
    },
    
    #[error("order already {status:?}")]
    InvalidStatus { status: OrderStatus },
    
    #[error("payment processing failed")]
    PaymentFailed(#[from] PaymentError),
}

// ============================================================================
// Example 5: Avoid Unwrap - Use Match or ?
// ============================================================================

// Bad - can panic
pub fn parse_user_id(input: &str) -> UserId {
    UserId::new(input.parse::<u64>().unwrap())
}

// Good - returns Result
pub fn parse_user_id(input: &str) -> Result<UserId, ParseError> {
    let id = input
        .parse::<u64>()
        .map_err(|_| ParseError::InvalidFormat)?;
    Ok(UserId::new(id))
}

// Good - provides default
pub fn parse_user_id_or_default(input: &str) -> UserId {
    input
        .parse::<u64>()
        .map(UserId::new)
        .unwrap_or_else(|_| UserId::default())
}

// ============================================================================
// Example 6: When to Use expect() vs ?
// ============================================================================

pub fn initialize_logger() {
    // OK - this is a fatal error during initialization
    tracing_subscriber::fmt::init()
        .expect("failed to initialize logger - cannot proceed");
}

pub async fn fetch_required_config() -> Result<Config> {
    // Good - propagate error with context
    let content = tokio::fs::read_to_string("config.toml")
        .await
        .context("failed to read config.toml")?;
    
    toml::from_str(&content)
        .context("failed to parse config")
}

// ============================================================================
// Example 7: Combining Option and Result
// ============================================================================

pub fn validate_and_parse(input: Option<&str>) -> Result<UserId, ValidationError> {
    let input = input.ok_or(ValidationError::Missing)?;
    
    let id = input
        .parse::<u64>()
        .map_err(|_| ValidationError::InvalidFormat)?;
    
    if id == 0 {
        return Err(ValidationError::ZeroNotAllowed);
    }
    
    Ok(UserId::new(id))
}

// Using combinators
pub fn validate_and_parse_functional(input: Option<&str>) -> Result<UserId, ValidationError> {
    input
        .ok_or(ValidationError::Missing)?
        .parse::<u64>()
        .map_err(|_| ValidationError::InvalidFormat)?
        .try_into()
        .map(UserId::new)
        .map_err(|_| ValidationError::ZeroNotAllowed)
}
