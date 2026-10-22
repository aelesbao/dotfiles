//! Functional preferences and equally correct imperative alternatives.
//!
//! Sibling modules share contracts and tests. Inputs are borrowed when only read,
//! and owned when names, nested vectors, or orders are intentionally consumed.

use std::{collections::BTreeSet, num::NonZeroU32, time::SystemTime};

use thiserror::Error;

/// A user record containing only fields needed for filtering and transformation.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct User {
    /// Name to consume into the result.
    pub name: String,
    /// Age in years.
    pub age: u32,
    /// Whether the account is active.
    pub active: bool,
}

/// Whole cents, not floating-point currency. This sketch models one nonnegative currency only.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct Cents(pub u64);

impl Cents {
    fn discounted(self, member_percent: u64, quantity_percent: u64) -> Self {
        // Widen before multiplication; both percentages are at most 100.
        // Round down once, after combining discounts, not after each step.
        Self(
            (u128::from(self.0) * u128::from(member_percent) * u128::from(quantity_percent)
                / 10_000) as u64,
        )
    }
}

/// Errors shared by both positive-number parsers.
#[derive(Debug, Error, PartialEq, Eq)]
pub enum ParseError {
    /// No value supplied.
    #[error("missing input")]
    Missing,
    /// Invalid or out-of-range unsigned integer syntax.
    #[error("invalid number")]
    InvalidNumber,
    /// Zero is not positive.
    #[error("must be positive")]
    NotPositive,
}

/// Minimal order state for deterministic transformations and rules.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum OrderStatus {
    /// Not processed yet.
    Pending,
    /// Processing completed.
    Processed,
}

/// A teaching order, not a pricing/persistence framework.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Order {
    /// Current state.
    pub status: OrderStatus,
    /// Injected time of processing; absent before processing.
    pub processed_at: Option<SystemTime>,
}

impl Order {
    /// Consume and process an order using caller-supplied time, without reading a clock.
    #[must_use]
    pub fn process(mut self, now: SystemTime) -> Self {
        self.status = OrderStatus::Processed;
        self.processed_at = Some(now);
        self
    }
}

/// Statistics over finite floating-point values; empty input is represented by `None`.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct Stats {
    /// Sum of the values; an overflow is reported rather than returning infinity.
    pub total: f64,
    /// Number of values.
    pub count: usize,
    /// Largest value.
    pub max: f64,
    /// Smallest value.
    pub min: f64,
}

impl Stats {
    fn first(value: f64) -> Result<Self, StatsError> {
        if !value.is_finite() {
            return Err(StatsError::NonFinite);
        }
        Ok(Self {
            total: value,
            count: 1,
            max: value,
            min: value,
        })
    }

    fn include(self, value: f64) -> Result<Self, StatsError> {
        if !value.is_finite() {
            return Err(StatsError::NonFinite);
        }
        let total = self.total + value;
        if !total.is_finite() {
            return Err(StatsError::SumOverflow);
        }
        Ok(Self {
            total,
            count: self.count + 1,
            max: self.max.max(value),
            min: self.min.min(value),
        })
    }
}

/// Aggregation errors; comparisons of NaN do not silently corrupt extrema.
#[derive(Debug, Error, PartialEq, Eq)]
pub enum StatsError {
    /// NaN or infinity occurred in the input.
    #[error("statistics require finite values")]
    NonFinite,
    /// The running sum overflowed the finite range of `f64`.
    #[error("statistics sum overflowed")]
    SumOverflow,
}

/// A collection of teams, consumed by the flattening example.
#[derive(Debug, Clone)]
pub struct Department {
    /// Nested teams.
    pub teams: Vec<Team>,
}

/// A collection of member names.
#[derive(Debug, Clone)]
pub struct Team {
    /// Member names in their original order.
    pub members: Vec<String>,
}

/// Valid alternatives. Loops, mutation, and early returns are not correctness defects.
pub mod imperative {
    use super::*;

    /// Select positive numbers and render them in input order.
    pub fn filter_and_transform(items: &[i32]) -> Vec<String> {
        let mut result = Vec::new();
        for &item in items {
            if item > 0 {
                result.push(format!("positive: {item}"));
            }
        }
        result
    }

    /// Return uppercase active adult names, sorted and deduplicated.
    pub fn get_active_adult_names(users: Vec<User>) -> Vec<String> {
        let mut result = Vec::new();
        for user in users {
            if user.active && user.age >= 18 {
                result.push(user.name.to_uppercase());
            }
        }
        result.sort();
        result.dedup();
        result
    }

    /// Apply member and quantity discounts, rounding down once to whole cents.
    /// A membership gives 10%; quantities 5-9 give 5%, and 10+ give 15%.
    /// Quantity selects the discount tier; `price` is already the amount to discount.
    pub fn calculate_discount(price: Cents, is_member: bool, quantity: u32) -> Cents {
        let mut member_percent = 100;
        if is_member {
            member_percent = 90;
        }
        let mut quantity_percent = 100;
        if quantity >= 10 {
            quantity_percent = 85;
        } else if quantity >= 5 {
            quantity_percent = 95;
        }
        price.discounted(member_percent, quantity_percent)
    }

    /// Parse positive `u32` input, keeping missing, malformed, and zero errors distinct.
    ///
    /// # Errors
    /// Returns the applicable [`ParseError`] classification.
    pub fn parse_and_validate(input: Option<&str>) -> Result<u32, ParseError> {
        match input {
            Some(input) => match input.parse::<u32>() {
                Ok(value) if value > 0 => Ok(value),
                Ok(_) => Err(ParseError::NotPositive),
                Err(_) => Err(ParseError::InvalidNumber),
            },
            None => Err(ParseError::Missing),
        }
    }

    /// Process all orders in place, returning ownership of the same collection.
    /// The caller supplies a single deterministic time for the batch.
    pub fn process_orders(mut orders: Vec<Order>, now: SystemTime) -> Vec<Order> {
        for order in &mut orders {
            order.status = OrderStatus::Processed;
            order.processed_at = Some(now);
        }
        orders
    }

    /// Aggregate in input order; empty input returns `Ok(None)`.
    ///
    /// # Errors
    /// Rejects nonfinite input or a nonfinite running sum, without reordering values.
    pub fn calculate_stats(values: &[f64]) -> Result<Option<Stats>, StatsError> {
        let Some((&first, remaining)) = values.split_first() else {
            return Ok(None);
        };
        let mut stats = Stats::first(first)?;
        for &value in remaining {
            stats = stats.include(value)?;
        }
        Ok(Some(stats))
    }

    /// Flatten departments/teams without changing member order.
    pub fn get_all_members(departments: Vec<Department>) -> Vec<String> {
        let mut members = Vec::new();
        for department in departments {
            for team in department.teams {
                for member in team.members {
                    members.push(member);
                }
            }
        }
        members
    }
}

/// Preferred combinators when the transformation remains easy to follow.
pub mod functional {
    use super::*;

    /// Select positive numbers and render them in input order.
    pub fn filter_and_transform(items: &[i32]) -> Vec<String> {
        items
            .iter()
            .filter(|&&item| item > 0)
            .map(|item| format!("positive: {item}"))
            .collect()
    }

    /// Return uppercase active adult names, sorted and deduplicated.
    pub fn get_active_adult_names(users: Vec<User>) -> Vec<String> {
        let names: BTreeSet<_> = users
            .into_iter()
            .filter(|user| user.active && user.age >= 18)
            .map(|user| user.name.to_uppercase())
            .collect();
        names.into_iter().collect()
    }

    /// Apply the same discount tiers and round-once policy as the imperative sibling.
    pub fn calculate_discount(price: Cents, is_member: bool, quantity: u32) -> Cents {
        let member_percent = if is_member { 90 } else { 100 };
        let quantity_percent = match quantity {
            10.. => 85,
            5..=9 => 95,
            _ => 100,
        };
        price.discounted(member_percent, quantity_percent)
    }

    /// Parse positive `u32` input without discarding parse errors via `.ok()`.
    ///
    /// # Errors
    /// Returns the applicable [`ParseError`] classification.
    pub fn parse_and_validate(input: Option<&str>) -> Result<u32, ParseError> {
        let value = input
            .ok_or(ParseError::Missing)?
            .parse::<u32>()
            .map_err(|_| ParseError::InvalidNumber)?;
        NonZeroU32::new(value)
            .map(NonZeroU32::get)
            .ok_or(ParseError::NotPositive)
    }

    /// Map orders using a consuming method and caller-supplied deterministic time.
    /// This is a style alternative, not an allocation improvement over the in-place loop.
    pub fn process_orders(orders: Vec<Order>, now: SystemTime) -> Vec<Order> {
        orders.into_iter().map(|order| order.process(now)).collect()
    }

    /// Aggregate with a correctly typed accumulator; empty input returns `Ok(None)`.
    ///
    /// # Errors
    /// Rejects nonfinite input or a nonfinite running sum, without reordering values.
    pub fn calculate_stats(values: &[f64]) -> Result<Option<Stats>, StatsError> {
        let Some((&first, remaining)) = values.split_first() else {
            return Ok(None);
        };
        remaining
            .iter()
            .try_fold(Stats::first(first)?, |stats, &value| stats.include(value))
            .map(Some)
    }

    /// Flatten departments/teams without changing member order.
    pub fn get_all_members(departments: Vec<Department>) -> Vec<String> {
        departments
            .into_iter()
            .flat_map(|department| department.teams)
            .flat_map(|team| team.members)
            .collect()
    }
}

/// Correct two-pass alternative with an extra traversal, not a behavioral defect.
pub mod two_pass {
    /// Split numbers into stable even and odd subsequences using two filters.
    pub fn split_even_odd(numbers: &[i32]) -> (Vec<i32>, Vec<i32>) {
        let evens = numbers
            .iter()
            .copied()
            .filter(|number| number % 2 == 0)
            .collect();
        let odds = numbers
            .iter()
            .copied()
            .filter(|number| number % 2 != 0)
            .collect();
        (evens, odds)
    }
}

/// Single-pass partitioning preference.
pub mod single_pass {
    /// Split numbers into stable even and odd subsequences using partition.
    pub fn split_even_odd(numbers: &[i32]) -> (Vec<i32>, Vec<i32>) {
        numbers.iter().copied().partition(|number| number % 2 == 0)
    }
}

/// A nonfatal rule diagnostic, returned to the caller rather than printed by library code.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Warning(pub String);

/// Complete typed stand-ins for sequential rules; no plugin framework required.
pub enum Rule {
    /// Process using injected time.
    Process(SystemTime),
    /// Record a warning and leave the current order unchanged.
    Warn(String),
    /// Stop processing with a fatal error.
    Reject(String),
}

/// Successful order transformation, with nonfatal warnings in encounter order.
#[derive(Debug, PartialEq, Eq)]
pub struct RuleOutcome {
    /// Final order.
    pub order: Order,
    /// Warnings for the handling boundary to report according to repository policy.
    pub warnings: Vec<Warning>,
}

/// A fatal rule rejection retains warnings encountered before the failure.
#[derive(Debug, Error, PartialEq, Eq)]
#[error("rule rejected order: {message}")]
pub struct RuleFailure {
    /// Fatal reason.
    pub message: String,
    /// Warnings encountered before the rejection.
    pub warnings: Vec<Warning>,
}

/// Apply rules sequentially; a loop makes mutation, warnings, and short-circuiting clear.
///
/// # Errors
/// Returns the first rejection with preceding warnings; later rules are not applied.
pub fn apply_business_rules(mut order: Order, rules: &[Rule]) -> Result<RuleOutcome, RuleFailure> {
    let mut warnings = Vec::new();
    for rule in rules {
        match rule {
            Rule::Process(now) => order = order.process(*now),
            Rule::Warn(message) => warnings.push(Warning(message.clone())),
            Rule::Reject(message) => {
                return Err(RuleFailure {
                    message: message.clone(),
                    warnings,
                });
            }
        }
    }
    Ok(RuleOutcome { order, warnings })
}

#[cfg(test)]
mod tests {
    use std::time::Duration;

    use super::*;

    fn pending() -> Order {
        Order {
            status: OrderStatus::Pending,
            processed_at: None,
        }
    }

    #[test]
    fn filter_and_transform_preserves_order_and_handles_empty_input() {
        for (input, expected) in [
            (vec![], vec![]),
            (vec![-1, 0], vec![]),
            (vec![2, -3, 1], vec!["positive: 2", "positive: 1"]),
            (vec![i32::MIN, i32::MAX], vec!["positive: 2147483647"]),
        ] {
            assert_eq!(imperative::filter_and_transform(&input), expected);
            assert_eq!(functional::filter_and_transform(&input), expected);
        }
    }

    #[test]
    fn active_adult_names_filter_uppercase_sort_and_deduplicate() {
        let users = vec![
            User {
                name: "zoe".into(),
                age: 18,
                active: true,
            },
            User {
                name: "ada".into(),
                age: 40,
                active: true,
            },
            User {
                name: "ADA".into(),
                age: 22,
                active: true,
            },
            User {
                name: "child".into(),
                age: 17,
                active: true,
            },
            User {
                name: "inactive".into(),
                age: 50,
                active: false,
            },
        ];
        assert_eq!(
            imperative::get_active_adult_names(users.clone()),
            ["ADA", "ZOE"]
        );
        assert_eq!(functional::get_active_adult_names(users), ["ADA", "ZOE"]);
        assert!(imperative::get_active_adult_names(vec![]).is_empty());
        assert!(functional::get_active_adult_names(vec![]).is_empty());
    }

    #[test]
    fn calculate_discount_uses_cents_rounds_once_and_handles_boundaries() {
        for (price, member, quantity, expected) in [
            (1000, false, 0, 1000),
            (1000, false, 4, 1000),
            (1000, true, 4, 900),
            (1000, false, 5, 950),
            (1000, false, 9, 950),
            (1000, false, 10, 850),
            (1000, true, 10, 765),
            (19, true, 10, 14),
            (0, true, 10, 0),
            (u64::MAX, false, 1, u64::MAX),
        ] {
            assert_eq!(
                imperative::calculate_discount(Cents(price), member, quantity),
                Cents(expected)
            );
            assert_eq!(
                functional::calculate_discount(Cents(price), member, quantity),
                Cents(expected)
            );
        }
    }

    #[test]
    fn parse_and_validate_styles_preserve_error_distinctions() {
        for (input, expected) in [
            (None, Err(ParseError::Missing)),
            (Some(""), Err(ParseError::InvalidNumber)),
            (Some("nope"), Err(ParseError::InvalidNumber)),
            (Some("-1"), Err(ParseError::InvalidNumber)),
            (Some("4294967296"), Err(ParseError::InvalidNumber)),
            (Some("0"), Err(ParseError::NotPositive)),
            (Some("1"), Ok(1)),
            (Some("4294967295"), Ok(u32::MAX)),
        ] {
            assert_eq!(imperative::parse_and_validate(input), expected);
            assert_eq!(functional::parse_and_validate(input), expected);
        }
    }

    #[test]
    fn process_orders_uses_the_supplied_time_in_both_styles() {
        let now = SystemTime::UNIX_EPOCH + Duration::from_secs(123);
        let orders = vec![pending(), pending()];
        let expected = vec![
            Order {
                status: OrderStatus::Processed,
                processed_at: Some(now)
            };
            2
        ];
        assert_eq!(imperative::process_orders(orders.clone(), now), expected);
        assert_eq!(functional::process_orders(orders, now), expected);
        assert!(imperative::process_orders(vec![], now).is_empty());
        assert!(functional::process_orders(vec![], now).is_empty());
    }

    #[test]
    fn calculate_stats_handles_empty_single_negative_and_mixed_inputs() {
        for (values, expected) in [
            (vec![], None),
            (
                vec![3.0],
                Some(Stats {
                    total: 3.0,
                    count: 1,
                    min: 3.0,
                    max: 3.0,
                }),
            ),
            (
                vec![-4.0, -2.0],
                Some(Stats {
                    total: -6.0,
                    count: 2,
                    min: -4.0,
                    max: -2.0,
                }),
            ),
            (
                vec![-2.0, 0.0, 5.0],
                Some(Stats {
                    total: 3.0,
                    count: 3,
                    min: -2.0,
                    max: 5.0,
                }),
            ),
        ] {
            assert_eq!(imperative::calculate_stats(&values), Ok(expected));
            assert_eq!(functional::calculate_stats(&values), Ok(expected));
        }
    }

    #[test]
    fn calculate_stats_rejects_nonfinite_values_and_sum_overflow() {
        for values in [
            vec![f64::NAN],
            vec![f64::INFINITY],
            vec![1.0, f64::NEG_INFINITY],
        ] {
            assert_eq!(
                imperative::calculate_stats(&values),
                Err(StatsError::NonFinite)
            );
            assert_eq!(
                functional::calculate_stats(&values),
                Err(StatsError::NonFinite)
            );
        }
        for calculate in [imperative::calculate_stats, functional::calculate_stats] {
            assert_eq!(
                calculate(&[f64::MAX, f64::MAX]),
                Err(StatsError::SumOverflow)
            );
        }
    }

    #[test]
    fn get_all_members_preserves_nested_order_and_empty_groups() {
        let departments = vec![
            Department { teams: vec![] },
            Department {
                teams: vec![
                    Team { members: vec![] },
                    Team {
                        members: vec!["Ada".into(), "Zoe".into()],
                    },
                ],
            },
            Department {
                teams: vec![Team {
                    members: vec!["Ada".into()],
                }],
            },
        ];
        assert_eq!(
            imperative::get_all_members(departments.clone()),
            ["Ada", "Zoe", "Ada"]
        );
        assert_eq!(
            functional::get_all_members(departments),
            ["Ada", "Zoe", "Ada"]
        );
        assert!(imperative::get_all_members(vec![]).is_empty());
        assert!(functional::get_all_members(vec![]).is_empty());
    }

    #[test]
    fn split_even_odd_is_stable_for_negatives_and_empty_input() {
        for (input, expected) in [
            (vec![], (vec![], vec![])),
            (vec![-3, -2, 0, 1, 4], (vec![-2, 0, 4], vec![-3, 1])),
        ] {
            assert_eq!(two_pass::split_even_odd(&input), expected);
            assert_eq!(single_pass::split_even_odd(&input), expected);
        }
    }

    #[test]
    fn apply_business_rules_returns_warnings_and_stops_at_fatal_errors() {
        let now = SystemTime::UNIX_EPOCH;
        let outcome = apply_business_rules(
            pending(),
            &[Rule::Warn("review".into()), Rule::Process(now)],
        )
        .unwrap();
        assert_eq!(outcome.order, pending().process(now));
        assert_eq!(outcome.warnings, [Warning("review".into())]);
        assert_eq!(
            apply_business_rules(pending(), &[]).unwrap(),
            RuleOutcome {
                order: pending(),
                warnings: vec![]
            }
        );
        let failure = apply_business_rules(
            pending(),
            &[
                Rule::Warn("first".into()),
                Rule::Reject("stop".into()),
                Rule::Warn("not reached".into()),
            ],
        )
        .unwrap_err();
        assert_eq!(failure.message, "stop");
        assert_eq!(failure.warnings, [Warning("first".into())]);
    }
}
