#!/usr/bin/env python3

import tempfile
import unittest
from pathlib import Path

from render_prompts import RenderError, render


class RenderPromptsTest(unittest.TestCase):
    def test_filters_nested_sections(self) -> None:
        source = """before
<!-- SECTION:outer:START:copilot -->
outer
<!-- SECTION:inner:START:!copilot -->
hidden
<!-- SECTION:inner:END -->
<!-- SECTION:outer:END -->
after
"""
        self.assertEqual(render(source, "copilot", {}), "before\nouter\n\nafter\n")

    def test_applies_replacements_and_rejects_leaks(self) -> None:
        metadata = {
            "systems": {
                "opencode": {
                    "text_replacements": {"ask_user": "question"},
                    "forbidden_tokens": ["ask_user"],
                }
            }
        }
        self.assertEqual(render("Use ask_user", "opencode", metadata), "Use question")

        with self.assertRaises(RenderError):
            render(
                "Use ask-user",
                "opencode",
                {"systems": {"opencode": {"forbidden_tokens": ["ask-user"]}}},
            )

    def test_processes_recursive_includes_and_detects_cycles(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "first.md").write_text("first <!-- INCLUDE:second.md -->", encoding="utf-8")
            (root / "second.md").write_text("second", encoding="utf-8")
            self.assertEqual(
                render("<!-- INCLUDE:first.md -->", "copilot", {}, root),
                "first second",
            )

            (root / "second.md").write_text("<!-- INCLUDE:first.md -->", encoding="utf-8")
            with self.assertRaises(RenderError):
                render("<!-- INCLUDE:first.md -->", "copilot", {}, root)


if __name__ == "__main__":
    unittest.main()
