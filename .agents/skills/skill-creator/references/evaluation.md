# Evaluation protocol

Modified portable adaptation of Anthropic's eval/review loop and grading
instructions with OpenAI's helper-testing guidance; see
[ATTRIBUTION.md](../ATTRIBUTION.md). Licensed under Apache-2.0.

## Task quality

1. Agree on realistic prompts, representative input fixtures, expected artifacts,
   and a small rubric. Include boundaries and failure cases. Two or three cases
   are smoke tests only. Fix assertions before seeing candidate outputs where
   possible; disclose later changes and rerun both conditions if they change.
2. Choose a frozen baseline: no skill for a new skill, original or explicitly
   selected previous snapshot for updates. Keep prompts, inputs, model/settings,
   tool access, and resource budget comparable. Ensure the no-skill baseline
   cannot discover another copy. Record any uncontrolled differences.
3. Prefer fresh isolated sessions/processes for each condition and repetition.
   Authorized delegation can parallelize independent runs but is not required.
   Serial fresh sessions or user-operated sessions work too. Alternate or
   randomize condition order when practical. Never allow one run's outputs to
   leak into another. Same-context review is useful but contaminated.
4. Store actual artifacts and available transcripts in an external workspace,
   for example `iteration-1/case-name/candidate/trial-1/outputs/` and the
   corresponding `baseline/trial-1/outputs/`. Keep a manifest recording case ID,
   prompt, input hashes, skill revision/hash, host/version, model/settings,
   condition, trial, execution mode, errors, and output paths. Record timing/token
   counts only when measured with known provenance; otherwise use null/unavailable.
5. Grade content, not filename existence or executor confidence. For each
   assertion record `pass`, `fail`, or `unverifiable`, plus a file/location and
   quote or reproducible check. Missing evidence cannot pass. An unreadable
   artifact is unverifiable, not a success. Check implicit claims and identify
   weak assertions that would also pass incorrect outputs. Use human rubrics
   for subjective value. Optional blind A/B review can use an authorized
   independent reviewer or a human; retain the mapping separately.
6. Show artifacts, grades, and human notes together. Empty notes are no comment.
   Do not infer acceptance. Report execution errors separately from task failures.

## Discovery tests

Use ordinary requests without the skill name, an explicit load command, or a
path to its instructions. Build realistic positives covering different phrasing
and realistic near negatives sharing vocabulary but asking for a different task.
Have the user confirm ambiguous labels before tuning. The JSON example includes
both types but is much too small for performance claims.

Measure each host's actual selection using observable load/tool evidence where
available. Log selected path, duplicate candidates, permissions, and errors.
If selection is not observable, mark it unknown; an answer resembling the skill
is not proof it loaded. Explicit-path runs test compliance only. Host errors,
permission denials, and unknown observations are not ordinary non-selections.
Count false positives and false negatives separately, with raw denominators and
unknown/error counts, rather than hiding tradeoffs in one score.

## Repetition and selection

Repeat both conditions per case under the same settings, reporting trial counts,
raw outcomes, per-case differences, and variability. Mean and sample standard
deviation can describe repeated numeric measurements; with one trial, variance
is unavailable, not evidence of stability. Repeated model runs on a tiny prompt
set are not independent coverage of new tasks or proof of statistical significance.
Report regressions, cost/quality tradeoffs, and environmental limitations.

Use development cases for edits and a separate validation set for choosing among
revisions. A set consulted for selection is validation even if called "test".
Freeze the selected revision before a final untouched holdout run. Do not retune
on holdout failures while continuing to call it untouched; disclose reuse or
reserve new cases. Do not fabricate metrics for unrun trials, missing timing,
or manual impressions. If runtime access is absent, deliver prompts and a manual
review with explicit limitations, not invented benchmark results.

## Small data contract

`eval-example.json` is a planning document, not a runner API. Copy it to the
external workspace and replace it with user-reviewed cases. `task_cases` hold
prompts, input files (relative to that workspace), expected outputs, and assertions.
`discovery_cases` hold ordinary requests and expected selection labels. `split`
is `development`, `validation`, or `holdout`; the example deliberately has no
holdout. `requested_trials` is a plan, not completed runs. No results are embedded.

For each executed trial, a grading record can be as small as:

```json
{
  "case_id": "preserve-id",
  "condition": "candidate",
  "trial": 1,
  "status": "completed",
  "assertions": [
    {"id": "leading-zero", "verdict": "pass", "evidence": "outputs/clean.csv:2 has account_id 0017"}
  ],
  "seconds": null,
  "tokens": null,
  "human_feedback": null
}
```

This is illustrative evidence formatting, not an executed result. Use `error`
for failed execution; retain the diagnostic. Keep missing evidence unverifiable
and report how many assertions were evaluable alongside any pass fraction.
