# AI Agent Instructions Setup - Usage Guide

## Overview

This system provides a streamlined way to set up AI coding agent instructions for new projects. It separates **global rules** (universal best practices) from **project-specific context** (your project details).

## Architecture

### Global Configs (User-Wide)
Located in `~/configs/`, these contain universal development rules:
- `~/configs/claude/.claude/CLAUDE.md` - Claude Code global rules
- `~/configs/gemini/.gemini/GEMINI.md` - Gemini Code global rules
- `~/configs/qwen/.qwen/QWEN.md` - Qwen Code global rules
- `~/configs/opencode/.config/opencode/AGENTS.md` - OpenCode global rules

**Note:** GitHub Copilot has NO global config support.

### Project-Specific Files
Generated per project, containing only project context:
- `.claude/CLAUDE.md` - Claude project context
- `.gemini/GEMINI.md` - Gemini project context
- `.qwen/QWEN.md` - Qwen project context
- `AGENTS.md` - Comprehensive (for Copilot + OpenCode)

## Quick Start

### 1. Set Up a New Project

```bash
cd ~/configs
./setup-agent-instructions.sh /path/to/your/project
```

The script will:
1. Auto-detect your project type (React, Next.js, Python, etc.)
2. Offer to use a preset or collect details manually
3. Generate all 4 agent instruction files

### 2. Update an Existing Project

```bash
cd ~/configs
./setup-agent-instructions.sh --update /path/to/your/project
```

Update mode will:
1. Load existing project values from current files
2. Show current values and ask if you want to keep them
3. Regenerate ALL 4 files (including AGENTS.md)
4. Ask to overwrite each file individually
5. Skip files where you choose 'n'

**Important:** AGENTS.md is included in updates and will be regenerated like other files.

### 3. Available Presets (Optional)

**6 Built-in Presets:**
- **frontend-react** - React + TypeScript + Vite
- **backend-node** - Node.js + Express + PostgreSQL
- **fullstack-nextjs** - Next.js + React + Prisma
- **python-fastapi** - Python + FastAPI + PostgreSQL
- **cli-tool** - Node.js/Go/Rust CLI application
- **library** - Reusable TypeScript library

**Note:** Presets are convenient but **optional**. You can always use manual input for custom tech stacks.

### 4. Example Usage

```bash
# For a new React project
cd ~/projects
mkdir my-react-app
cd my-react-app
npm create vite@latest . -- --template react-ts
~/configs/setup-agent-instructions.sh .
```

The script detects it's a React project and offers the preset!

## Command Line Options

```bash
# Show help
./setup-agent-instructions.sh --help

# Create new project (default)
./setup-agent-instructions.sh /path/to/project

# Update existing project
./setup-agent-instructions.sh --update /path/to/project
./setup-agent-instructions.sh -u /path/to/project
```

## Manual Setup (Without Presets)

### When to Use Manual Mode

Use manual input when:
- Your tech stack isn't covered by the 6 presets
- You have a custom or unique project setup
- You want minimal defaults and will customize later
- Working with mixed or experimental technologies

### How to Use Manual Mode

**Option 1: No detection (project with no markers)**
```bash
# For a project with no package.json, requirements.txt, etc.
./setup-agent-instructions.sh /path/to/custom-project

# Script will prompt for manual input:
Project name [custom-project]: MyCustomApp
Project type (frontend/backend/fullstack/cli/library): backend
Primary language: Rust
Tech stack (comma-separated): Actix, PostgreSQL, Redis
Project description (press Enter twice to finish):
A high-performance API server built with Rust
```

**Option 2: Decline detected preset**
```bash
./setup-agent-instructions.sh /path/to/react-project

# When prompted:
► Detected project type: frontend-react
Use preset 'frontend-react'? (Y/n): n

# Then choose manual:
Would you like to use a preset? (y/N): n

# Then enter your custom details
```

### What Gets Generated (Manual Mode)

Files are created with:
- ✅ Your provided details (name, type, language, stack, description)
- ✅ Placeholder sections for you to fill in:
  - `Add architecture patterns here.`
  - `Add code style guidelines here.`
  - `Add file organization details here.`
  - `Add testing strategy here.`
  - `Add dependency guidelines here.`
  - `Add project-specific notes here.`

### Customize After Generation

```bash
cd your-project

# Edit and fill in the placeholder sections
code .claude/CLAUDE.md
code .gemini/GEMINI.md
code .qwen/QWEN.md
code AGENTS.md

# Or update using the script
~/configs/setup-agent-instructions.sh --update .
```

### Example: Custom Rust Project

```bash
./setup-agent-instructions.sh /path/to/rust-api

# Input:
Project name: rust-actix-api
Project type: backend
Primary language: Rust
Tech stack: Actix Web, PostgreSQL, Redis
Description: High-performance REST API with WebSocket support

# Generated files have your details + placeholders to fill
```

## Customization

### Update Global Rules

Edit the global configs directly:
```bash
# Update Claude global rules
code ~/configs/claude/.claude/CLAUDE.md

# Changes affect ALL projects automatically
```

### Update Project-Specific Context

**Option 1: Edit files directly**
```bash
cd your-project
code .claude/CLAUDE.md  # Update project context
code AGENTS.md          # Update for Copilot/OpenCode
```

**Option 2: Use the update command**
```bash
# Updates all files, loading existing values as defaults
~/configs/setup-agent-instructions.sh --update .

# The script will:
# - Load existing values from .claude/CLAUDE.md
# - Show current values (name, type, language, stack)
# - Ask if you want to keep them (Y/n)
# - Regenerate all 4 files with those values
# - Ask to overwrite each file (y/N)
#   • Claude, Gemini, Qwen (from PROJECT_TEMPLATE)
#   • AGENTS.md (from AGENTS_COMPREHENSIVE_TEMPLATE)
```

### Update Mode Use Cases

**1. Refresh all files (update structure, keep content)**
```bash
./setup-agent-instructions.sh --update .
Keep values: Y
Overwrite Claude: y
Overwrite Gemini: y
Overwrite Qwen: y
Overwrite AGENTS: y
# All files regenerated with same content
```

**2. Change project details (e.g., migrated tech stack)**
```bash
./setup-agent-instructions.sh --update .
Keep values: n
# Enter new values (TypeScript → Go, React → Fiber)
Overwrite all: y
# All files updated with new stack
```

**3. Selective update (only some files)**
```bash
./setup-agent-instructions.sh --update .
Keep values: Y
Overwrite Claude: n  # Skip
Overwrite Gemini: n  # Skip
Overwrite Qwen: y    # Update
Overwrite AGENTS: y  # Update
# Only Qwen and AGENTS updated
```

**⚠️ Important:** Manual edits will be lost if you overwrite. Use version control or answer 'n' to skip files you've customized.

### Add Custom Presets

Want to add your own preset for reuse? Edit `~/configs/templates/presets.json`:

```json
{
  "your-preset-name": {
    "PROJECT_TYPE": "backend",
    "PRIMARY_LANGUAGE": "Go",
    "TECH_STACK": "Go, Gin, PostgreSQL",
    "PROJECT_DESCRIPTION": "A REST API built with Go and Gin framework",
    "KEY_TECHNOLOGIES": "- Go 1.21+\n- Gin web framework\n- GORM for ORM",
    "ARCHITECTURE_PATTERNS": "- MVC architecture\n- Repository pattern\n- Middleware for auth",
    "CODE_STYLE_GUIDE": "- Use gofmt for formatting\n- Follow Go best practices\n- Write table-driven tests",
    "FILE_ORGANIZATION": "```\ncmd/\ninternal/\npkg/\n```",
    "TESTING_STRATEGY": "- Unit tests with testing package\n- Integration tests\n- Aim for >80% coverage",
    "DEPENDENCY_GUIDELINES": "- Use Go modules\n- Keep dependencies minimal\n- Pin versions",
    "PROJECT_NOTES": "Add project-specific notes here."
  }
}
```

After adding, the script will detect and offer your custom preset automatically!

## File Structure

```
your-project/
├── .claude/
│   └── CLAUDE.md          # Project context (references global)
├── .gemini/
│   └── GEMINI.md          # Project context (references global)
├── .qwen/
│   └── QWEN.md            # Project context (references global)
└── AGENTS.md              # Comprehensive (Copilot + OpenCode)
```

## Testing

Run the test suite:
```bash
cd ~/configs
./test-setup-script.sh
```

Tests verify:
- Scripts are executable
- Templates exist and are valid
- JSON syntax is correct
- Placeholders are present
- Project detection works

## Flexibility: Presets vs Manual

### When to Use Presets

✅ **Use a preset when:**
- Your project matches a common tech stack
- You want best practices out-of-the-box
- Quick setup is the priority
- Working on a standard React/Node/Python project

### When to Use Manual Input

✅ **Use manual mode when:**
- Custom tech stack (Rust, Elixir, Go, etc.)
- Unique project requirements
- Want to start minimal and customize later
- Experimental or learning projects
- Mixed technologies not covered by presets

### Hybrid Approach

You can also:
1. Start with a preset (for structure)
2. Run `--update` mode later
3. Choose "n" to keep existing and customize manually

```bash
# Initial setup with preset
./setup-agent-instructions.sh my-project

# Later, update with custom details
./setup-agent-instructions.sh --update my-project
```

---

## Tips

### Version Control

**Recommended:** Commit agent instructions to share with your team
```bash
git add .claude/ .gemini/ .qwen/ AGENTS.md
git commit -m "Add AI agent instructions"
```

**Alternative:** Add to `.gitignore` if instructions contain sensitive info
```bash
echo ".claude/" >> .gitignore
echo ".gemini/" >> .gitignore
echo ".qwen/" >> .gitignore
echo "AGENTS.md" >> .gitignore
```

### Keeping Global Rules Updated

Use GNU Stow to manage your configs:
```bash
cd ~/configs
git pull  # Get latest global rules
stow claude gemini qwen opencode  # Symlink to home directory
```

### Quick Project Setup

Create an alias:
```bash
# Add to ~/.bashrc or ~/.zshrc
alias setup-agents='~/configs/setup-agent-instructions.sh'

# Usage:
cd my-new-project
setup-agents .
```

## Troubleshooting

### "jq is required but not installed"
```bash
# Ubuntu/Debian
sudo apt install jq

# macOS
brew install jq

# Arch
sudo pacman -S jq
```

### "Template files are missing"
```bash
# Make sure you're in the configs directory
cd ~/configs
ls templates/  # Should show: PROJECT_INSTRUCTIONS.template.md, AGENTS_COMPREHENSIVE.template.md, presets.json
```

### Files Already Exist
The script will prompt you to overwrite. Choose:
- `y` - Overwrite (lose current content)
- `n` - Skip (keep existing file)

## Advanced Usage

### Custom Templates

Create your own template:
```bash
cp ~/configs/templates/PROJECT_INSTRUCTIONS.template.md my-custom-template.md
# Edit placeholders as needed
```

### Multiple Projects

Set up multiple projects at once:
```bash
for project in project1 project2 project3; do
    ~/configs/setup-agent-instructions.sh ~/projects/$project
done
```

## Benefits

✅ **Single source of truth** - Global rules in one place  
✅ **Minimal duplication** - Project files only have project context  
✅ **Easy maintenance** - Update global rules once, affects all projects  
✅ **Quick setup** - Auto-detection + presets = fast project initialization  
✅ **Flexible** - Use presets or manual input  
✅ **Team-friendly** - Commit and share with your team  

## Support

- See [MCP-SETUP.md](./MCP-SETUP.md) for MCP server configuration
- Run tests: `./test-setup-script.sh`
- Check templates: `ls templates/`

---

*Happy coding with AI assistance!* 🚀
