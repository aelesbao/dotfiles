// Hexagonal Architecture Example
// Demonstrates clean separation between domain, application, and infrastructure layers

// ============================================================================
// DOMAIN LAYER - Pure business logic, no external dependencies
// ============================================================================

// domain/user.rs
pub mod domain {
    use std::fmt;

    #[derive(Debug, Clone, PartialEq, Eq)]
    pub struct UserId(u64);

    impl UserId {
        pub fn new(id: u64) -> Self {
            Self(id)
        }
    }

    #[derive(Debug, Clone)]
    pub struct Email(String);

    impl Email {
        pub fn new(email: String) -> Result<Self, EmailError> {
            if !email.contains('@') {
                return Err(EmailError::InvalidFormat);
            }
            Ok(Self(email))
        }

        pub fn as_str(&self) -> &str {
            &self.0
        }
    }

    #[derive(Debug, Clone)]
    pub struct User {
        id: UserId,
        name: String,
        email: Email,
        status: UserStatus,
    }

    #[derive(Debug, Clone, PartialEq)]
    pub enum UserStatus {
        Pending,
        Active,
        Suspended,
    }

    impl User {
        pub fn new(id: UserId, name: String, email: Email) -> Self {
            Self {
                id,
                name,
                email,
                status: UserStatus::Pending,
            }
        }

        pub fn id(&self) -> &UserId {
            &self.id
        }

        pub fn activate(&mut self) -> Result<(), DomainError> {
            match self.status {
                UserStatus::Pending => {
                    self.status = UserStatus::Active;
                    Ok(())
                }
                _ => Err(DomainError::InvalidStatusTransition),
            }
        }

        pub fn is_active(&self) -> bool {
            self.status == UserStatus::Active
        }
    }

    // Domain errors - pure, no infrastructure types
    #[derive(Debug)]
    pub enum EmailError {
        InvalidFormat,
    }

    #[derive(Debug)]
    pub enum DomainError {
        InvalidStatusTransition,
    }
}

// ============================================================================
// APPLICATION LAYER - Use cases, orchestrates domain and ports
// ============================================================================

// app/user_service.rs
pub mod app {
    use super::domain::*;
    use async_trait::async_trait;
    use std::sync::Arc;

    // Define port (trait) for user repository
    #[async_trait]
    pub trait UserRepository: Send + Sync {
        async fn find(&self, id: &UserId) -> Result<Option<User>, RepositoryError>;
        async fn save(&self, user: &User) -> Result<(), RepositoryError>;
    }

    // Define port for email service
    #[async_trait]
    pub trait EmailService: Send + Sync {
        async fn send_welcome(&self, email: &str) -> Result<(), EmailError>;
    }

    // Application errors
    #[derive(Debug)]
    pub enum AppError {
        UserNotFound,
        Repository(RepositoryError),
        Email(EmailError),
        Domain(DomainError),
    }

    #[derive(Debug)]
    pub enum RepositoryError {
        DatabaseError(String),
        ConnectionFailed,
    }

    #[derive(Debug)]
    pub enum EmailError {
        SendFailed(String),
    }

    // Application service - coordinates domain logic with ports
    pub struct UserService {
        repository: Arc<dyn UserRepository>,
        email_service: Arc<dyn EmailService>,
    }

    impl UserService {
        pub fn new(
            repository: Arc<dyn UserRepository>,
            email_service: Arc<dyn EmailService>,
        ) -> Self {
            Self {
                repository,
                email_service,
            }
        }

        // Use case: Register new user
        pub async fn register_user(
            &self,
            name: String,
            email_str: String,
        ) -> Result<User, AppError> {
            // Domain logic
            let email = Email::new(email_str).map_err(|_| AppError::Domain(DomainError::InvalidStatusTransition))?;
            let id = UserId::new(rand::random()); // In real code, generate properly
            let user = User::new(id, name, email.clone());

            // Infrastructure interaction through ports
            self.repository
                .save(&user)
                .await
                .map_err(AppError::Repository)?;

            self.email_service
                .send_welcome(email.as_str())
                .await
                .map_err(AppError::Email)?;

            Ok(user)
        }

        // Use case: Activate user
        pub async fn activate_user(&self, user_id: UserId) -> Result<User, AppError> {
            let mut user = self
                .repository
                .find(&user_id)
                .await
                .map_err(AppError::Repository)?
                .ok_or(AppError::UserNotFound)?;

            user.activate().map_err(AppError::Domain)?;

            self.repository
                .save(&user)
                .await
                .map_err(AppError::Repository)?;

            Ok(user)
        }
    }
}

// ============================================================================
// INFRASTRUCTURE LAYER - Concrete implementations of ports
// ============================================================================

// infra/postgres_user_repository.rs
pub mod infra {
    use super::app::*;
    use super::domain::*;
    use async_trait::async_trait;
    use sqlx::PgPool;

    // Concrete implementation of UserRepository port
    pub struct PostgresUserRepository {
        pool: PgPool,
    }

    impl PostgresUserRepository {
        pub fn new(pool: PgPool) -> Self {
            Self { pool }
        }
    }

    #[async_trait]
    impl UserRepository for PostgresUserRepository {
        async fn find(&self, id: &UserId) -> Result<Option<User>, RepositoryError> {
            // Database query implementation
            // This is where SQL/ORM code lives
            // Returns domain types, not database types
            todo!("implement database query")
        }

        async fn save(&self, user: &User) -> Result<(), RepositoryError> {
            // Database save implementation
            todo!("implement database save")
        }
    }

    // Concrete implementation of EmailService port
    pub struct SmtpEmailService {
        smtp_host: String,
        smtp_port: u16,
    }

    impl SmtpEmailService {
        pub fn new(smtp_host: String, smtp_port: u16) -> Self {
            Self { smtp_host, smtp_port }
        }
    }

    #[async_trait]
    impl EmailService for SmtpEmailService {
        async fn send_welcome(&self, email: &str) -> Result<(), EmailError> {
            // SMTP implementation
            // External API calls live here
            todo!("implement SMTP sending")
        }
    }

    // In-memory implementation for testing
    pub struct InMemoryUserRepository {
        users: tokio::sync::RwLock<std::collections::HashMap<UserId, User>>,
    }

    impl InMemoryUserRepository {
        pub fn new() -> Self {
            Self {
                users: tokio::sync::RwLock::new(std::collections::HashMap::new()),
            }
        }
    }

    #[async_trait]
    impl UserRepository for InMemoryUserRepository {
        async fn find(&self, id: &UserId) -> Result<Option<User>, RepositoryError> {
            let users = self.users.read().await;
            Ok(users.get(id).cloned())
        }

        async fn save(&self, user: &User) -> Result<(), RepositoryError> {
            let mut users = self.users.write().await;
            users.insert(user.id().clone(), user.clone());
            Ok(())
        }
    }
}

// ============================================================================
// BINARY - Wiring it all together
// ============================================================================

// main.rs
use std::sync::Arc;

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    // Initialize infrastructure
    let pool = sqlx::PgPool::connect("postgres://...").await?;
    let user_repo = Arc::new(infra::PostgresUserRepository::new(pool));
    let email_service = Arc::new(infra::SmtpEmailService::new(
        "smtp.example.com".to_string(),
        587,
    ));

    // Construct application service with dependencies injected
    let user_service = app::UserService::new(user_repo, email_service);

    // Use the service
    let user = user_service
        .register_user("Alice".to_string(), "alice@example.com".to_string())
        .await?;

    println!("Registered user: {:?}", user);

    Ok(())
}

// ============================================================================
// DEPENDENCY FLOW
// ============================================================================
//
// main.rs (wiring)
//   ↓
// app::UserService
//   ↓
// app::UserRepository (trait) ← implemented by → infra::PostgresUserRepository
// app::EmailService (trait)    ← implemented by → infra::SmtpEmailService
//   ↓
// domain::User (pure logic)
//
// Key points:
// 1. Domain knows nothing about infrastructure
// 2. App defines ports (traits) but doesn't know implementations
// 3. Infra implements ports and depends on app/domain
// 4. Main wires everything together
// 5. Dependencies point inward (infra → app → domain)
