#!/usr/bin/env python3
"""Run prompt unit tests and exact generated-output validation."""

from __future__ import annotations

import argparse
import sys
import unittest
from pathlib import Path

from generate_prompts import GenerationError, generate_agents, generate_globals
from render_prompts import RenderError


SCRIPT_DIR = Path(__file__).resolve().parent


def main() -> int:
    suite = unittest.defaultTestLoader.discover(
        str(SCRIPT_DIR), pattern="test_*prompts.py"
    )
    if not unittest.TextTestRunner(verbosity=1).run(suite).wasSuccessful():
        return 1

    args = argparse.Namespace(system="all", agent="all", dry_run=False, check=True)
    try:
        valid = generate_globals(args)
        valid = generate_agents(args) and valid
    except (OSError, ValueError, RenderError, GenerationError) as error:
        print(f"ERROR: {error}", file=sys.stderr)
        return 1

    if valid:
        print("All prompt templates and generated outputs are valid and synchronized.")
        return 0
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
