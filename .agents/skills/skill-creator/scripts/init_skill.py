#!/usr/bin/env python3
"""Modified neutral scaffolder inspired by OpenAI init_skill.py.

Apache-2.0; source revisions and changes: ../ATTRIBUTION.md.
Requires Python 3 and PyYAML. Never replaces an existing destination.
"""

import argparse
import sys
from contextlib import suppress
from pathlib import Path

from validate_skill import validate_metadata, yaml


def init_skill(destination, description):
    """Create only a minimal SKILL.md; the destination parent must exist."""
    destination = Path(destination).absolute()
    metadata = {"name": destination.name, "description": description}
    errors = validate_metadata(metadata, destination.name)
    if errors:
        raise ValueError("; ".join(errors))
    content = (
        "---\n" + yaml.safe_dump(metadata, sort_keys=False, allow_unicode=True)
        + "---\n\n# " + destination.name.replace("-", " ").title()
        + "\n\n## Workflow\n\n"
        "1. Confirm the requested inputs, output format, and success criteria.\n"
        "2. Inspect supplied materials and perform the task described above.\n"
        "3. Check the result against the success criteria. Report missing inputs\n"
        "   or limitations instead of claiming unsupported completion.\n"
    )
    # mkdir fails for directories, files, and dangling symlinks alike.
    destination.mkdir()
    skill_file = destination / "SKILL.md"
    created_file = False
    try:
        with skill_file.open("x", encoding="utf-8") as handle:
            created_file = True
            handle.write(content)
    except OSError:
        # Remove only our own partial file/directory, not unrelated contents.
        # A failed exclusive open must not delete a file created by another writer.
        if created_file:
            skill_file.unlink(missing_ok=True)
        with suppress(OSError):
            destination.rmdir()
        raise
    return destination


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("destination", type=Path, help="New skill directory with an existing parent")
    parser.add_argument("--description", required=True, help="Capability and when to use the skill")
    args = parser.parse_args()
    try:
        destination = init_skill(args.destination, args.description)
    except (OSError, ValueError) as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 1
    print(f"Created {destination / 'SKILL.md'}. Review and specialize the minimal workflow.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
