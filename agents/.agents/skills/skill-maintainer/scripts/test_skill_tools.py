#!/usr/bin/env python3

import tempfile
import unittest
from pathlib import Path

from add_reference_tocs import add_contents
from audit_skills import find_size_warnings, has_trigger_duplication_heading


class SkillToolTests(unittest.TestCase):
    def test_detects_generic_trigger_heading(self) -> None:
        self.assertTrue(has_trigger_duplication_heading("---\nname: x\n---\n## When to Use\n"))
        self.assertFalse(has_trigger_duplication_heading("## When to Use Docker vs CLI\n"))

    def test_existing_contents_suppresses_reference_warning(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            skill_dir = Path(directory)
            references = skill_dir / "references"
            references.mkdir()
            (skill_dir / "SKILL.md").write_text("# Skill\n", encoding="utf-8")
            content = "# Reference\n\n## Contents\n\n- [Topic](#topic)\n\n## Topic\n" + "line\n" * 101
            (references / "large.md").write_text(content, encoding="utf-8")
            self.assertEqual(find_size_warnings(skill_dir), [])

    def test_add_contents_indexes_h2_and_ignores_fences(self) -> None:
        content = "# Reference\n\n```md\n## Not a heading\n```\n\n## Real Heading\n"
        updated = add_contents(content)
        self.assertIsNotNone(updated)
        assert updated is not None
        self.assertIn("- [Real Heading](#real-heading)", updated)
        self.assertNotIn("- [Not a heading]", updated)


if __name__ == "__main__":
    unittest.main()
