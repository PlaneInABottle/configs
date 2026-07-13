#!/usr/bin/env python3
"""Add H2 contents sections to oversized skill references."""

from __future__ import annotations

import argparse
import re
from pathlib import Path

HEADING_RE = re.compile(r"^(#{1,6})\s+(.+?)\s*$")
CONTENTS_RE = re.compile(r"^##\s+(?:Table of )?Contents\s*$", re.IGNORECASE | re.MULTILINE)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("skills_root", type=Path)
    parser.add_argument("--write", action="store_true", help="Write updates instead of listing files")
    parser.add_argument("--min-lines", type=int, default=100)
    return parser.parse_args()


def slugify(text: str) -> str:
    text = re.sub(r"<[^>]+>", "", text).strip().lower()
    text = re.sub(r"[^\w\- ]", "", text, flags=re.UNICODE)
    return re.sub(r"[\s-]+", "-", text).strip("-")


def h2_headings(content: str) -> list[str]:
    headings: list[str] = []
    in_fence = False
    for line in content.splitlines():
        if line.lstrip().startswith("```"):
            in_fence = not in_fence
            continue
        if in_fence:
            continue
        match = HEADING_RE.match(line)
        if match and match.group(1) == "##" and match.group(2).lower() not in {"contents", "table of contents"}:
            headings.append(match.group(2).strip())
    return headings


def add_contents(content: str) -> str | None:
    if CONTENTS_RE.search(content):
        normalized = re.sub(r"^(# .+?)\n{3,}(## (?:Table of )?Contents)$", r"\1\n\n\2", content, count=1, flags=re.MULTILINE | re.IGNORECASE)
        return normalized if normalized != content else None
    headings = h2_headings(content)
    if not headings:
        return None
    lines = content.splitlines()
    insert_at = 1 if lines and lines[0].startswith("# ") else 0
    while insert_at < len(lines) and not lines[insert_at].strip():
        insert_at += 1
    toc = ["## Contents", "", *[f"- [{heading}](#{slugify(heading)})" for heading in headings], ""]
    return "\n".join(lines[:insert_at] + toc + lines[insert_at:]) + "\n"


def main() -> int:
    args = parse_args()
    changed = 0
    for reference in sorted(args.skills_root.glob("*/references/*.md")):
        content = reference.read_text(encoding="utf-8")
        if len(content.splitlines()) <= args.min_lines:
            continue
        updated = add_contents(content)
        if updated is None:
            continue
        print(reference)
        changed += 1
        if args.write:
            reference.write_text(updated, encoding="utf-8")
    print(f"References {'updated' if args.write else 'needing contents'}: {changed}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
