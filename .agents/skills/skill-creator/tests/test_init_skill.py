"""Focused scaffold safety and CLI tests for init_skill.py. Apache-2.0."""

import importlib
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

SCRIPTS = Path(__file__).resolve().parents[1] / "scripts"
sys.path.insert(0, str(SCRIPTS))
scaffolder = importlib.import_module("init_skill")
validator = importlib.import_module("validate_skill")


class InitSkillTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.destination = Path(self.temp.name) / "report-review"
        self.description = "Review reports for unsupported claims. Use when checking evidence."

    def test_minimal_valid_scaffold(self):
        result = scaffolder.init_skill(self.destination, self.description)
        self.assertEqual(result, self.destination)
        self.assertEqual(validator.validate_skill(result), [])
        self.assertEqual([p.name for p in result.iterdir()], ["SKILL.md"])
        content = (result / "SKILL.md").read_text(encoding="utf-8")
        self.assertNotIn("TODO", content)
        self.assertNotIn("openai.yaml", content)
        self.assertNotIn("agents/", content)

    def test_description_is_yaml_safe(self):
        description = "Review: reports\nUse # evidence [not a YAML sequence]."
        scaffolder.init_skill(self.destination, description)
        self.assertEqual(validator.validate_skill(self.destination), [])
        content = (self.destination / "SKILL.md").read_text(encoding="utf-8")
        data = validator.yaml.safe_load(content.split("---", 2)[1])
        self.assertEqual(data["description"], description)

    def test_existing_directory_is_unchanged(self):
        self.destination.mkdir()
        existing = self.destination / "SKILL.md"
        existing.write_text("keep me", encoding="utf-8")
        with self.assertRaises(FileExistsError):
            scaffolder.init_skill(self.destination, self.description)
        self.assertEqual(existing.read_text(encoding="utf-8"), "keep me")

    def test_existing_file_and_dangling_symlink_refused(self):
        self.destination.write_text("keep", encoding="utf-8")
        with self.assertRaises(FileExistsError):
            scaffolder.init_skill(self.destination, self.description)
        self.assertEqual(self.destination.read_text(encoding="utf-8"), "keep")
        self.destination.unlink()
        self.destination.symlink_to(self.destination.parent / "nonexistent")
        with self.assertRaises(FileExistsError):
            scaffolder.init_skill(self.destination, self.description)
        self.assertTrue(self.destination.is_symlink())

    def test_live_directory_symlink_refused(self):
        target = self.destination.parent / "existing"
        target.mkdir()
        self.destination.symlink_to(target, target_is_directory=True)
        with self.assertRaises(FileExistsError):
            scaffolder.init_skill(self.destination, self.description)
        self.assertEqual(list(target.iterdir()), [])

    def test_invalid_name_or_description_leaves_no_destination(self):
        for name, description in (("Bad_Name", self.description), ("a" * 65, self.description),
                                  ("good-name", ""), ("good-name", "  "),
                                  ("good-name", "d" * 1025)):
            destination = self.destination.parent / name
            with self.subTest(name=name, description=description):
                with self.assertRaises(ValueError):
                    scaffolder.init_skill(destination, description)
                self.assertFalse(destination.exists())

    def test_missing_parent_is_not_created(self):
        destination = self.destination / "child"
        with self.assertRaises(FileNotFoundError):
            scaffolder.init_skill(destination, self.description)
        self.assertFalse(self.destination.exists())

    def test_open_failure_cleans_empty_directory(self):
        with patch.object(Path, "open", side_effect=PermissionError("simulated denial")), self.assertRaises(PermissionError):
            scaffolder.init_skill(self.destination, self.description)
        self.assertFalse(self.destination.exists())

    def test_write_failure_cleans_own_partial_output(self):
        original_open = Path.open

        class FailingFile:
            def __init__(self, handle):
                self.handle = handle

            def __enter__(self):
                return self

            def __exit__(self, *args):
                self.handle.close()

            def write(self, content):
                self.handle.write(content[:10])
                raise OSError("simulated disk failure")

        def failing_open(path, *args, **kwargs):
            return FailingFile(original_open(path, *args, **kwargs))

        with patch.object(Path, "open", failing_open), self.assertRaises(OSError):
            scaffolder.init_skill(self.destination, self.description)
        self.assertFalse(self.destination.exists())

    def test_cli_from_unrelated_cwd_and_collision_exit(self):
        command = [sys.executable, str(SCRIPTS / "init_skill.py"), str(self.destination),
                   "--description", self.description]
        result = subprocess.run(command, cwd=self.temp.name, capture_output=True, text=True, check=False)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(validator.validate_skill(self.destination), [])
        result = subprocess.run(command, cwd=self.temp.name, capture_output=True, text=True, check=False)
        self.assertEqual(result.returncode, 1)
        self.assertIn("ERROR", result.stderr)

    def test_cli_missing_arguments_and_invalid_name(self):
        for args, code in (([], 2), ([str(self.destination)], 2),
                           ([str(self.destination.parent / "Bad_Name"), "--description", "Use it"], 1)):
            result = subprocess.run(
                [sys.executable, str(SCRIPTS / "init_skill.py"), *args],
                capture_output=True, text=True, check=False,
            )
            self.assertEqual(result.returncode, code, result.stderr)
        self.assertFalse(self.destination.exists())


if __name__ == "__main__":
    unittest.main()
