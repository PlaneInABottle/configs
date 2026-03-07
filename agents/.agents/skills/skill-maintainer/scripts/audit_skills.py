#!/usr/bin/env python3
"""Audit a local skills tree for structural and content issues."""

from __future__ import annotations

import argparse
import re
import subprocess
import sys
from dataclasses import dataclass, field
from pathlib import Path

MARKDOWN_LINK_RE = re.compile(r"\[[^\]]+\]\(([^)]+)\)")
FRONTMATTER_RE = re.compile(r"^---\n.*?\n---\n?", re.DOTALL)
HEADING_RE = re.compile(r"^(#{1,6})\s+(.+?)\s*$")
SKILL_MD_LINE_WARN = 500
REFERENCE_LINE_WARN = 100


@dataclass
class SkillAudit:
    name: str
    path: Path
    errors: list[str] = field(default_factory=list)
    warnings: list[str] = field(default_factory=list)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("skills_root", type=Path, help="Path to the skills root to audit")
    parser.add_argument(
        "--validator",
        type=Path,
        default=None,
        help="Optional path to skill-creator/scripts/quick_validate.py",
    )
    return parser.parse_args()


def discover_skill_dirs(skills_root: Path) -> list[Path]:
    return sorted(path for path in skills_root.iterdir() if path.is_dir())


def strip_frontmatter(markdown: str) -> str:
    return FRONTMATTER_RE.sub("", markdown, count=1)


def normalize_heading(text: str) -> str:
    normalized = re.sub(r"[^a-z0-9]+", " ", text.lower()).strip()
    return re.sub(r"\s+", " ", normalized)


def is_local_link(target: str) -> bool:
    if not target or target.startswith("#"):
        return False
    if "://" in target or target.startswith("mailto:"):
        return False
    cleaned = target.split("#", 1)[0].split("?", 1)[0]
    looks_like_file = bool(Path(cleaned).suffix) or "/" in cleaned or cleaned.startswith(".")
    if not looks_like_file:
        return False
    return True


def resolve_local_link(skill_md: Path, target: str) -> Path:
    cleaned = target.split("#", 1)[0].split("?", 1)[0]
    return (skill_md.parent / cleaned).resolve()


def find_missing_local_links(skill_md: Path, content: str) -> list[str]:
    missing: list[str] = []
    for match in MARKDOWN_LINK_RE.finditer(content):
        target = match.group(1).strip()
        if not is_local_link(target):
            continue
        resolved = resolve_local_link(skill_md, target)
        if not resolved.exists():
            missing.append(target)
    return sorted(set(missing))


def has_trigger_duplication_heading(content: str) -> bool:
    body = strip_frontmatter(content)
    for raw_line in body.splitlines():
        match = HEADING_RE.match(raw_line)
        if not match:
            continue
        heading = normalize_heading(match.group(2))
        tokens = set(heading.split())
        if "skill" not in tokens:
            continue
        if "when" in tokens and ("use" in tokens or "load" in tokens or "applies" in tokens):
            return True
        if "triggers" in tokens:
            return True
    return False


def line_count(path: Path) -> int:
    return len(path.read_text(encoding="utf-8").splitlines())


def reference_paths(skill_dir: Path) -> list[Path]:
    references_dir = skill_dir / "references"
    if not references_dir.exists():
        return []
    return sorted(path for path in references_dir.rglob("*") if path.is_file())


def find_size_warnings(skill_dir: Path) -> list[str]:
    warnings: list[str] = []
    skill_md = skill_dir / "SKILL.md"
    if skill_md.exists():
        skill_lines = line_count(skill_md)
        if skill_lines > SKILL_MD_LINE_WARN:
            warnings.append(
                f"SKILL.md is {skill_lines} lines; consider moving detail into references (warn threshold {SKILL_MD_LINE_WARN})"
            )
    for reference in reference_paths(skill_dir):
        if reference.suffix.lower() != ".md":
            continue
        ref_lines = line_count(reference)
        if ref_lines > REFERENCE_LINE_WARN:
            warnings.append(
                f"{reference.relative_to(skill_dir)} is {ref_lines} lines; add a table of contents or split it (warn threshold {REFERENCE_LINE_WARN})"
            )
    return warnings


def run_quick_validate(skill_dir: Path, validator_path: Path) -> tuple[bool, str]:
    result = subprocess.run(
        [sys.executable, str(validator_path), str(skill_dir)],
        capture_output=True,
        text=True,
        check=False,
    )
    message = (result.stdout or result.stderr).strip() or "validator returned no output"
    return result.returncode == 0, message


def default_validator_path() -> Path:
    return Path(__file__).resolve().parents[2] / "skill-creator" / "scripts" / "quick_validate.py"


def audit_skill_dir(skill_dir: Path, validator_path: Path) -> SkillAudit:
    audit = SkillAudit(name=skill_dir.name, path=skill_dir)
    skill_md = skill_dir / "SKILL.md"
    if not skill_md.exists():
        audit.errors.append("SKILL.md not found")
        return audit

    content = skill_md.read_text(encoding="utf-8")
    missing_links = find_missing_local_links(skill_md, content)
    for target in missing_links:
        audit.errors.append(f"missing linked local reference: {target}")

    if has_trigger_duplication_heading(content):
        audit.errors.append("body-level trigger duplication heading detected")

    valid, message = run_quick_validate(skill_dir, validator_path)
    if not valid:
        audit.errors.append(f"quick_validate.py failed: {message}")

    audit.warnings.extend(find_size_warnings(skill_dir))
    return audit


def print_report(skills_root: Path, audits: list[SkillAudit]) -> None:
    error_count = sum(len(audit.errors) for audit in audits)
    warning_count = sum(len(audit.warnings) for audit in audits)
    print(f"Skills root: {skills_root}")
    print(f"Skills scanned: {len(audits)}")
    print(f"Errors: {error_count}")
    print(f"Warnings: {warning_count}")
    print()
    for audit in audits:
        status = "FAIL" if audit.errors else "PASS"
        print(f"[{status}] {audit.name}")
        if audit.errors:
            for error in audit.errors:
                print(f"  ERROR: {error}")
        if audit.warnings:
            for warning in audit.warnings:
                print(f"  WARN: {warning}")
        print()


def main() -> int:
    args = parse_args()
    skills_root = args.skills_root.resolve()
    validator_path = (args.validator.resolve() if args.validator else default_validator_path())
    if not skills_root.exists():
        print(f"Skills root not found: {skills_root}", file=sys.stderr)
        return 2
    if not validator_path.exists():
        print(f"Validator not found: {validator_path}", file=sys.stderr)
        return 2
    audits = [audit_skill_dir(skill_dir, validator_path) for skill_dir in discover_skill_dirs(skills_root)]
    print_report(skills_root, audits)
    return 1 if any(audit.errors for audit in audits) else 0


if __name__ == "__main__":
    raise SystemExit(main())
