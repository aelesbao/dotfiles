// Functional Programming Patterns in Rust

// ============================================================================
// Example 1: Iterator Combinators vs Manual Loops
// ============================================================================

// Bad - manual loop with mutable state
pub fn filter_and_transform_bad(items: Vec<i32>) -> Vec<String> {
    let mut result = Vec::new();
    for item in items {
        if item > 0 {
            result.push(format!("positive: {}", item));
        }
    }
    result
}

// Good - iterator combinators
pub fn filter_and_transform_good(items: Vec<i32>) -> Vec<String> {
    items
        .into_iter()
        .filter(|&item| item > 0)
        .map(|item| format!("positive: {}", item))
        .collect()
}

// ============================================================================
// Example 2: Complex Transformations with Chaining
// ============================================================================

#[derive(Debug, Clone)]
pub struct User {
    id: u64,
    name: String,
    age: u32,
    active: bool,
}

// Bad - nested loops and mutable state
pub fn get_active_adult_names_bad(users: Vec<User>) -> Vec<String> {
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

// Good - declarative chain
pub fn get_active_adult_names_good(users: Vec<User>) -> Vec<String> {
    users
        .into_iter()
        .filter(|user| user.active && user.age >= 18)
        .map(|user| user.name.to_uppercase())
        .collect::<std::collections::BTreeSet<_>>()  // dedup and sort
        .into_iter()
        .collect()
}

// ============================================================================
// Example 3: Expressions Over Statements
// ============================================================================

// Bad - statement-oriented with mutation
pub fn calculate_discount_bad(price: f64, is_member: bool, quantity: u32) -> f64 {
    let mut final_price = price;
    
    if is_member {
        final_price = final_price * 0.9;
    }
    
    if quantity >= 10 {
        final_price = final_price * 0.85;
    } else if quantity >= 5 {
        final_price = final_price * 0.95;
    }
    
    final_price
}

// Good - expression-oriented
pub fn calculate_discount_good(price: f64, is_member: bool, quantity: u32) -> f64 {
    let member_discount = if is_member { 0.9 } else { 1.0 };
    
    let quantity_discount = match quantity {
        q if q >= 10 => 0.85,
        q if q >= 5 => 0.95,
        _ => 1.0,
    };
    
    price * member_discount * quantity_discount
}

// ============================================================================
// Example 4: Option and Result Combinators
// ============================================================================

// Bad - nested matching
pub fn parse_and_validate_bad(input: Option<&str>) -> Result<u32, String> {
    match input {
        Some(s) => match s.parse::<u32>() {
            Ok(n) => {
                if n > 0 {
                    Ok(n)
                } else {
                    Err("must be positive".to_string())
                }
            }
            Err(_) => Err("invalid number".to_string()),
        },
        None => Err("missing input".to_string()),
    }
}

// Good - combinator chain
pub fn parse_and_validate_good(input: Option<&str>) -> Result<u32, String> {
    input
        .ok_or("missing input")?
        .parse::<u32>()
        .map_err(|_| "invalid number")?
        .checked_sub(1)
        .ok_or("must be positive")?
        .checked_add(1)
        .ok_or("overflow")
}

// Even better - using filter
pub fn parse_and_validate_best(input: Option<&str>) -> Result<u32, String> {
    input
        .ok_or("missing input")?
        .parse::<u32>()
        .ok()
        .filter(|&n| n > 0)
        .ok_or("must be a positive number".to_string())
}

// ============================================================================
// Example 5: Immutability by Default
// ============================================================================

// Bad - unnecessary mutation
pub fn process_orders_bad(mut orders: Vec<Order>) -> Vec<Order> {
    for order in &mut orders {
        order.status = OrderStatus::Processed;
        order.processed_at = Some(Utc::now());
    }
    orders
}

// Good - map to new collection
pub fn process_orders_good(orders: Vec<Order>) -> Vec<Order> {
    orders
        .into_iter()
        .map(|mut order| {
            order.status = OrderStatus::Processed;
            order.processed_at = Some(Utc::now());
            order
        })
        .collect()
}

// Even better - with a method on Order
impl Order {
    pub fn process(mut self) -> Self {
        self.status = OrderStatus::Processed;
        self.processed_at = Some(Utc::now());
        self
    }
}

pub fn process_orders_best(orders: Vec<Order>) -> Vec<Order> {
    orders.into_iter().map(Order::process).collect()
}

// ============================================================================
// Example 6: Fold for Aggregation
// ============================================================================

#[derive(Debug, Default)]
pub struct Stats {
    total: f64,
    count: usize,
    max: f64,
    min: f64,
}

// Bad - manual accumulation
pub fn calculate_stats_bad(values: Vec<f64>) -> Stats {
    if values.is_empty() {
        return Stats::default();
    }
    
    let mut stats = Stats {
        total: 0.0,
        count: 0,
        max: f64::MIN,
        min: f64::MAX,
    };
    
    for value in values {
        stats.total += value;
        stats.count += 1;
        if value > stats.max {
            stats.max = value;
        }
        if value < stats.min {
            stats.min = value;
        }
    }
    
    stats
}

// Good - using fold
pub fn calculate_stats_good(values: Vec<f64>) -> Option<Stats> {
    values.into_iter().reduce(|mut stats, value| {
        Stats {
            total: stats.total + value,
            count: stats.count + 1,
            max: stats.max.max(value),
            min: stats.min.min(value),
        }
    })
}

// Better - using fold with initial value
pub fn calculate_stats_better(values: Vec<f64>) -> Stats {
    if values.is_empty() {
        return Stats::default();
    }
    
    let first = values[0];
    values.into_iter().fold(
        Stats {
            total: 0.0,
            count: 0,
            max: first,
            min: first,
        },
        |stats, value| Stats {
            total: stats.total + value,
            count: stats.count + 1,
            max: stats.max.max(value),
            min: stats.min.min(value),
        },
    )
}

// ============================================================================
// Example 7: Flat Map for Nested Structures
// ============================================================================

#[derive(Debug)]
pub struct Department {
    name: String,
    teams: Vec<Team>,
}

#[derive(Debug)]
pub struct Team {
    name: String,
    members: Vec<String>,
}

// Bad - nested loops with mutation
pub fn get_all_members_bad(departments: Vec<Department>) -> Vec<String> {
    let mut all_members = Vec::new();
    for dept in departments {
        for team in dept.teams {
            for member in team.members {
                all_members.push(member);
            }
        }
    }
    all_members
}

// Good - flat_map
pub fn get_all_members_good(departments: Vec<Department>) -> Vec<String> {
    departments
        .into_iter()
        .flat_map(|dept| dept.teams)
        .flat_map(|team| team.members)
        .collect()
}

// ============================================================================
// Example 8: Partition for Splitting
// ============================================================================

// Bad - two separate filters
pub fn split_even_odd_bad(numbers: Vec<i32>) -> (Vec<i32>, Vec<i32>) {
    let evens: Vec<i32> = numbers.iter().filter(|&&n| n % 2 == 0).copied().collect();
    let odds: Vec<i32> = numbers.iter().filter(|&&n| n % 2 != 0).copied().collect();
    (evens, odds)
}

// Good - single pass with partition
pub fn split_even_odd_good(numbers: Vec<i32>) -> (Vec<i32>, Vec<i32>) {
    numbers.into_iter().partition(|&n| n % 2 == 0)
}

// ============================================================================
// Example 9: When to Use Loops (Balance Readability)
// ============================================================================

// Sometimes a loop IS clearer - don't force functional style

// This is fine - the logic is complex and a loop is clear
pub fn apply_business_rules(mut order: Order, rules: &[Rule]) -> Result<Order, ValidationError> {
    for rule in rules {
        match rule.apply(&order) {
            Ok(modified) => order = modified,
            Err(e) if e.is_warning() => {
                eprintln!("Warning: {}", e);
                continue;
            }
            Err(e) => return Err(e),
        }
    }
    Ok(order)
}

// This would be less clear as a fold - the loop is better here

// ============================================================================
// Example 10: Common Combinators Quick Reference
// ============================================================================

pub fn combinator_examples(input: Vec<i32>) -> Vec<String> {
    input
        .into_iter()
        // Transform each element
        .map(|x| x * 2)
        // Keep only matching elements
        .filter(|&x| x > 10)
        // Transform with Option/Result, filter None/Err
        .filter_map(|x| {
            if x % 3 == 0 {
                Some(format!("divisible by 3: {}", x))
            } else {
                None
            }
        })
        // Take first n elements
        .take(5)
        // Skip first n elements
        .skip(1)
        // Flatten nested iterators
        // .flat_map(|x| vec![x, x + 1])
        // Accumulate into single value
        // .fold(0, |acc, x| acc + x)
        // Find first match
        // .find(|x| x > 100)
        // Check if any/all match
        // .any(|x| x > 100)
        // .all(|x| x > 0)
        .collect()
}

// Key takeaway: Use functional style when it improves clarity and reduces mutation.
// Use loops when the logic is complex and a loop is clearer.
// The goal is correctness, composability, and minimal state - not functional purity.
