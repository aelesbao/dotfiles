# Reviewing Rust changes

Use this reference for review tasks. Follow the core skill's repository inspection
and compatibility workflow before evaluating a diff. Review the requested scope;
do not turn a review into an unsolicited rewrite or migration.

## Classify every finding

Label each finding explicitly:

- **defect**: a correctness or soundness problem, or an unintended API break.
  Explain the failing input, violated contract, or unsafe obligation. A deliberate,
  requested breaking API change is not automatically a defect.
- **convention**: a house preference, with a reason and any applicable exception.
  Do not report a preference as a defect. Do not flag code that follows the
  repository's own conventions, even when this skill would choose differently.
- **nit**: a small, optional improvement with no meaningful behavioral effect.
  Include only when useful under the requested review scope.

Classification and severity are different: state the actual impact instead of
using the label as a severity ranking. Do not inflate a style preference into a
high-priority correctness issue. Valid loops, deliberate CLI stdout, existing
non-Tokio runtimes, owned inputs, and documented invariant-based panics are not
inherently defects. Consult each topic's primary policy before making a finding.

## Review method

1. Identify the changed contract and its callers. Inspect surrounding code,
   applicable instructions, tests, MSRV/edition, features, and CI policy.
2. Trace meaningful success and failure paths: empty input, invalid values,
   error propagation, ownership transfer, public compatibility, and observable
   output. For unsafe changes, reason about invariants rather than treating tests
   as soundness proof. For concurrent code, read the async reference.
3. Read only the relevant [error](error-handling.md),
   [functional](functional-style.md), or
   [async](async-and-concurrency.md) reference; avoid repeating their entire
   rule lists in a review.
4. Validate suspected defects with focused tests or a concrete code trace when
   possible. Run the repository's relevant checks if available and permitted;
   distinguish static reasoning from executed evidence.
5. Report actionable findings with precise locations and a minimal correction
   direction. Keep unrelated/pre-existing issues separate from regressions.
   If no actionable findings remain, say so rather than inventing preferences.

## Finding format

Use the repository's requested review format when one exists. Otherwise include:

- Label and concise title, for example `defect: zero bypasses positive-ID check`.
- File and line or symbol, with the smallest useful range.
- Trigger and impact: what input or caller behavior exposes the issue?
- Evidence: observed test/command result or a clearly marked reasoning trace.
- A focused correction or requested test, not a broad restructuring proposal.

For a convention finding, explain the benefit and why repository policy leaves
room for the house default. If an exception applies, do not manufacture a finding.
For uncertain behavior, state the uncertainty and missing evidence; do not claim
an unexecuted test failed or present speculation as an established defect.

## Review handoff

Summarize the examined scope, actionable findings, commands actually run with
outcomes, and limits of coverage. Note checks not run and why, including missing
tools/dependencies. Separate pre-existing failures, regressions, and unverified
risks. Passing tests support the review but are not a guarantee of correctness,
soundness, or universal feature/target compatibility.

Use the core skill's final verification checklist for implementation handoffs;
this reference replaces the former standalone `CHECKLIST.md` without duplicating
every topic's rules.
