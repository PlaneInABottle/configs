# Global Instructions Template System

Automated system for managing global instruction files across Copilot, Claude, OpenCode, and Gemini from a single master template.

## Overview

This system uses a **master template** (`master.md`) as the single source of truth and generates system-specific files by:
1. **Section filtering**: Include/exclude sections per system
2. **Text replacements**: Replace system-specific terminology
3. **Header injection**: Add tool-specific headers (if required)

```
templates/global-instructions/
├── master.md              # Single source of truth
├── metadata.json          # System configurations
├── headers/               # System-specific headers
│   └── copilot.header    # YAML frontmatter for Copilot
└── README.md             # This file
```

## Quick Start

### Update All Systems
```bash
./scripts/update-global-instructions.sh
```

### Update Specific System
```bash
./scripts/update-global-instructions.sh --system=gemini
./scripts/update-global-instructions.sh --system=copilot
```

### Preview Changes (Dry Run)
```bash
./scripts/update-global-instructions.sh --dry-run
```

## Features

### 1. Section Filtering

Control which sections appear in which systems using HTML comments:

```markdown
<!-- SECTION:section_id:START:copilot,claude -->
This content only appears in Copilot and Claude
<!-- SECTION:section_id:END -->

<!-- SECTION:advanced_features:START:!gemini -->
This appears in all systems EXCEPT Gemini
<!-- SECTION:advanced_features:END -->

<!-- SECTION:universal:START:all -->
This appears in all systems
<!-- SECTION:universal:END -->
```

**Syntax:**
- `copilot,claude` - Include only for these systems
- `!gemini` - Include for all EXCEPT Gemini
- `all` - Include for all systems

**When to use:**
- System-specific features (e.g., Copilot's `task_complete` tool)
- Different capabilities across systems
- Platform-specific instructions

### 2. Text Replacements

Replace system-specific terminology automatically. Configured in `metadata.json`:

```json
"gemini": {
  "text_replacements": {
    "@analyzer": "analyzer",
    "@planner": "planner",
    "@task": "task"
  }
}
```

**How it works:**
- Write master.md using Copilot's `@analyzer` syntax
- Gemini output automatically uses plain `analyzer` names
- Other systems remain unchanged (no replacements = no changes)

**When to use:**
- Different syntax for same concept (e.g., `@agent` vs `agent`)
- System-specific terminology differences
- Command prefix/suffix variations

### 3. Headers

Systems can require YAML frontmatter or other headers.

**Copilot example** (`headers/copilot.header`):
```yaml
---
description: "System prompt with required Context7 MCP usage..."
applyTo: "**"
---
```

**Configuration** (`metadata.json`):
```json
"copilot": {
  "requires_header": true,
  "target_file": "copilot/.copilot/copilot-instructions.md"
}
```

Systems with `requires_header: false` get content directly without headers.

## Configuration: metadata.json

### System Configuration

```json
{
  "systems": {
    "gemini": {
      "requires_header": false,
      "target_file": "gemini/.gemini/GEMINI.md",
      "description": "Gemini CLI global instructions",
      "text_replacements": {
        "@analyzer": "analyzer",
        "@planner": "planner"
      }
    }
  }
}
```

**Fields:**
- `requires_header` (boolean) - Whether to inject header before content
- `target_file` (string) - Path relative to configs root
- `description` (string) - Human-readable description
- `text_replacements` (object, optional) - Find/replace map applied after section filtering

### Adding a New System

1. **Add to metadata.json:**
   ```json
   "newsystem": {
     "requires_header": false,
     "target_file": "newsystem/.config/instructions.md",
     "description": "New system instructions"
   }
   ```

2. **Create header if needed:**
   ```bash
   # If requires_header: true
   echo "---\nconfig: value\n---" > templates/global-instructions/headers/newsystem.header
   ```

3. **Update the script:**
   ```bash
   # Edit update-global-instructions.sh, add to valid systems (line 242):
   if [[ "$SYSTEM" != "all" ]] && [[ "$SYSTEM" != "copilot" ]] && \
      [[ "$SYSTEM" != "opencode" ]] && [[ "$SYSTEM" != "claude" ]] && \
      [[ "$SYSTEM" != "gemini" ]] && [[ "$SYSTEM" != "newsystem" ]]; then
   ```

4. **Generate:**
   ```bash
   ./scripts/update-global-instructions.sh --system=newsystem
   ```

## Workflow

### Making Changes to Instructions

**Recommended workflow:**

1. **Edit master template:**
   ```bash
   vim templates/global-instructions/master.md
   ```

2. **Preview changes:**
   ```bash
   ./scripts/update-global-instructions.sh --dry-run
   ```

3. **Apply changes:**
   ```bash
   ./scripts/update-global-instructions.sh
   ```

4. **Verify outputs:**
   ```bash
   # Check generated files
   cat copilot/.copilot/copilot-instructions.md
   cat gemini/.gemini/GEMINI.md
   ```

5. **Commit:**
   ```bash
   git add templates/global-instructions/master.md \
           copilot/.copilot/copilot-instructions.md \
           gemini/.gemini/GEMINI.md \
           claude/.claude/CLAUDE.md \
           opencode/.config/opencode/OPENCODE.md
   git commit -m "Update global instructions: <description>"
   ```

### System-Specific Changes

**Using section filtering:**
```bash
# 1. Add section markers in master.md
<!-- SECTION:copilot_feature:START:copilot -->
Copilot-specific content here
<!-- SECTION:copilot_feature:END -->

# 2. Regenerate
./scripts/update-global-instructions.sh
```

**Using text replacements:**
```bash
# 1. Add replacements to metadata.json
"gemini": {
  "text_replacements": {
    "NewTerm": "gemini-term"
  }
}

# 2. Regenerate
./scripts/update-global-instructions.sh --system=gemini
```

## File Structure

### Generated Files

**Copilot** (`copilot/.copilot/copilot-instructions.md`):
```markdown
---
description: "..."
applyTo: "**"
---

<!-- sync-test: generated via ... -->

# Global Instructions
...
```

**Gemini** (`gemini/.gemini/GEMINI.md`):
```markdown
<!-- sync-test: generated via ... -->

# Global Instructions
...
```
*(Note: @ prefixes replaced with plain names)*

**Claude** (`claude/.claude/CLAUDE.md`):
```markdown
<!-- sync-test: generated via ... -->

# Global Instructions
...
```

**OpenCode** (`opencode/.config/opencode/OPENCODE.md`):
```markdown
<!-- sync-test: generated via ... -->

# Global Instructions
...
```

## Troubleshooting

### Text replacements not working

**Symptom:** `@analyzer` still appears in Gemini output

**Solution:**
1. Verify metadata.json has correct replacements
2. Check key spelling: `"text_replacements"` (not `word_replacements`)
3. Regenerate: `./scripts/update-global-instructions.sh --system=gemini`

### Section not appearing in target system

**Symptom:** Section missing from expected system

**Solution:**
1. Check SECTION markers: `<!-- SECTION:id:START:system -->`
2. Verify system name matches (e.g., `gemini` not `Gemini`)
3. Check for typos in system list
4. Ensure closing `<!-- SECTION:id:END -->` tag exists

### Header missing or wrong format

**Symptom:** Generated file has wrong header

**Solution:**
1. Check `metadata.json`: `"requires_header": true/false`
2. Verify header file exists: `templates/global-instructions/headers/{system}.header`
3. Check header content format
4. Regenerate: `./scripts/update-global-instructions.sh --system={system}`

## Design Decisions

### Why Section Filtering Instead of Multiple Templates?

**Chosen approach:** Single master.md with section markers
- ✅ Single source of truth (DRY principle)
- ✅ Easy to see what differs between systems
- ✅ Changes propagate to all systems by default
- ❌ Master.md has some "noise" from markers

**Alternative (rejected):** Separate templates per system
- ❌ Massive duplication
- ❌ Changes don't propagate
- ❌ High maintenance burden
- ✅ Each file is "clean"

**Verdict:** Single master with markers wins. The marker "noise" is minimal compared to maintaining 4+ separate files.

### Why Text Replacements Instead of Template Variables?

**Chosen approach:** Simple find/replace after filtering

**Alternative (rejected):** Template variables like `{{AGENT_PREFIX}}`
- Would require template engine
- Makes master.md less readable
- Over-engineered for simple string differences

**Verdict:** Text replacements are KISS (Keep It Simple). Perfect for syntax differences.

### Why Python for Processing?

- Already embedded in bash script
- Native regex support
- JSON parsing built-in
- Cross-platform (macOS, Linux)
- No external dependencies beyond Python 3

## Current Status

✅ **Implemented:**
- Section filtering with include/exclude syntax
- Text replacements per system
- Header injection for Copilot
- Dry-run mode
- All 4 systems supported (Copilot, Claude, OpenCode, Gemini)

✅ **Systems:**
- **Copilot**: Full instructions with headers + tool references
- **Claude**: Full instructions without headers
- **OpenCode**: Full instructions without headers
- **Gemini**: Full instructions with @ prefixes removed

## Maintenance

### Updating Master Template

Master template is the **single source of truth**. All edits should go here:

```bash
vim templates/global-instructions/master.md
```

After editing, always regenerate all systems:

```bash
./scripts/update-global-instructions.sh
```

### Adding New Sections

1. **Decide scope:** Which systems need this section?
2. **Add markers if needed:**
   ```markdown
   <!-- SECTION:new_feature:START:copilot,gemini -->
   New content here
   <!-- SECTION:new_feature:END -->
   ```
3. **Regenerate all systems**
4. **Verify each system's output**

### Updating Metadata

When changing `metadata.json`:
- Always validate JSON syntax
- Update version number
- Document changes in this README
- Regenerate to test

## Related Documentation

- [Subagent Management Scripts](../../scripts/README.md) - Similar system for subagent instructions
- [Project Instructions Generator](../../scripts/generate-project-instructions.sh) - Per-project instructions

## Version History

- **1.2.0** (2026-02-08): Added text_replacements feature for Gemini
- **1.1.0** (2025-12-18): Added section filtering
- **1.0.0** (2025-12-18): Initial implementation
