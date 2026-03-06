# Skill Maintenance

## Authority

Treat shipped repository files as the source of truth for skill behavior:

- `scripts/quick_validate.py` defines the active validation contract.
- `scripts/package_skill.py` reuses `quick_validate.py` before creating a `.skill` archive.
- `SKILL.md` should describe the same contract instead of inventing stricter or broader rules.

Current validated frontmatter contract:

- Required keys: `name`, `description`
- Optional keys already accepted by the validator: `license`, `allowed-tools`, `metadata`

Do not add new frontmatter keys in `SKILL.md` guidance unless you intentionally update `scripts/quick_validate.py` and re-validate existing skills.

## Validation Workflow

Validate the edited skill first:

```bash
cd /Users/Y_ALTAY1/.agents/skills/skill-creator
python3 scripts/quick_validate.py /Users/Y_ALTAY1/.agents/skills/skill-creator
```

Then run a repo-level validation pass for all local skills:

```bash
cd /Users/Y_ALTAY1/.agents/skills
for skill_dir in */; do
  [ -f "$skill_dir/SKILL.md" ] || continue
  python3 skill-creator/scripts/quick_validate.py "$skill_dir" || exit 1
done
```

Package only after validation passes:

```bash
cd /Users/Y_ALTAY1/.agents/skills/skill-creator
python3 scripts/package_skill.py /path/to/skill-folder
```

## Update Checklist

1. Inspect `scripts/quick_validate.py` before changing frontmatter guidance.
2. Keep `SKILL.md` concise and move maintenance details into reference files such as this one.
3. Ensure every referenced local file from `SKILL.md` actually exists.
4. Run the edited-skill validation command.
5. Run the repo-level validation loop so active skills still satisfy the shared validator.
