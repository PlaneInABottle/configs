---
name: skill-maintainer
description: Audit, improve, split, deduplicate, and validate repository skills. Use when the task is to inspect a local skills tree, find contradictory guidance, detect broken skill references, decide whether a skill should be split or kept unified, or standardize repository skill quality before handing creation/package mechanics to skill-creator.
---

# Skill Maintainer

Audit skills before editing them. Treat local skill files, shipped scripts, and the shared validator as the primary authority. When a skill makes factual or operational claims, verify them against local evidence and real session findings when feasible.

Use this skill to inventory the active skills tree, surface deterministic structural problems, validate checkable claims, and decide whether a skill needs cleanup, deduplication, or a scope split. When the task becomes “write/update/package the skill files,” load `../skill-creator/SKILL.md` alongside this skill.

## Audit Workflow

1. Inventory the target skills tree before proposing changes.
2. Run `scripts/audit_skills.py` to catch deterministic structural issues first.
3. Read `references/audit-checklist.md` to inspect overlap, contradictions, progressive disclosure, split boundaries, and claim-validation steps.
4. Verify important claims against shipped files, validator output, and reproducible local commands when feasible; mark them as verified, contradicted, or unverified.
5. Use real session evidence to decide whether guidance should be corrected, narrowed, or expanded.
6. Decide whether each issue needs a fix in place, a split, deduplication, or escalation.
7. Hand off mechanical skill authoring or packaging work to [`skill-creator`](../skill-creator/SKILL.md).

## Load These Resources As Needed

- Load [`references/audit-checklist.md`](references/audit-checklist.md) when you need the review rubric and split-vs-keep heuristics.
- Run `python3 scripts/audit_skills.py <skills-root>` for a deterministic inventory of missing `SKILL.md`, missing linked local references, validator failures, trigger-duplication headings, and size warnings.

## Expected Audit Output

- The script prints a summary with `Skills scanned`, `Errors`, and `Warnings`, followed by one `[PASS]` or `[FAIL]` block per immediate skill directory.
- A repository-ready tree should finish with `Errors: 0`; warnings can still appear for oversized references that need progressive-disclosure cleanup.
- An intentionally broken fixture should exit non-zero and show explicit lines such as `SKILL.md not found`, `missing linked local reference: ...`, or `body-level trigger duplication heading detected`.
