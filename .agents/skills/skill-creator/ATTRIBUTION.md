# Attribution and modification notice

This is a modified, agent-neutral adaptation, not an upstream distribution or
an endorsement by either source author. Documentation and helpers are distributed
under Apache License 2.0; see [LICENSE.txt](LICENSE.txt). That file is retained
verbatim from Anthropic, including `Copyright 2026 Anthropic, PBC.` Both source
skills carry Apache-2.0 terms. No trademark rights are granted.

## Whose copyright notice belongs here?

Keep Anthropic's existing notice in `LICENSE.txt`; it identifies upstream
material and does not mean Anthropic authored or owns every addition in this
adaptation. Do not replace it with your name. The Apache-2.0 license permits
modifications while requiring retention of applicable upstream notices.

You may add a separate notice for original contributions whose copyright you
hold, using the appropriate year and rights-holder name. That notice supplements,
not replaces, the upstream notices. No personal copyright claim has been added
here because ownership of the new contributions has not been established.
The source and modification records below distinguish this adaptation from
both upstream skills.

## Sources pinned for this adaptation

- Anthropic `anthropics/skills`, revision
  `dbd4588f9e1033efb41dad4bef2f7947c8993d44`:
  <https://github.com/anthropics/skills/tree/dbd4588f9e1033efb41dad4bef2f7947c8993d44/skills/skill-creator>.
  Primary source: `SKILL.md` intent/draft/test/review/iterate workflow;
  `agents/grader.md` and `agents/analyzer.md` evidence and variance guidance;
  `scripts/quick_validate.py` validation concept.
- OpenAI `openai/skills`, revision
  `49f948faa9258a0c61caceaf225e179651397431`:
  <https://github.com/openai/skills/tree/49f948faa9258a0c61caceaf225e179651397431/skills/.system/skill-creator>.
  Complementary source: `SKILL.md` concision, degrees of freedom, resource
  organization; `scripts/init_skill.py` destination refusal/scaffolding concept;
  `scripts/quick_validate.py` static validation concept.

## Modifications

The portable `SKILL.md`, authoring/evaluation references, and both helper scripts
are substantially rewritten adaptations with notices in their headers. Removed
vendor runners, required subagent roles, UI generators, mandatory archive/viewer,
and installed-path writes. Added authorization-based execution options,
serial/fresh-session/manual fallbacks, evidence limitations, validation versus
holdout separation, strict nonempty fields/folder equality, duplicate YAML-key
checks, and a minimal scaffold without TODO content. Helpers use Python 3 and
PyYAML only, with no auto-install or runtime agent API.

The illustrative JSON cases, focused unittest tests, and the adjacent merge
guide are new material for this adaptation under the same
Apache-2.0 license. The example JSON is unexecuted planning data, not a modified
copy of upstream results. No source UI assets, viewer, benchmark outputs,
proprietary SDK, or media dependencies are bundled.

No NOTICE file was found in either source skill. The Anthropic repository's
`THIRD_PARTY_NOTICES.md` names media/font components; none of those components
is copied or required by this adaptation. PyYAML is an external prerequisite,
not vendored. Preserve these notices and LICENSE.txt when redistributing this
adaptation; review additional dependency notices if adding resources later.
