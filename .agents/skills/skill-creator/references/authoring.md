# Authoring choices

Modified portable adaptation of Anthropic and OpenAI guidance; see
[ATTRIBUTION.md](../ATTRIBUTION.md). Licensed under Apache-2.0.

## Choose the degree of freedom

- Use prose and heuristics when the right choice depends on context.
- Use parameterized steps or pseudocode for a preferred pattern with variation.
- Use a tested script with narrow inputs for fragile, repeatable operations.

Include a small input/output example and describe errors, missing inputs, and
when to ask for permission. Explain reasons for constraints. Avoid broad claims
that a description will always trigger across hosts.

## Organize for selective reading

Keep `SKILL.md` as the workflow and navigation entry point. A few hundred lines
is an editorial budget, not a universal host limit. Link directly to each needed
reference and say when to read it; add contents lists to long references.

- `scripts/`: tested deterministic helpers with explicit dependencies.
- `references/`: domain rules and variant-specific detail loaded as needed.
- `assets/`: templates or other files used in produced outputs.

Create only useful directories. Do not duplicate facts across core and references.
Resolve resource paths from the skill directory. Put generated evaluation
artifacts outside installed skills. Keep required licenses and provenance.

## Portable frontmatter profile

Default to `name` and `description`. The bundled validator also accepts optional
`license` (nonempty string), `compatibility` (nonempty string, at most 500
characters), `metadata` (string-to-string mapping), and `allowed-tools`
(nonempty space-delimited string). Tool names and authorization semantics vary
by host; this experimental field does not grant permission by itself.

The validator rejects unknown top-level fields as outside this deliberately
small profile, not as proof they violate every host's specification. It rejects
malformed/duplicate YAML keys, empty required strings, invalid names, excessive
lengths, folder mismatch, and empty bodies. It does not parse Markdown links,
resolve resources, detect secrets or unfinished prose, execute code, validate
host extensions, or prove behavior/specification compliance. Review those
manually, including realistic use and failure paths. Do not require host-specific
metadata files in a shared skill.
