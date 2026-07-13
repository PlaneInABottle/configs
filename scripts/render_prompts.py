#!/usr/bin/env python3
"""Render system-specific prompt templates from shared sources."""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path


SECTION_PATTERN = re.compile(
    r"<!-- SECTION:(\w+):START:([\w,!]+) -->\n?(.*?)\n?<!-- SECTION:\1:END -->",
    re.DOTALL,
)
INCLUDE_PATTERN = re.compile(r"<!-- INCLUDE:(.*?) -->")


class RenderError(RuntimeError):
    pass


def should_include(enabled_for: str, system: str) -> bool:
    selectors = [value.strip() for value in enabled_for.split(",")]
    exclusions = {value[1:] for value in selectors if value.startswith("!")}
    inclusions = {value for value in selectors if not value.startswith("!")}

    if system in exclusions:
        return False
    if inclusions:
        return system in inclusions or "all" in inclusions
    return True


def process_includes(content: str, repository_root: Path, stack: tuple[Path, ...] = ()) -> str:
    root = repository_root.resolve()

    def replace(match: re.Match[str]) -> str:
        relative_path = match.group(1).strip()
        include_path = (root / relative_path).resolve()
        if include_path != root and root not in include_path.parents:
            raise RenderError(f"Include escapes repository root: {relative_path}")
        if include_path in stack:
            chain = " -> ".join(str(path) for path in (*stack, include_path))
            raise RenderError(f"Recursive include detected: {chain}")
        if not include_path.is_file():
            raise RenderError(f"Include not found: {relative_path}")
        included = include_path.read_text(encoding="utf-8")
        return process_includes(included, root, (*stack, include_path))

    return INCLUDE_PATTERN.sub(replace, content)


def filter_sections(content: str, system: str) -> str:
    result = content
    while True:
        updated = SECTION_PATTERN.sub(
            lambda match: match.group(3) if should_include(match.group(2), system) else "",
            result,
        )
        if updated == result:
            return result
        result = updated


def render(
    content: str,
    system: str,
    metadata: dict,
    repository_root: Path | None = None,
) -> str:
    if repository_root is not None:
        content = process_includes(content, repository_root)

    result = filter_sections(content, system)
    system_metadata = metadata.get("systems", {}).get(system, {})
    for old_text, new_text in system_metadata.get("text_replacements", {}).items():
        result = result.replace(old_text, new_text)

    result = re.sub(r"\n{3,}", "\n\n", result)
    forbidden = system_metadata.get("forbidden_tokens", [])
    leaked = [token for token in forbidden if token in result]
    if leaked:
        raise RenderError(
            f"Forbidden token(s) in {system} output: {', '.join(sorted(leaked))}"
        )
    return result


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--system", required=True)
    metadata = parser.add_mutually_exclusive_group(required=True)
    metadata.add_argument("--metadata", type=Path)
    metadata.add_argument("--metadata-json")
    parser.add_argument("--input", type=Path, required=True)
    parser.add_argument("--repository-root", type=Path)
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    try:
        metadata_source = (
            args.metadata_json
            if args.metadata_json is not None
            else args.metadata.read_text(encoding="utf-8")
        )
        metadata = json.loads(metadata_source)
        content = args.input.read_text(encoding="utf-8")
        output = render(content, args.system, metadata, args.repository_root)
    except (OSError, json.JSONDecodeError, RenderError) as error:
        print(f"render_prompts.py: {error}", file=sys.stderr)
        return 1

    sys.stdout.write(output)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
