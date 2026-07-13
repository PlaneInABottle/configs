#!/usr/bin/env python3

import tempfile
import unittest
from contextlib import redirect_stdout
from io import StringIO
from pathlib import Path
from unittest.mock import patch

from generate_prompts import (
    agent_header,
    apply_output,
    reconcile_agent_outputs,
    remove_or_reject_stale,
)


class GeneratePromptsTest(unittest.TestCase):
    def test_atomic_output_and_check(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            target = Path(directory) / "output.md"
            with redirect_stdout(StringIO()):
                self.assertTrue(apply_output(target, "content\n", check=False, dry_run=False))
            self.assertEqual(target.read_text(encoding="utf-8"), "content\n")
            with redirect_stdout(StringIO()):
                self.assertTrue(apply_output(target, "content\n", check=True, dry_run=False))
                self.assertFalse(apply_output(target, "changed\n", check=True, dry_run=False))

    def test_stale_output_handling(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            target = Path(directory) / "stale.md"
            target.write_text("stale", encoding="utf-8")
            with redirect_stdout(StringIO()):
                self.assertFalse(remove_or_reject_stale(target, check=True, dry_run=False))
                self.assertTrue(remove_or_reject_stale(target, check=False, dry_run=False))
            self.assertFalse(target.exists())

    def test_headers_match_supported_systems(self) -> None:
        agent = {
            "name": "reviewer",
            "description": "Reviews code.",
            "mode": "subagent",
            "examples": ['  - "Review this"'],
        }
        self.assertIn("name: reviewer", agent_header(agent, "copilot"))
        self.assertIn("model: inherit", agent_header(agent, "claude"))
        self.assertIn("mode: subagent", agent_header(agent, "opencode"))

    def test_reconciles_orphaned_outputs(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            orphan = root / "opencode/.config/opencode/agent/orphan.md"
            explorer = root / "codex/.codex/agents/explorer.toml"
            orphan.parent.mkdir(parents=True)
            explorer.parent.mkdir(parents=True)
            orphan.write_text("orphan", encoding="utf-8")
            explorer.write_text("managed elsewhere", encoding="utf-8")

            with patch("generate_prompts.ROOT", root), redirect_stdout(StringIO()):
                self.assertTrue(
                    reconcile_agent_outputs(
                        {"subagents": {}}, check=False, dry_run=False
                    )
                )

            self.assertFalse(orphan.exists())
            self.assertTrue(explorer.exists())


if __name__ == "__main__":
    unittest.main()
