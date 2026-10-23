---
name: skill-creator
description: Create, revise, and evaluate reusable agent skills. Use when turning a workflow into a skill, improving skill instructions or resources, testing task quality, or tuning a skill's discovery description. Not for ordinary one-off tasks that do not involve authoring or evaluating a skill.
---

# Skill creator

Modified portable adaptation of Anthropic and OpenAI skill-creator guidance.
See [ATTRIBUTION.md](ATTRIBUTION.md) for sources, revisions, and Apache-2.0 terms.

## 1. Capture intent

Start at the user's current stage: intent, draft, evaluation, or revision.
Extract known requirements from the conversation before asking questions.
Confirm only material gaps: intended users, realistic requests, inputs, output
format, edge cases, tools, constraints, and observable success criteria.
Explain technical terms at the user's level. Agree on a lightweight smoke test
or a more rigorous evaluation; do not force a benchmark onto a simple request.

Inspect existing skills and relevant examples with the user's permission.
For updates, preserve the name and snapshot the original in a separate workspace
before editing. Do not overwrite an installed skill without explicit approval.

## 2. Draft the smallest useful skill

Write `SKILL.md` with YAML `name` and `description`, then actionable Markdown.
Keep folder and name identical: 1-64 lowercase ASCII letters/digits separated
by single hyphens. Write a nonempty description of at most 1024 characters
covering capability and realistic use contexts, without promising universal
activation. Default to these two fields only.

Keep the core lean. Explain non-obvious constraints and prefer short examples
over general background. Give precise steps for fragile operations and allow
judgment where multiple approaches are valid. Define outputs and failure behavior.
Use [references/authoring.md](references/authoring.md) when organizing resources
or choosing how specific instructions should be.

Optional scaffolding requires Python 3 and PyYAML. Resolve all bundled paths
from this skill's directory, not the project working directory. In shell examples,
set `SKILL_DIR` to the absolute directory containing this `SKILL.md` and
`WORKSPACE` to a user-approved directory outside installed skill directories.
Neither helper installs dependencies or invokes an agent:

```sh
python3 -c 'import yaml; print(yaml.__version__)'
python3 "$SKILL_DIR/scripts/init_skill.py" "$WORKSPACE/report-review" \
  --description 'Review reports for evidence gaps. Use when checking claims against supplied sources.'
```

The destination's parent must exist. The helper refuses any existing destination
and creates only a valid minimal `SKILL.md`. Replace generic workflow steps with
the agreed domain procedure before calling the skill useful.
If PyYAML is unavailable, report the dependency and ask the user how to provide
it, or author the Markdown manually. Do not auto-install packages.

## 3. Evaluate with evidence

Read [references/evaluation.md](references/evaluation.md) before designing tests.
Use [references/eval-example.json](references/eval-example.json) as a small,
unexecuted example, not as measured results or a complete evaluation suite.
Keep prompts, snapshots, transcripts, outputs, grading, and feedback in the
external workspace, never in the installed skill.

Separate two questions:

- **Task quality:** Does the skill produce correct, useful results? Compare the
  same prompts and inputs with the skill versus no skill for new work, or a
  frozen previous version for updates. Inspect actual artifacts, not just claims.
- **Discovery:** Does a host choose the skill for realistic positive requests
  and avoid nearby negatives? User-review labels first; measure each host
  separately. Explicitly directing an agent to read a skill tests compliance,
  not automatic discovery.

Use optional delegation only if available and authorized. Otherwise run serially
in fresh sessions with controlled inputs, ask the user to run isolated trials,
or do a disclosed manual review. Same-context self-testing is contaminated and
weaker evidence, not an independent benchmark. No particular runner is required.

Start with a few smoke cases, then expand and repeat trials before stronger
claims. Record environment, revisions, execution mode, evidence, and unavailable
metrics honestly. Keep tuning/validation cases separate from an untouched final
holdout. Do not use the holdout to choose the winning revision.

## 4. Review and iterate

Show outputs, assertion evidence, failures, and limitations to the user in any
available readable format. Blank feedback means no comment, not approval.
Ask for explicit acceptance before finalizing. Generalize fixes rather than
memorizing test prompts; remove instructions that add work without benefit.
Add helpers only for demonstrated repeated or fragile work, and test them.
Rerun affected cases and regression cases against the same stated baseline.
Stop on explicit acceptance, an agreed budget, or lack of useful progress;
report unresolved issues instead of inventing improvement scores.

## 5. Validate and hand off

```sh
python3 "$SKILL_DIR/scripts/validate_skill.py" "$WORKSPACE/report-review"
```

This is static portable-profile checking, not full specification conformance,
security review, or behavior validation. Manually check referenced paths, run
bundled helpers including failure paths, and review dependencies and sensitive
content. Deliver the directory, evidence summary, and known limitations.
Do not publish, install globally, include secrets, or require an archive.

Installation requires user approval and collision checks. Verify discovery and
refresh behavior against the target agent's documentation; duplicate names may
select a different copy. Do not change host configuration here.
