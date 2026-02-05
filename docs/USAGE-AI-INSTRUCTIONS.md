# Global AI Instructions Setup

`setup-ai-instructions.sh` manages global AI instruction files for Claude, GitHub Copilot, Google Gemini, Qwen, and OpenCode from a single unified template.

**Key Concept:** AI agents analyze projects/requirements and provide the full instruction content via `--set-content` flag. The script then distributes this content across all 5 AI tools automatically.

---

## Quick Start

```bash
# Generate all 5 AI instruction files
./setup-ai-instructions.sh \
  --set-description="Your instructions description" \
  --set-content="# Full instruction content here\n\nComplete markdown content with all sections..."

# Update only specific tools
./setup-ai-instructions.sh --update --only=claude,copilot \
  --set-content="Updated content"

# Generate only one tool
./setup-ai-instructions.sh --only=gemini \
  --set-content="Gemini-specific instructions"
```

---

## What It Does

1. **Reads:** Single template file with placeholders
2. **Substitutes:** AI-provided content into template
3. **Generates:** 5 separate instruction files (one per AI tool)
4. **Stores:** Files in correct symlinked locations for each tool

### Files Generated

| Tool | Location | Symlink |
|------|----------|---------|
| Claude | `~/.claude/CLAUDE.md` | ✅ Configured |
| Copilot | `~/.copilot/copilot-instructions.md` | ✅ Configured |
| Gemini | `~/.gemini/GEMINI.md` | ✅ Configured |
| Qwen | `~/.qwen/QWEN.md` | ✅ Configured |
| OpenCode | `~/.opencode/OPENCODE.md` | ✅ Configured |

---

## Command Line Options

### Required (unless --update mode)

```bash
--set-content="TEXT"           # Full instruction content (use \n for newlines)
--set-description="TEXT"       # Description for frontmatter (default: Global AI...)
```

### Flags

```bash
-h, --help                     # Show help message
-u, --update                   # Update mode: preserve existing files with confirmation
-f, --force                    # Force overwrite without asking
--only=TOOL[,TOOL]             # Generate only specific tools (default: all)
                               # Valid: claude|copilot|gemini|qwen|opencode|all
```

---

## Examples

### Example 1: Initial Setup with All Tools

```bash
./setup-ai-instructions.sh \
  --force \
  --set-description="Global development standards for all projects" \
  --set-content="# Quick Start Rules\n\n1. Verify claims\n2. Use simple solutions\n3. Reference line numbers\n\n# Architecture Patterns\n\n..."
```

**Output:**
```
ℹ Configuration:
  Description: Global development standards for all projects
  Version: 1.0.0
  Content length: 2543 characters
  Tools to generate: 5

ℹ Generating instruction files...
✓ Generated: claude → ~/.claude/CLAUDE.md
✓ Generated: copilot → ~/.copilot/copilot-instructions.md
✓ Generated: gemini → ~/.gemini/GEMINI.md
✓ Generated: qwen → ~/.qwen/QWEN.md
✓ Generated: opencode → ~/.opencode/OPENCODE.md
✓ Complete: 5/5 files generated
```

### Example 2: Update Only Claude

```bash
./setup-ai-instructions.sh \
  --update \
  --only=claude \
  --set-content="Updated Claude instructions..."
```

### Example 3: Generate Specific Tools

```bash
./setup-ai-instructions.sh \
  --force \
  --only=claude,gemini,qwen \
  --set-description="AI standards" \
  --set-content="..."
```


---

## How AI Should Use This

### Workflow: Analyze → Generate → Update

1. **Analyze Project/Requirements**
   - Review project structure
   - Identify technology stack
   - Understand team practices
   - Determine development standards

2. **Generate Comprehensive Instruction Content**
   - Create markdown with all sections needed
   - Balance meta-instructions and technical standards
   - Include language-specific guidelines
   - Add decision frameworks

3. **Execute Script**
   ```bash
   ./setup-ai-instructions.sh \
     --force \
     --set-description="[Analyzed description]" \
     --set-content="[Generated complete content]"
   ```

4. **Verify Files**
   ```bash
   cat ~/.claude/CLAUDE.md
   cat ~/.copilot/instructions.md
   # ... check all 5 files
   ```

---

## Template Structure

The template file (`templates/AI_INSTRUCTIONS.template.md`) is minimal:

```markdown
---
description: "{{DESCRIPTION}}"
applyTo: "**"
version: "{{VERSION}}"
lastUpdated: "{{TIMESTAMP}}"
---

{{CONTENT}}

---

**Last Updated:** {{TIMESTAMP}}
**Version:** {{VERSION}}
```

**Placeholders:**
- `{{DESCRIPTION}}` - From `--set-description`
- `{{CONTENT}}` - From `--set-content` (your full markdown)

The actual instruction content (philosophy, standards, examples, etc.) comes entirely from the `--set-content` flag. AI provides the complete, structured content. Version and timestamp are tracked via git.

---

## Advanced Usage

### Updating Multiple Tools Separately

```bash
# Generate base version
./setup-ai-instructions.sh --force \
  --set-content="Base instructions"

# Update Claude specifically (keeps other files)
./setup-ai-instructions.sh --update --only=claude \
  --set-content="Claude-specific enhancements..."

# Update Copilot
./setup-ai-instructions.sh --update --only=copilot \
  --set-content="Copilot-optimized content..."
```

### Multiline Content

Use `\n` for newlines in the `--set-content` value:

```bash
./setup-ai-instructions.sh \
  --set-content="# Section 1\n\nParagraph 1\n\n# Section 2\n\nParagraph 2"
```

This renders as:
```
# Section 1

Paragraph 1

# Section 2

Paragraph 2
```

### Special Characters

Escape pipes and quotes in content:

```bash
./setup-ai-instructions.sh \
  --set-content="Use \| for pipes in tables"
```

---

## Troubleshooting

### Missing Template File

**Error:** `Template file not found: /path/templates/AI_INSTRUCTIONS.template.md`

**Fix:** Ensure you're running the script from the configs directory:
```bash
cd /home/mirza/configs
./setup-ai-instructions.sh ...
```

### Content Not Rendering

**Issue:** Multiline content appears on single line

**Fix:** Use `\n` explicitly in `--set-content`:
```bash
# Wrong:
--set-content="Line 1
Line 2"

# Correct:
--set-content="Line 1\nLine 2"
```

### Files Not Accessible

**Issue:** `~/.claude/CLAUDE.md` not found or empty

**Check symlinks:**
```bash
ls -la ~/.claude/
ls -la ~/.copilot/
# Should show → /home/mirza/configs/*/.*
```

**If symlinks missing:** Recreate them
```bash
ln -s /home/mirza/configs/claude/.claude ~/.claude
ln -s /home/mirza/configs/copilot/.copilot ~/.copilot
# ... and so on
```

### Permission Denied

**Error:** `Permission denied` when writing files

**Fix:** Make script executable:
```bash
chmod +x /home/mirza/configs/setup-ai-instructions.sh
```

---

## Comparing with setup-agent-instructions.sh

Both scripts follow the same philosophy:

| Aspect | setup-agent-instructions.sh | setup-ai-instructions.sh |
|--------|------------------------------|------------------------|
| **Purpose** | Generate project-specific agent configs | Generate global AI instructions |
| **Template** | One template per agent type | Single unified template |
| **Output** | 4 files per project (.claude, .gemini, .qwen, AGENTS.md) | 5 files globally (same across symlinks) |
| **Content** | Project-specific (analyzed by AI) | Global standards (provided by AI) |
| **Scope** | Per-project in project folders | System-wide in ~/.{tool}/ |
| **Updating** | Project can have local overrides | Global applies to all projects |
| **Use Case** | "How should I handle THIS project?" | "What are GLOBAL standards?" |

---

## Best Practices

1. **Version your standards** - Increment version when making significant changes
2. **Document philosophy** - Start content with core principles
3. **Keep it current** - Update when tech stack or practices change
4. **Review before update** - Always check existing content before overwriting
5. **Use --update mode** - Preserves existing files, only overwrites confirmed
6. **Test single tool first** - Use `--only=claude` before updating all
7. **Commit to git** - All updated files are version controlled

---

## Git Integration

The generated files are automatically tracked in git:

```bash
# After running setup-ai-instructions.sh
git status
# Shows: modified claude/.claude/CLAUDE.md, copilot/.copilot/copilot-instructions.md, etc.

git add claude/.claude/CLAUDE.md copilot/.copilot/copilot-instructions.md ...
git commit -m "chore: Update global AI instructions"
```

Or commit all at once:
```bash
git add claude/ copilot/ gemini/ qwen/ opencode/
git commit -m "chore: Update global AI instructions - improved standards"
```

---

## Related Files

- **Template:** `templates/AI_INSTRUCTIONS.template.md`
- **Script:** `setup-ai-instructions.sh`
- **Config directory:** `~/.claude/`, `~/.copilot/`, `~/.gemini/`, `~/.qwen/`, `~/.opencode/`
- **Project setup:** `setup-agent-instructions.sh` (for project-specific configs)

---

**Version:** 1.0.0
**Last Updated:** 2025-11-19
**Compatible with:** All AI tools (Claude, Copilot, Gemini, Qwen, OpenCode)
