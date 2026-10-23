#!/usr/bin/env python3
"""Modified portable validator inspired by upstream quick_validate.py.

Apache-2.0; source revisions and changes: ../ATTRIBUTION.md.
Requires Python 3 and PyYAML. Performs static profile checks only.
"""

import argparse
import re
import sys
from pathlib import Path

try:
    import yaml
except ImportError:
    raise SystemExit("PyYAML is required. Provide it in your chosen Python environment; no dependency was installed.") from None


class UniqueKeyLoader(yaml.SafeLoader):
    """Reject duplicate keys instead of silently accepting the last value."""

    def construct_mapping(self, node, deep=False):
        self.flatten_mapping(node)
        mapping = {}
        for key_node, value_node in node.value:
            key = self.construct_object(key_node, deep=deep)
            if not isinstance(key, str):
                raise ValueError("YAML mapping keys must be strings")
            if key in mapping:
                raise ValueError(f"Duplicate YAML key: {key}")
            mapping[key] = self.construct_object(value_node, deep=deep)
        return mapping


def validate_metadata(data, folder_name):
    """Return errors for our documented portable frontmatter profile."""
    if not isinstance(data, dict):
        return ["Frontmatter must be a YAML mapping"]
    errors = []
    allowed = {"name", "description", "license", "compatibility", "metadata", "allowed-tools"}
    if any(not isinstance(key, str) or key not in allowed for key in data):
        errors.append("Unknown top-level field outside portable profile")
    name = data.get("name")
    if not isinstance(name, str) or not re.fullmatch(r"[a-z0-9]+(?:-[a-z0-9]+)*", name) or len(name) > 64:
        errors.append("name must be 1-64 lowercase ASCII letters/digits separated by single hyphens")
    elif name != folder_name:
        errors.append("name must match the skill directory name")
    description = data.get("description")
    if not isinstance(description, str) or not description.strip() or len(description) > 1024:
        errors.append("description must be a nonempty string of at most 1024 characters")
    for field in ("license", "compatibility", "allowed-tools"):
        if field in data:
            value = data[field]
            if not isinstance(value, str) or not value.strip():
                errors.append(f"{field} must be a nonempty string")
            elif field == "compatibility" and len(value) > 500:
                errors.append("compatibility must be at most 500 characters")
    if "metadata" in data:
        metadata = data["metadata"]
        if not isinstance(metadata, dict) or any(
            not isinstance(key, str) or not isinstance(value, str)
            for key, value in metadata.items()
        ):
            errors.append("metadata must be a string-to-string mapping")
    return errors


def validate_skill(skill_path):
    """Return static errors, without executing resources or parsing body links."""
    path = Path(skill_path)
    try:
        content = (path / "SKILL.md").read_text(encoding="utf-8")
    except (OSError, UnicodeError) as exc:
        return [f"Cannot read SKILL.md: {exc}"]
    lines = content.splitlines()
    if not lines or lines[0] != "---":
        return ["SKILL.md must start with a YAML frontmatter delimiter (---)"]
    try:
        end = lines.index("---", 1)
    except ValueError:
        return ["Missing closing YAML frontmatter delimiter (---)"]
    loader = None
    try:
        loader = UniqueKeyLoader("\n".join(lines[1:end]))
        data = loader.get_single_data()
    except (yaml.YAMLError, ValueError, RecursionError) as exc:
        return [f"Invalid YAML frontmatter: {exc}"]
    finally:
        if loader is not None:
            loader.dispose()
    errors = validate_metadata(data, path.absolute().name)
    if not "\n".join(lines[end + 1:]).strip():
        errors.append("SKILL.md body must not be empty")
    return errors


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("skill_directory", type=Path)
    args = parser.parse_args()
    errors = validate_skill(args.skill_directory)
    if errors:
        for error in errors:
            print(f"ERROR: {error}", file=sys.stderr)
        return 1
    print("Static portable-profile checks passed. Not full spec, link, security, or behavior validation.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
