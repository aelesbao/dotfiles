# Reviewing Rust changes

Review the requested scope. A review produces findings, not a rewrite.

## Labels

- **defect**: correctness or soundness problem, or an unintended API break.
  Name the failing input, violated contract, or unmet unsafe obligation. A
  requested breaking change is not a defect.
- **convention**: a house preference where repository policy is silent. Give the
  benefit. Code that follows the repository's own convention gets no finding.
- **nit**: small optional improvement with no behavioral effect.

A label is not a severity; state the actual impact. These are not defects by
themselves: valid loops, deliberate CLI stdout, a non-Tokio runtime, owned
parameters, and documented invariant panics.

## Method

1. Identify the changed contract and its callers. Check surrounding code, tests,
   MSRV, edition, features, and CI policy.
2. Trace success and failure paths: empty input, invalid values, error
   propagation, ownership transfer, public compatibility, observable output.
   For unsafe code, reason about invariants. For concurrent code, read the async
   reference.
3. Confirm suspected defects with a focused test or an explicit code trace. Run
   the repository's checks when permitted, and mark which findings are executed
   evidence and which are reasoning.
4. Keep pre-existing issues separate from regressions. If nothing actionable
   remains, say so.

## Finding format

Use the repository's format if it has one. Otherwise:

- Label and title, e.g. `defect: zero bypasses positive-ID check`.
- File and line or symbol, smallest useful range.
- Trigger and impact.
- Evidence: command output, or a trace marked as reasoning.
- A focused fix or a test to add.

State uncertainty and the missing evidence instead of presenting speculation as
a defect.

## Handoff

Summarize scope examined, findings, commands run with outcomes, and checks not
run with reasons. Passing tests support a review; they do not guarantee
soundness or compatibility across all features and targets.
