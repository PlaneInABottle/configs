# Global Instructions Quick Reference

## Common Commands

```bash
# Update all systems
./scripts/update-global-instructions.sh

# Update specific system
./scripts/update-global-instructions.sh --system=gemini

# Preview changes (dry run)
./scripts/update-global-instructions.sh --dry-run

# Get help
./scripts/update-global-instructions.sh --help
```

## Section Filtering Syntax

```markdown
<!-- Include for specific systems -->
<!-- SECTION:id:START:copilot,claude -->
Content here
<!-- SECTION:id:END -->

<!-- Exclude specific system -->
<!-- SECTION:id:START:!gemini -->
Content here
<!-- SECTION:id:END -->

<!-- Include for all -->
<!-- SECTION:id:START:all -->
Content here
<!-- SECTION:id:END -->
```

## Text Replacements

**In metadata.json:**
```json
"gemini": {
  "text_replacements": {
    "@analyzer": "analyzer",
    "oldterm": "newterm"
  }
}
```

**How it works:**
- Write master.md with `@analyzer`
- Gemini output gets `analyzer` (no @)
- Other systems unchanged

## File Locations

```
templates/global-instructions/
├── master.md              # Edit this file
├── metadata.json          # System configs
├── headers/
│   └── copilot.header    # YAML frontmatter
└── README.md             # Full documentation

Generated files:
├── copilot/.copilot/copilot-instructions.md
├── claude/.claude/CLAUDE.md
├── opencode/.config/opencode/OPENCODE.md
└── gemini/.gemini/GEMINI.md
```

## Workflow

1. **Edit:** `vim templates/global-instructions/master.md`
2. **Preview:** `./scripts/update-global-instructions.sh --dry-run`
3. **Apply:** `./scripts/update-global-instructions.sh`
4. **Commit:** `git add templates/ copilot/ claude/ opencode/ gemini/`

## Supported Systems

| System | Header? | Special Features |
|--------|---------|------------------|
| Copilot | Yes (YAML) | Requires frontmatter |
| Claude | No | Standard markdown |
| OpenCode | No | Standard markdown |
| Gemini | No | @ prefix removed via text_replacements |

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Text replacement not working | Check metadata.json spelling: `text_replacements` |
| Section missing | Verify SECTION markers and system name |
| Header wrong | Check `requires_header` in metadata.json |

See [full documentation](README.md) for details.
