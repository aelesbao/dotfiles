---
name: technical-writing
description: >
  Use when drafting, editing, or reviewing technical documentation,
  README prose, guides, standalone technical documents or reports, or
  pull request descriptions. Do not use for ordinary conversation,
  progress updates, debugging explanations, or routine implementation
  plans unless the user asks to turn them into a standalone document.
---

# Technical Writing

Create clear, accurate technical documents that help the intended reader understand a topic or complete a task.

## Scope

Apply this skill only to the requested writing deliverable, whether it appears in chat or a file.

Default scope:

- Documentation pages, README prose, and guides
- Standalone technical documents and reports
- Pull request descriptions

Do not extend this skill to surrounding conversation, progress updates, tool-use narration, or unrelated changes.

Saving a file does not by itself activate this skill. Code, configuration, and task-tracking data are not technical writing deliverables.

Do not activate this skill for routine code comments, docstrings, commit messages, or workplace messages unless the user explicitly requests it.

## Principles

- Identify the audience, purpose, and scope. Use the task context when these are clear; ask only when missing information affects the result.
- Lead with the information the reader needs most.
- Use headings that describe the content. Use lists or tables when they make the content easier to scan.
- Keep terminology consistent. Define unfamiliar terms when the audience needs them.
- Prefer direct sentences and common words. Remove repetition and filler without removing necessary context.
- Preserve technical meaning, identifiers, commands, and exact quotations.
- Separate verified facts from assumptions. Do not invent behavior, requirements, test results, or sources.
- Keep examples relevant and consistent with the implementation. State prerequisites and expected results for procedures when needed.
- Match the requested format and level of detail. Do not add sections merely to fill a template.

## Method

1. Identify what the reader must know or do.
2. Check the relevant source material for technical claims.
3. Organize the content around the reader's task or questions.
4. Draft the smallest complete explanation or procedure.
5. Review the deliverable for accuracy, structure, terminology, and unnecessary detail.

For pull request descriptions, explain the change, its reason, and the available validation evidence. Include risks or migration steps when relevant.

Review only the requested deliverable, not surrounding conversation or unrelated artifacts.

## Coordination

This skill controls document quality and structure, not a restricted English standard.

Use natural English without mandatory sentence limits, tense restrictions, or a blanket ban on passive voice.

Use `simplified-english` as well only when the user explicitly requests STE or that skill. Apply its language rules only within the requested scope.

Use channel-specific or voice skills when appropriate. Follow the user's explicit instructions when they conflict with this skill.
