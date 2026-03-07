# Skill Audit Checklist

**Related**: [SKILL.md](../SKILL.md), [skill-creator](../../skill-creator/SKILL.md)

## Contents

- [Structural checks](#structural-checks)
- [Content quality checks](#content-quality-checks)
- [Claim validation](#claim-validation)
- [Scope and split decisions](#scope-and-split-decisions)
- [Validation workflow](#validation-workflow)

## Structural checks

- Confirm every immediate skill directory contains `SKILL.md`.
- Confirm every local file linked from `SKILL.md` exists before treating the skill as ready.
- Run the shared validator on each skill to catch frontmatter drift before reviewing prose.
- Flag body headings that duplicate trigger guidance such as `When to Use This Skill`; trigger rules belong in frontmatter `description`.
- Warn when `SKILL.md` grows beyond the local progressive-disclosure budget or a reference file grows large enough to need its own table of contents.

## Content quality checks

- Check whether the frontmatter `description` states both what the skill does and when it should load.
- Remove duplicated guidance between `SKILL.md` and `references/`; keep the body as the concise entrypoint.
- Look for contradictory instructions across skill files and validator-backed tooling. Prefer shipped scripts as the authority when prose disagrees.
- Verify examples, commands, and linked sibling files still match the repository layout.
- Record whether the skill is focused on one concern or has started to absorb unrelated workflow guidance.

## Claim validation

- Treat shipped files and scripts as the primary authority for repository-specific claims.
- Reproduce tool or workflow behavior with local commands when feasible instead of assuming prose is still correct.
- Classify each meaningful factual or operational claim as `verified`, `contradicted`, or `unverified`.
- When real session evidence changes your understanding, update the skill so the next run reflects what actually happened.

## Scope and split decisions

- Keep a skill unified when its resources support one coherent concern and the references stay navigable.
- Split a skill when the trigger surface spans separate concerns, when one part is meta-governance instead of task execution, or when the body needs unrelated decision trees to stay usable.
- Prefer moving detail into references before creating a new skill; do not split only because a single section is long.
- When the task is repository skill governance, keep this skill focused on audit decisions and link to `skill-creator` for creation, editing, and packaging mechanics.
- Document split decisions with local evidence so future audits do not have to rediscover why the boundary exists.

## Validation workflow

1. Run `python3 scripts/audit_skills.py <skills-root>` to inventory deterministic issues first.
2. Read the flagged `SKILL.md` and linked references before proposing fixes.
3. Validate the edited skill with `python3 ../skill-creator/scripts/quick_validate.py <skill-dir>` or the repository-local equivalent.
4. Re-run the audit to confirm the issue list shrank and no new structural regressions appeared.
5. If recent session work triggered the update, capture the observed failure, inefficiency, or confirmation in the skill change while it is still concrete.
6. If the fix requires new files, packaging, or broader authoring changes, continue with `skill-creator`.
