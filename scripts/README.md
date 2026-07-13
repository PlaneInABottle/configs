# Prompt Generation Scripts

The prompt system has two sources of truth:

- `templates/global-instructions/master.md` for CLI-wide instructions
- `templates/subagents/master/*.md` for role-agent instructions

Generated files must not be edited manually. Update the templates and regenerate.

## Architecture

`scripts/render_prompts.py` is the shared template renderer. It provides:

- Recursive `<!-- INCLUDE:path -->` expansion for role-agent templates
- Nested `<!-- SECTION:id:START:systems -->` filtering
- Per-system text replacements
- Forbidden-token checks to catch platform syntax leakage

`scripts/generate_prompts.py` adds platform-specific headers, locks concurrent runs, writes outputs atomically, and reconciles the expected output inventory. These shell wrappers preserve the established commands:

- `scripts/update-global-instructions.sh`
- `scripts/update-subagents.sh`

`scripts/validate_prompts.py`, exposed through `scripts/validate-prompts.sh`, runs unit tests and checks every generated global and role-agent file byte-for-byte against its source template. It also rejects orphaned or disabled role-agent outputs.

## Global Instructions

```bash
# Regenerate every CLI
./scripts/update-global-instructions.sh

# Regenerate one CLI
./scripts/update-global-instructions.sh --system=opencode

# Preview target paths without writing
./scripts/update-global-instructions.sh --dry-run

# Fail if generated files are stale
./scripts/update-global-instructions.sh --check
```

System metadata and output paths live in `templates/global-instructions/metadata.json`.

## Role Agents

```bash
# Regenerate every enabled role agent
./scripts/update-subagents.sh

# Regenerate one role or one CLI
./scripts/update-subagents.sh --agent=implementer
./scripts/update-subagents.sh --system=copilot

# Preview target paths without writing
./scripts/update-subagents.sh --dry-run

# Fail on stale, missing, or unexpected managed outputs
./scripts/update-subagents.sh --check
```

Agent metadata lives in `templates/subagents/master/METADATA.json`. Each agent declares `enabled_systems`; numeric header-length metadata is not used.

Current role-agent matrix:

| Agent | Copilot | Opencode | Claude |
|---|---:|---:|---:|
| planner | yes | yes | yes |
| analyzer | yes | yes | yes |
| implementer | yes | yes | yes |
| coordinator | yes | yes | no |
| challenger | no | yes | no |

Codex has no generated heavy role agents. Its managed helper files are the built-in `explorer` and `worker` overrides under `codex/.codex/agents/`.

## Sections

```markdown
<!-- SECTION:example:START:copilot,opencode -->
Visible only in Copilot and Opencode.
<!-- SECTION:example:END -->

<!-- SECTION:example_except_codex:START:!codex -->
Visible everywhere except Codex.
<!-- SECTION:example_except_codex:END -->
```

Use unique section IDs. Nested sections are supported.

## Includes

Role-agent templates may include shared fragments:

```markdown
<!-- INCLUDE:templates/shared/subagents/principles.md -->
```

Includes must stay inside the repository. Missing or recursive includes fail generation.

## Validation Workflow

```bash
./scripts/update-global-instructions.sh
./scripts/update-subagents.sh
./scripts/validate-prompts.sh
git diff --check
```

Before committing, inspect `git status` and stage only the intended templates, generated outputs, metadata, scripts, and documentation. Do not stage runtime configuration or unrelated working-tree changes.
