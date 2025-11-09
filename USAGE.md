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
3. Allow you to confirm overwrite for each file
4. Preserve your existing content if you choose to keep it

### 3. Available Presets

- **frontend-react** - React + TypeScript + Vite
- **backend-node** - Node.js + Express + PostgreSQL
- **fullstack-nextjs** - Next.js + React + Prisma
- **python-fastapi** - Python + FastAPI + PostgreSQL
- **cli-tool** - Node.js/Go/Rust CLI application
- **library** - Reusable TypeScript library

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

## Manual Setup

If you prefer to enter details manually:

```bash
./setup-agent-instructions.sh /path/to/project
# When prompted:
# - Choose "n" to skip preset
# - Enter project details manually
# - Files will be generated with your custom values
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
# - Show current values
# - Ask if you want to keep them
# - Allow selective overwrites
```

### Add New Presets

Edit `~/configs/templates/presets.json`:
```json
{
  "your-preset-name": {
    "PROJECT_TYPE": "backend",
    "PRIMARY_LANGUAGE": "Go",
    "TECH_STACK": "Go, Gin, PostgreSQL",
    ...
  }
}
```

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
