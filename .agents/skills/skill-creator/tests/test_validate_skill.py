"""Focused static-profile regressions for validate_skill.py. Apache-2.0."""

import importlib
import json
import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

SCRIPTS = Path(__file__).resolve().parents[1] / "scripts"
sys.path.insert(0, str(SCRIPTS))
validator = importlib.import_module("validate_skill")
validate_skill = validator.validate_skill
yaml = validator.yaml


class ValidateSkillTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.skill = Path(self.temp.name) / "sample-skill"
        self.skill.mkdir()

    def write_skill(self, data=None, body="# Workflow\nDo the task."):
        if data is None:
            data = {"name": self.skill.name, "description": "Process supplied reports."}
        (self.skill / "SKILL.md").write_text(
            "---\n" + yaml.safe_dump(data) + "---\n" + body, encoding="utf-8"
        )

    def test_minimal_and_standard_optional_fields(self):
        self.write_skill()
        self.assertEqual(validate_skill(self.skill), [])
        self.write_skill({
            "name": self.skill.name, "description": "Process reports.",
            "license": "Apache-2.0", "compatibility": "Python 3",
            "metadata": {"owner": "team"}, "allowed-tools": "Read Bash(python3:*)",
        })
        self.assertEqual(validate_skill(self.skill), [])

    def test_missing_empty_wrong_type_required_fields(self):
        for field in ("name", "description"):
            for value in (None, "", "  \t", 123, False, [], {}):
                with self.subTest(field=field, value=value):
                    data: dict[object, object] = {"name": self.skill.name, "description": "Process reports."}
                    data[field] = value
                    self.write_skill(data)
                    self.assertTrue(validate_skill(self.skill))
            data = {"name": self.skill.name, "description": "Process reports."}
            del data[field]
            self.write_skill(data)
            self.assertTrue(validate_skill(self.skill))

    def test_invalid_names_and_folder_mismatch(self):
        for name in ("Sample", "sample_skill", "-sample", "sample-", "sample--skill",
                     "sämple", "sample/skill", " sample-skill", "other-name", "a" * 65):
            with self.subTest(name=name):
                self.write_skill({"name": name, "description": "Useful description"})
                self.assertTrue(validate_skill(self.skill))

    def test_length_boundaries(self):
        self.skill = self.skill.parent / ("a" * 64)
        self.skill.mkdir()
        self.write_skill({"name": self.skill.name, "description": "d" * 1024,
                          "compatibility": "c" * 500})
        self.assertEqual(validate_skill(self.skill), [])
        for extra in ({"description": "d" * 1025}, {"compatibility": "c" * 501}):
            data = {"name": self.skill.name, "description": "Valid"}
            data.update(extra)
            self.write_skill(data)
            self.assertTrue(validate_skill(self.skill))

    def test_optional_types_and_unknown_fields(self):
        for extra in ({"license": []}, {"license": ""}, {"compatibility": False},
                      {"allowed-tools": ["Read"]}, {"metadata": []},
                      {"metadata": {"version": 1}}, {"metadata": {1: "v"}},
                      {"unknown": "extension"}, {1: "value"}):
            with self.subTest(extra=extra):
                data: dict[object, object] = {}
                data["name"] = self.skill.name
                data["description"] = "Process reports."
                for key, value in extra.items():
                    data[key] = value
                self.write_skill(data)
                self.assertTrue(validate_skill(self.skill))

    def test_frontmatter_failures(self):
        for content in (
            "# No frontmatter", "---\nname: sample-skill", "---\n---\nBody",
            "---\n- sequence\n---\nBody", "---\nname: [\n---\nBody",
            "---\nname: sample-skill\nname: other\n---\nBody",
            "---\n? [a, b]\n: value\n---\nBody",
            "---\n!!python/object/apply:os.system ['false']\n---\nBody",
            "---\nname: sample-skill\ndescription: ok\nmetadata:\n  a: b\n  a: c\n---\nBody",
        ):
            with self.subTest(content=content):
                (self.skill / "SKILL.md").write_text(content, encoding="utf-8")
                self.assertTrue(validate_skill(self.skill))

    def test_nonprintable_frontmatter_returns_diagnostic_without_traceback(self):
        (self.skill / "SKILL.md").write_bytes(
            b"---\nname: sample-skill\ndescription: bad\x00text\n---\nBody\n"
        )
        errors = validate_skill(self.skill)
        self.assertTrue(errors)
        self.assertIn("Invalid YAML frontmatter", errors[0])
        result = subprocess.run(
            [sys.executable, str(SCRIPTS / "validate_skill.py"), str(self.skill)],
            capture_output=True, text=True, check=False,
        )
        self.assertEqual(result.returncode, 1)
        self.assertIn("Invalid YAML frontmatter", result.stderr)
        self.assertNotIn("Traceback", result.stderr)

    def test_empty_body_is_rejected(self):
        self.write_skill(body=" \n\t")
        self.assertIn("SKILL.md body must not be empty", validate_skill(self.skill))

    def test_crlf_and_multiline_description(self):
        (self.skill / "SKILL.md").write_bytes(
            b"---\r\nname: sample-skill\r\ndescription: >\r\n  Process reports\r\n"
            b"  when reviewing.\r\n---\r\n# Workflow\r\nDo work.\r\n"
        )
        self.assertEqual(validate_skill(self.skill), [])

    def test_missing_unreadable_and_non_utf8(self):
        self.assertTrue(validate_skill(self.skill))
        (self.skill / "SKILL.md").mkdir()
        self.assertTrue(validate_skill(self.skill))
        (self.skill / "SKILL.md").rmdir()
        (self.skill / "SKILL.md").write_bytes(b"\xff")
        self.assertTrue(validate_skill(self.skill))

    def test_cli_from_unrelated_cwd(self):
        self.write_skill()
        command = [sys.executable, str(SCRIPTS / "validate_skill.py"), str(self.skill)]
        result = subprocess.run(command, cwd=self.temp.name, capture_output=True, text=True, check=False)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("Not full spec", result.stdout)
        self.write_skill(body="")
        result = subprocess.run(command, cwd=self.temp.name, capture_output=True, text=True, check=False)
        self.assertEqual(result.returncode, 1)
        self.assertIn("body", result.stderr)

    def test_missing_dependency_has_actionable_error(self):
        for script in ("validate_skill.py", "init_skill.py"):
            result = subprocess.run(
                [sys.executable, "-S", str(SCRIPTS / script), "--help"],
                env={**os.environ, "PYTHONPATH": ""}, capture_output=True, text=True, check=False,
            )
            self.assertNotEqual(result.returncode, 0)
            self.assertIn("PyYAML is required", result.stderr)
            self.assertNotIn("Traceback", result.stderr)

    def test_bundled_skill_and_unexecuted_example(self):
        root = SCRIPTS.parent
        self.assertEqual(validate_skill(root), [])
        example = json.loads((root / "references/eval-example.json").read_text(encoding="utf-8"))
        self.assertTrue(example["task_cases"])
        self.assertEqual({case["should_select"] for case in example["discovery_cases"]}, {True, False})
        self.assertNotIn("results", example)


if __name__ == "__main__":
    unittest.main()
