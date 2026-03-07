# Skill Maintenance

## Authority

Treat shipped repository files as the source of truth for skill behavior:

- `scripts/quick_validate.py` defines the active validation contract.
- `scripts/package_skill.py` reuses `quick_validate.py` before creating a `.skill` archive.
- `SKILL.md` should describe the same contract instead of inventing stricter or broader rules.
- When `SKILL.md` or `references/` make factual or operational claims, verify them against current files, shipped tooling output, or other local evidence before treating them as repository guidance.

Current validated frontmatter contract:

- Required keys: `name`, `description`
- Optional keys already accepted by the validator: `license`, `allowed-tools`, `metadata`

Do not add new frontmatter keys in `SKILL.md` guidance unless you intentionally update `scripts/quick_validate.py` and re-validate existing skills.

## Active Tree Rules

Keep `.agents/skills/` structurally valid at all times.

- Do not leave incomplete or stub skills in the active skills tree.
- If a skill is not ready to satisfy the shared validator, keep it outside `.agents/skills/` until it is complete enough to validate cleanly.
- If a skill is intentionally abandoned or superseded, remove or archive the whole skill directory instead of leaving a partial placeholder behind.
- Treat every file path referenced from `SKILL.md` as a repository readiness rule: referenced files must exist before the skill is considered ready.

Use frontmatter `description` as the primary trigger surface for when a skill should load.

- Put "when to use this skill" guidance in `description`.
- Keep the body focused on execution guidance after the skill has already triggered.
- Do not rely on a body-level "When to Use This Skill" section as the primary trigger definition.

## Validation Workflow

Validate the edited skill first:

```bash
cd agents/.agents/skills/skill-creator
python3 scripts/quick_validate.py .
```

Then run a repo-level validation pass for all local skills:

```bash
cd agents/.agents/skills
for skill_dir in */; do
  [ -f "$skill_dir/SKILL.md" ] || continue
  python3 skill-creator/scripts/quick_validate.py "$skill_dir" || exit 1
done
```

Package only after validation passes:

```bash
cd agents/.agents/skills/skill-creator
python3 scripts/package_skill.py /path/to/skill-folder
```

## Update Checklist

1. Inspect `scripts/quick_validate.py` before changing frontmatter guidance.
2. Keep `SKILL.md` concise and move maintenance details into reference files such as this one.
3. Ensure the active skills tree contains no incomplete or stub skill directories.
4. Ensure every referenced local file from `SKILL.md` actually exists.
5. Keep trigger guidance primarily in frontmatter `description`, not a body-only usage section.
6. Run the edited-skill validation command.
7. Run the repo-level validation loop so active skills still satisfy the shared validator.
8. When live session work confirms or disproves current instructions, make the smallest evidence-backed update and re-validate the affected skill.
