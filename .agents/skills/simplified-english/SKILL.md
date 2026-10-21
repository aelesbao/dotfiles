---
name: simplified-english
description: >
  Use only when the user explicitly requests Simplified Technical
  English (STE), ASD-STE100-style writing, or the simplified-english
  skill by name. Do not activate merely because content is technical,
  formal, instructional, or intended for documentation. Requests for
  concise, direct, plain, or simple English alone do not activate this skill.
---

# Simplified English

Apply the rules below as an ASD-STE100-inspired language style only when the user explicitly requests it.

## Scope

- Apply these rules only to the content the user identifies.
- An artifact-specific request does not apply to surrounding conversation, progress updates, or unrelated changes.
- If the user explicitly requests STE for the whole session, apply it throughout the session until they change that instruction.
- Do not infer a session-wide preference from a request to rewrite one passage or document.
- A request to inspect, edit, or discuss this skill does not itself request STE for the response.

## Rules

- Put one topic in each sentence.
- Use active voice only.
- Use simple present, simple past, or simple future tense.
- Do not use clauses that start with an "-ing" form.
- Use each approved word with one meaning and one part of speech.
- Keep articles such as "the" and "a".
- Use no more than 20 words in a procedural sentence.
- Use no more than 25 words in a descriptive sentence.
- Use no more than three words in a noun cluster.

Prefer common words when no approved word list is available.

Keep technical names when a change could alter their meaning.

Keep verbatim text unchanged when accuracy requires an exact quotation. Do not rewrite code, commands, or identifiers to satisfy prose rules.

## Method

1. Draft the selected content with short and direct sentences.
2. Give each sentence one topic.
3. Find each passive construction and rewrite it in active voice.
4. Find each "-ing" clause and replace it with a finite clause.
5. Split each sentence that exceeds its word limit.
6. Split each noun cluster that contains more than three words.
7. Check articles, tense, word meaning, and part of speech.
8. Check only the content within the requested STE scope.

## Coordination

This skill controls language form. Use `technical-writing` as well when the task involves a technical document.

A channel-specific skill can control the output structure. Follow the user's current and explicit language instructions when they conflict with this skill.

## Example

Write:

"This function makes a new engine for each request."

Do not write:

"A new engine is created per request."

## Compliance boundary

Do not claim full ASD-STE100 compliance without an approved dictionary and a complete standards check.

Without these resources, apply this rule set without claiming certification or full compliance. Explain the limits only when the user asks about compliance.
