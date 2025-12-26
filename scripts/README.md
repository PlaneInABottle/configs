# Subagent Management Scripts

Automated system for managing subagent instruction files across Copilot, Opencode, and Claude systems.

## Overview

This system uses **master templates** as single source of truth and generates tool-specific files by combining master content with appropriate headers.

```
templates/subagents/
├── master/                 # Single source of truth
│   ├── planner.md
│   ├── reviewer.md
│   ├── implementer.md
│   ├── coordinator.md
│   ├── prompt-creator.md
│   └── METADATA.json       # Agent metadata (descriptions, examples)
└── headers/                # Tool-specific headers
    ├── copilot.template    # Copilot header format
    ├── opencode.template   # Opencode header format (YAML)
    └── claude.template     # Claude header format
```

## Scripts

### 1. `extract-to-master.sh`

Extracts content from existing subagent files into master templates.

**Usage:**
```bash
./scripts/extract-to-master.sh
```

**What it does:**
- Reads copilot and opencode subagent files
- Extracts content (excluding headers)
- Saves to `templates/subagents/master/{agent}.md`
- Creates header templates
- Generates METADATA.json with descriptions and examples

**When to use:**
- Initial setup (already done)
- After manual edits to subagent files that should become the new master

### 2. `update-subagents.sh`

Generates subagent files from master templates + headers.

**Usage:**
```bash
# Update specific agent for all systems
./scripts/update-subagents.sh --agent=debugger

# Update all agents for specific system
./scripts/update-subagents.sh --agent=all --system=copilot
./scripts/update-subagents.sh --agent=all --system=claude

# Dry run to preview changes
./scripts/update-subagents.sh --agent=all --dry-run

# Force overwrite without prompts
./scripts/update-subagents.sh --agent=all --force
```

**Options:**
- `--agent=NAME` - Agent to update (planner|reviewer|implementer|coordinator|prompt-creator|all)
- `--system=NAME` - System to update (copilot|opencode|claude|all) [default: all]
- `--dry-run` - Preview changes without modifying files
- `--force` - Overwrite without confirmation

**What it does:**
- Reads master template content
- Reads metadata (description, examples)
- Generates appropriate header for target system
- Combines header + content
- Writes to target location

**When to use:**
- After editing master templates
- To regenerate all files from master
- To ensure synchronization

### 3. `validate-subagents.sh`

Validates that copilot and opencode files have identical content.

**Usage:**
```bash
./scripts/validate-subagents.sh
```

**What it does:**
- Compares content of copilot vs opencode files (excluding headers)
- Reports which agents are in sync
- Exit code 0 if all synced, 1 if any differ

**When to use:**
- Before committing changes
- To verify synchronization
- In CI/CD pipeline (future)

## Workflow

### Making Changes to Subagents

**Recommended workflow:**

1. **Edit master template:**
   ```bash
   # Edit the master template (e.g., planner, implementer, reviewer, coordinator)
   vim templates/subagents/master/implementer.md
   ```

2. **Update all files:**
   ```bash
   # Dry run first to preview
   ./scripts/update-subagents.sh --agent=implementer --dry-run

   # Apply changes
   ./scripts/update-subagents.sh --agent=implementer --force
   ```

3. **Validate:**
   ```bash
   ./scripts/validate-subagents.sh
   ```

4. **Commit:**
   ```bash
   git add templates copilot opencode
   git commit -m "[subagents] Update implementer: <description>"
   ```

### Bulk Updates

```bash
# Update all subagents
./scripts/update-subagents.sh --agent=all --force

# Validate everything
./scripts/validate-subagents.sh

# Commit if all good
git add templates copilot opencode
git commit -m "[subagents] Bulk update: <description>"
```

## File Structure

### Copilot Format

```markdown
---
name: implementer
description: "..."
---

<content from master template>
```

### Opencode Format

```yaml
---
description: "..."
mode: subagent
examples:
  - "..."
  - "..."
tools:
  write: true
  edit: true
  bash: true
  webfetch: true
  read: true
  grep: true
  glob: true
  list: true
  patch: true
  todowrite: true
  todoread: true
permission:
  webfetch: allow
  bash:
    "git diff": allow
    "git log*": allow
    "git status": allow
    "git show*": allow
    "pytest*": allow
    "npm test*": allow
    "uv run*": allow
    "head*": allow
    "tail*": allow
    "cat*": allow
    "ls*": allow
    "tree*": allow
    "find*": allow
    "grep*": allow
    "echo*": allow
    "wc*": allow
    "pwd": allow
    "sed*": deny
    "awk*": deny
    "*": ask
  edit: ask
---

<content from master template>
```

These Opencode `tools` / `permission` blocks are generated from `METADATA.json`.

- Default (applies to all agents): `defaults.opencode.tools_lines` and `defaults.opencode.permission_lines`
- Per-agent override (optional): `subagents.<agent>.opencode.tools_lines` and `subagents.<agent>.opencode.permission_lines` (falls back to defaults when empty)

### Claude Format

```markdown
---
name: planner
description: "Software architect that creates detailed implementation plans without writing code..."

Examples:
  - "Use for complex multi-step features requiring architectural design"
  - "Use for large refactoring projects needing systematic planning"
tools: Bash, Glob, Grep, LS, Read, Edit, MultiEdit, Write, NotebookEdit, WebFetch, TodoWrite, WebSearch, BashOutput, KillBash, mcp__Context7__resolve-library-id, mcp__Context7__get-library-docs, ListMcpResourcesTool, ReadMcpResourceTool
---

<content from master template>
```

Claude header is generated from `METADATA.json`:

- `name`: Agent name from `subagents.<agent>.name`
- `description`: Agent description from `subagents.<agent>.description`
- `Examples`: Example usage blocks from `subagents.<agent>.examples`
- `tools`: Tools list from `defaults.claude.tools` (same for all agents)

## Design Decisions

### Why Different Headers?

- **Copilot**: Minimal header (4 lines) - only needs name and description
- **Opencode**: Extended YAML header (44-46 lines) - needs detailed tool permissions

Different tools have different requirements. Headers remain tool-specific.

### Why Different Section Structures?

Each subagent serves a different purpose:
- **Planner**: Comprehensive planning with SOLID principles
- **Implementer**: Technology-specific implementation guides
- **Reviewer**: Security and quality focus areas
- **Coordinator**: Multi-phase orchestration (Opencode only)
- **Prompt-Creator**: Prompt engineering specialist (Opencode only)

Custom sections per role ensure maximum clarity and usability.

## Current Status

✅ **Working:**
- Extraction script (`extract-to-master.sh`)
- Generation script (`update-subagents.sh`)
- Validation script (`validate-subagents.sh`)
- Master templates created
- Header templates created
- **Claude integration added**

✅ **Implemented Configurability:**
- Opencode header `tools:` and `permission:` blocks are configurable via `templates/subagents/master/METADATA.json`:
  - `defaults.opencode.tools_lines`
  - `defaults.opencode.permission_lines`
- Claude header `tools:` is configurable via `templates/subagents/master/METADATA.json`:
  - `defaults.claude.tools`

✅ **Robust Validation:**
- `validate-subagents.sh` detects content start dynamically (after the last `---` and following blank lines), so it does **not** rely on hardcoded header lengths.

✅ **Multi-System Support:**
- **Copilot**: planner, reviewer, implementer
- **Opencode**: planner, reviewer, implementer, coordinator, prompt-creator
- **Claude**: planner, reviewer, implementer

## Current Status

✅ **Working:**
- Extraction script (`extract-to-master.sh`)
- Generation script (`update-subagents.sh`)
- Validation script (`validate-subagents.sh`)
- Master templates created
- Header templates created

✅ **Implemented Configurability:**
- Opencode header `tools:` and `permission:` blocks are configurable via `templates/subagents/master/METADATA.json`:
  - `defaults.opencode.tools_lines`
  - `defaults.opencode.permission_lines`

✅ **Robust Validation:**
- `validate-subagents.sh` detects content start dynamically (after the last `---` and following blank lines), so it does **not** rely on hardcoded header lengths.

🔧 **TODO (Optional Enhancements):**
- Add per-subagent overrides for opencode tools/permissions (e.g. reviewer stricter than implementer)
- Add a small test suite for the scripts
- CI/CD integration (optional)

## Maintenance

### Adding a New Subagent

1. Create master template: `templates/subagents/master/newagent.md`
2. Add metadata to `METADATA.json`:
   - `name`, `description`, `examples`
   - `header_lines` for each system (copilot, opencode, claude) if applicable
3. Update scripts to include new agent in arrays
4. Run update script: `./scripts/update-subagents.sh --agent=newagent --force`
5. Validate: `./scripts/validate-subagents.sh`

### Updating Master Templates

Master templates are plain markdown files. Edit them directly:

```bash
vim templates/subagents/master/implementer.md
```

Then regenerate:

```bash
./scripts/update-subagents.sh --agent=implementer --force
```

### Verifying Sync

Always validate before committing:

```bash
./scripts/validate-subagents.sh
```

Expected output when synced:
```
✓ planner content identical (1405 lines)
✓ reviewer content identical (448 lines)
✓ implementer content identical (1602 lines)
✓ coordinator content identical (328 lines)

✓ All subagents are in sync!
```

## Troubleshooting

### Validation fails after update

```bash
# Check what actually differs
diff <(tail -n +6 copilot/.copilot/agents/implementer.agent.md) \
     <(tail -n +45 opencode/.config/opencode/agent/implementer.md)

# Re-extract and update
./scripts/extract-to-master.sh
./scripts/update-subagents.sh --agent=implementer --force
```

### Manual edits were made to copilot/opencode files

```bash
# Extract current state to master
./scripts/extract-to-master.sh

# This uses opencode as source of truth
# Review the extracted master templates
vim templates/subagents/master/*.md

# Regenerate to sync everything
./scripts/update-subagents.sh --agent=all --force
```

### Header line counts are wrong

They shouldn’t be anymore: `validate-subagents.sh` detects content start dynamically.

If generation looks wrong, verify the header template and metadata instead:
- `templates/subagents/headers/opencode.template`
- `templates/subagents/master/METADATA.json` (`defaults.opencode.tools_lines`, `defaults.opencode.permission_lines`, and per-agent `examples`)

## Future Enhancements

- [ ] Git pre-commit hook for automatic validation
- [ ] Automated tests for scripts
- [ ] CI/CD integration
- [ ] Version tracking in METADATA.json
- [ ] Diff viewing before update
- [ ] Interactive mode for update script
- [ ] Backup/restore functionality
- [ ] Change log generation

## Related Documentation

- [Subagent Update Script Analysis](../docs/subagent-update-script-analysis.md) - Full analysis and options
- [Project Instructions Generator](./generate-project-instructions.sh) - Generates project-specific AI instruction files for Claude, Gemini, Qwen, and Copilot/OpenCode
