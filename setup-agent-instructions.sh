#!/usr/bin/env bash
# Setup script for AI agent instruction files
# Creates project-specific agent instructions with auto-detection and presets

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Config directory
CONFIG_DIR="$HOME/configs"
TEMPLATES_DIR="$CONFIG_DIR/templates"

# Template files
PROJECT_TEMPLATE="$TEMPLATES_DIR/PROJECT_INSTRUCTIONS.template.md"
AGENTS_TEMPLATE="$TEMPLATES_DIR/AGENTS_COMPREHENSIVE.template.md"
PRESETS_FILE="$TEMPLATES_DIR/presets.json"

# Global variables
TARGET_DIR=""
UPDATE_MODE=false

# Usage function
usage() {
    echo "Usage: $0 [OPTIONS] <project_directory>"
    echo ""
    echo "Creates or updates AI agent instruction files in the specified project directory."
    echo ""
    echo "Options:"
    echo "  --update, -u    Update existing project instructions (prompts for new values)"
    echo "  --help, -h      Show this help message"
    echo ""
    echo "Generated files:"
    echo "  • .claude/CLAUDE.md       - Claude Code (project-specific)"
    echo "  • .gemini/GEMINI.md       - Gemini Code (project-specific)"
    echo "  • .qwen/QWEN.md           - Qwen Code (project-specific)"
    echo "  • AGENTS.md               - GitHub Copilot + OpenCode (comprehensive)"
    echo ""
    echo "Examples:"
    echo "  $0 ~/projects/my-new-project              # Create new"
    echo "  $0 --update ~/projects/my-new-project     # Update existing"
    echo "  $0 -u .                                   # Update current directory"
    exit 1
}

print_header() {
    echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║   AI Agent Instructions Setup Script      ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
    echo ""
}

print_info() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_step() {
    echo -e "${CYAN}►${NC} $1"
}

check_dependencies() {
    if ! command -v jq &> /dev/null; then
        print_error "jq is required but not installed. Please install jq first."
        exit 1
    fi
}

check_templates() {
    local all_exist=true
    
    if [[ ! -f "$PROJECT_TEMPLATE" ]]; then
        print_error "Project template not found: $PROJECT_TEMPLATE"
        all_exist=false
    fi
    
    if [[ ! -f "$AGENTS_TEMPLATE" ]]; then
        print_error "Agents template not found: $AGENTS_TEMPLATE"
        all_exist=false
    fi
    
    if [[ ! -f "$PRESETS_FILE" ]]; then
        print_error "Presets file not found: $PRESETS_FILE"
        all_exist=false
    fi
    
    if [[ "$all_exist" = false ]]; then
        echo ""
        print_error "Template files are missing. Please ensure configs are properly set up."
        exit 1
    fi
}

detect_project_type() {
    local dir="$1"
    
    # Check for package.json (Node.js projects)
    if [[ -f "$dir/package.json" ]]; then
        # Try to determine if it's React, Next.js, or generic Node
        if grep -q '"next"' "$dir/package.json" 2>/dev/null; then
            echo "fullstack-nextjs"
            return
        elif grep -q '"react"' "$dir/package.json" 2>/dev/null; then
            echo "frontend-react"
            return
        else
            echo "backend-node"
            return
        fi
    fi
    
    # Check for requirements.txt or pyproject.toml (Python projects)
    if [[ -f "$dir/requirements.txt" ]] || [[ -f "$dir/pyproject.toml" ]]; then
        if [[ -f "$dir/pyproject.toml" ]] && grep -q 'fastapi' "$dir/pyproject.toml" 2>/dev/null; then
            echo "python-fastapi"
            return
        fi
        # Could add more Python framework detection here
        echo "python-fastapi"
        return
    fi
    
    # Check for go.mod (Go projects)
    if [[ -f "$dir/go.mod" ]]; then
        echo "cli-tool"
        return
    fi
    
    # Check for Cargo.toml (Rust projects)
    if [[ -f "$dir/Cargo.toml" ]]; then
        echo "cli-tool"
        return
    fi
    
    # Default: unknown
    echo "unknown"
}

get_preset_value() {
    local preset="$1"
    local key="$2"
    jq -r ".\"$preset\".\"$key\" // empty" "$PRESETS_FILE"
}

list_presets() {
    echo ""
    echo "Available presets:"
    jq -r 'keys[]' "$PRESETS_FILE" | while read -r preset; do
        local desc=$(jq -r ".\"$preset\".PROJECT_DESCRIPTION" "$PRESETS_FILE")
        echo "  • $preset"
    done
    echo ""
}

load_existing_values() {
    local project_file="$TARGET_DIR/.claude/CLAUDE.md"
    
    if [[ ! -f "$project_file" ]]; then
        return 1
    fi
    
    print_info "Loading existing project values..."
    
    # Extract values from existing file
    PROJECT_NAME=$(grep -oP '^# \K.*(?= - Project Context)' "$project_file" || basename "$TARGET_DIR")
    PROJECT_TYPE=$(grep -oP '^\*\*Type:\*\* \K.*' "$project_file" || echo "")
    PRIMARY_LANGUAGE=$(grep -oP '^\*\*Language:\*\* \K.*' "$project_file" || echo "")
    TECH_STACK=$(grep -oP '^\*\*Stack:\*\* \K.*' "$project_file" || echo "")
    
    # Extract multi-line sections (simplified)
    PROJECT_DESCRIPTION=$(sed -n '/^### Description$/,/^###/p' "$project_file" | grep -v "^###" | grep -v "^$" || echo "")
    
    return 0
}

prompt_for_details() {
    local detected_preset="$1"
    local use_preset=false
    local preset_name=""
    
    # If in update mode, try to load existing values
    if [[ "$UPDATE_MODE" = true ]]; then
        if load_existing_values; then
            print_info "Current values:"
            echo "  Project: $PROJECT_NAME"
            echo "  Type: $PROJECT_TYPE"
            echo "  Language: $PRIMARY_LANGUAGE"
            echo "  Stack: $TECH_STACK"
            echo ""
            read -p "Keep existing values? (Y/n): " -r
            if [[ ! $REPLY =~ ^[Nn]$ ]]; then
                # Load remaining values from existing file or use defaults
                KEY_TECHNOLOGIES="$(sed -n '/<project_identity>/,/<\/project_identity>/p' "$TARGET_DIR/.claude/CLAUDE.md" | sed -n '/^### Key Technologies$/,/^<\/project_identity>/p' | grep -v "^###" | grep -v "^<" | grep -v "^$" || echo "Add key technologies here.")"
                ARCHITECTURE_PATTERNS="$(sed -n '/<architecture>/,/<\/architecture>/p' "$TARGET_DIR/.claude/CLAUDE.md" | grep -v "^<" | grep -v "^##" | grep -v "^$" || echo "Add architecture patterns here.")"
                CODE_STYLE_GUIDE="$(sed -n '/<code_style>/,/<\/code_style>/p' "$TARGET_DIR/.claude/CLAUDE.md" | grep -v "^<" | grep -v "^##" | grep -v "^$" || echo "Add code style guidelines here.")"
                FILE_ORGANIZATION="$(sed -n '/<file_organization>/,/<\/file_organization>/p' "$TARGET_DIR/.claude/CLAUDE.md" | grep -v "^<" | grep -v "^##" | grep -v "^$" || echo "Add file organization details here.")"
                TESTING_STRATEGY="$(sed -n '/<testing>/,/<\/testing>/p' "$TARGET_DIR/.claude/CLAUDE.md" | grep -v "^<" | grep -v "^##" | grep -v "^$" || echo "Add testing strategy here.")"
                DEPENDENCY_GUIDELINES="$(sed -n '/<dependencies>/,/<\/dependencies>/p' "$TARGET_DIR/.claude/CLAUDE.md" | grep -v "^<" | grep -v "^##" | grep -v "^$" || echo "Add dependency guidelines here.")"
                PROJECT_NOTES="$(sed -n '/<project_notes>/,/<\/project_notes>/p' "$TARGET_DIR/.claude/CLAUDE.md" | grep -v "^<" | grep -v "^##" | grep -v "^$" || echo "Add project-specific notes here.")"
                TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
                return 0
            fi
        else
            print_warning "No existing project files found. Creating new..."
        fi
    fi
    
    # If we detected a project type, offer to use that preset
    if [[ "$detected_preset" != "unknown" ]]; then
        echo ""
        print_step "Detected project type: ${CYAN}$detected_preset${NC}"
        read -p "Use preset '$detected_preset'? (Y/n): " -r
        if [[ ! $REPLY =~ ^[Nn]$ ]]; then
            use_preset=true
            preset_name="$detected_preset"
        fi
    fi
    
    # If no preset selected, ask if they want to choose one
    if [[ "$use_preset" = false ]]; then
        echo ""
        read -p "Would you like to use a preset? (y/N): " -r
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            list_presets
            read -p "Enter preset name (or press Enter to skip): " preset_name
            if [[ -n "$preset_name" ]]; then
                # Check if preset exists
                if jq -e ".\"$preset_name\"" "$PRESETS_FILE" > /dev/null 2>&1; then
                    use_preset=true
                else
                    print_warning "Preset '$preset_name' not found. Using manual input."
                    use_preset=false
                fi
            fi
        fi
    fi
    
    # Load values from preset or prompt manually
    if [[ "$use_preset" = true ]]; then
        print_info "Using preset: $preset_name"
        PROJECT_NAME=$(basename "$TARGET_DIR")
        PROJECT_TYPE=$(get_preset_value "$preset_name" "PROJECT_TYPE")
        PRIMARY_LANGUAGE=$(get_preset_value "$preset_name" "PRIMARY_LANGUAGE")
        TECH_STACK=$(get_preset_value "$preset_name" "TECH_STACK")
        PROJECT_DESCRIPTION=$(get_preset_value "$preset_name" "PROJECT_DESCRIPTION")
        KEY_TECHNOLOGIES=$(get_preset_value "$preset_name" "KEY_TECHNOLOGIES")
        ARCHITECTURE_PATTERNS=$(get_preset_value "$preset_name" "ARCHITECTURE_PATTERNS")
        CODE_STYLE_GUIDE=$(get_preset_value "$preset_name" "CODE_STYLE_GUIDE")
        FILE_ORGANIZATION=$(get_preset_value "$preset_name" "FILE_ORGANIZATION")
        TESTING_STRATEGY=$(get_preset_value "$preset_name" "TESTING_STRATEGY")
        DEPENDENCY_GUIDELINES=$(get_preset_value "$preset_name" "DEPENDENCY_GUIDELINES")
        PROJECT_NOTES=$(get_preset_value "$preset_name" "PROJECT_NOTES")
    else
        # Manual input
        echo ""
        print_step "Please provide project details:"
        echo ""
        
        read -p "Project name [$(basename "$TARGET_DIR")]: " PROJECT_NAME
        PROJECT_NAME=${PROJECT_NAME:-$(basename "$TARGET_DIR")}
        
        read -p "Project type (frontend/backend/fullstack/cli/library): " PROJECT_TYPE
        read -p "Primary language: " PRIMARY_LANGUAGE
        read -p "Tech stack (comma-separated): " TECH_STACK
        
        echo ""
        echo "Project description (press Enter twice to finish):"
        PROJECT_DESCRIPTION=""
        while IFS= read -r line; do
            [[ -z "$line" ]] && break
            PROJECT_DESCRIPTION+="$line"$'\n'
        done
        
        # Set defaults for other fields
        KEY_TECHNOLOGIES="Add key technologies here."
        ARCHITECTURE_PATTERNS="Add architecture patterns here."
        CODE_STYLE_GUIDE="Add code style guidelines here."
        FILE_ORGANIZATION="Add file organization details here."
        TESTING_STRATEGY="Add testing strategy here."
        DEPENDENCY_GUIDELINES="Add dependency guidelines here."
        PROJECT_NOTES="Add project-specific notes here."
    fi
    
    TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
}

replace_placeholders() {
    local template_file="$1"
    local output_file="$2"
    
    # Read template
    local content=$(<"$template_file")
    
    # Replace all placeholders
    content="${content//\{\{PROJECT_NAME\}\}/$PROJECT_NAME}"
    content="${content//\{\{PROJECT_TYPE\}\}/$PROJECT_TYPE}"
    content="${content//\{\{PRIMARY_LANGUAGE\}\}/$PRIMARY_LANGUAGE}"
    content="${content//\{\{TECH_STACK\}\}/$TECH_STACK}"
    content="${content//\{\{PROJECT_DESCRIPTION\}\}/$PROJECT_DESCRIPTION}"
    content="${content//\{\{KEY_TECHNOLOGIES\}\}/$KEY_TECHNOLOGIES}"
    content="${content//\{\{ARCHITECTURE_PATTERNS\}\}/$ARCHITECTURE_PATTERNS}"
    content="${content//\{\{CODE_STYLE_GUIDE\}\}/$CODE_STYLE_GUIDE}"
    content="${content//\{\{FILE_ORGANIZATION\}\}/$FILE_ORGANIZATION}"
    content="${content//\{\{TESTING_STRATEGY\}\}/$TESTING_STRATEGY}"
    content="${content//\{\{DEPENDENCY_GUIDELINES\}\}/$DEPENDENCY_GUIDELINES}"
    content="${content//\{\{PROJECT_NOTES\}\}/$PROJECT_NOTES}"
    content="${content//\{\{TIMESTAMP\}\}/$TIMESTAMP}"
    
    # Write output
    echo "$content" > "$output_file"
}

create_agent_files() {
    echo ""
    print_step "Generating agent instructions..."
    echo ""
    
    # Create .claude/CLAUDE.md
    mkdir -p "$TARGET_DIR/.claude"
    if [[ -f "$TARGET_DIR/.claude/CLAUDE.md" ]]; then
        print_warning "Claude instructions already exist"
        read -p "Overwrite? (y/N): " -r
        [[ $REPLY =~ ^[Yy]$ ]] && replace_placeholders "$PROJECT_TEMPLATE" "$TARGET_DIR/.claude/CLAUDE.md" && print_info "Created .claude/CLAUDE.md"
    else
        replace_placeholders "$PROJECT_TEMPLATE" "$TARGET_DIR/.claude/CLAUDE.md"
        print_info "Created .claude/CLAUDE.md"
    fi
    
    # Create .gemini/GEMINI.md
    mkdir -p "$TARGET_DIR/.gemini"
    if [[ -f "$TARGET_DIR/.gemini/GEMINI.md" ]]; then
        print_warning "Gemini instructions already exist"
        read -p "Overwrite? (y/N): " -r
        [[ $REPLY =~ ^[Yy]$ ]] && replace_placeholders "$PROJECT_TEMPLATE" "$TARGET_DIR/.gemini/GEMINI.md" && print_info "Created .gemini/GEMINI.md"
    else
        replace_placeholders "$PROJECT_TEMPLATE" "$TARGET_DIR/.gemini/GEMINI.md"
        print_info "Created .gemini/GEMINI.md"
    fi
    
    # Create .qwen/QWEN.md
    mkdir -p "$TARGET_DIR/.qwen"
    if [[ -f "$TARGET_DIR/.qwen/QWEN.md" ]]; then
        print_warning "Qwen instructions already exist"
        read -p "Overwrite? (y/N): " -r
        [[ $REPLY =~ ^[Yy]$ ]] && replace_placeholders "$PROJECT_TEMPLATE" "$TARGET_DIR/.qwen/QWEN.md" && print_info "Created .qwen/QWEN.md"
    else
        replace_placeholders "$PROJECT_TEMPLATE" "$TARGET_DIR/.qwen/QWEN.md"
        print_info "Created .qwen/QWEN.md"
    fi
    
    # Create AGENTS.md (comprehensive for Copilot + OpenCode)
    if [[ -f "$TARGET_DIR/AGENTS.md" ]]; then
        print_warning "AGENTS.md already exists"
        read -p "Overwrite? (y/N): " -r
        [[ $REPLY =~ ^[Yy]$ ]] && replace_placeholders "$AGENTS_TEMPLATE" "$TARGET_DIR/AGENTS.md" && print_info "Created AGENTS.md"
    else
        replace_placeholders "$AGENTS_TEMPLATE" "$TARGET_DIR/AGENTS.md"
        print_info "Created AGENTS.md"
    fi
}

show_summary() {
    echo ""
    print_info "Setup complete!"
    echo ""
    echo -e "${BLUE}Files created in $TARGET_DIR:${NC}"
    echo "  • .claude/CLAUDE.md       - Claude Code (references ~/.claude/CLAUDE.md)"
    echo "  • .gemini/GEMINI.md       - Gemini Code (references ~/.gemini/GEMINI.md)"
    echo "  • .qwen/QWEN.md           - Qwen Code (references ~/.qwen/QWEN.md)"
    echo "  • AGENTS.md               - GitHub Copilot + OpenCode (comprehensive)"
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo "  1. Review and customize files for your specific project needs"
    echo "  2. Add to version control to share with your team"
    echo "  3. Global rules are managed in ~/configs/{agent}/"
    echo ""
}

main() {
    local target="${1:-.}"
    
    # Check if target directory exists or can be created
    if [[ ! -d "$target" ]]; then
        print_warning "Directory does not exist: $target"
        read -p "Create directory? (y/N): " -r
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            mkdir -p "$target"
            print_info "Created directory: $target"
        else
            print_error "Directory does not exist. Exiting."
            exit 1
        fi
    fi
    
    # Resolve to absolute path
    TARGET_DIR=$(cd "$target" && pwd)
    
    print_header
    echo -e "Target directory: ${GREEN}$TARGET_DIR${NC}"
    
    # Check dependencies and templates
    check_dependencies
    check_templates
    
    # Detect project type
    print_step "Detecting project type..."
    local detected_type=$(detect_project_type "$TARGET_DIR")
    
    # Prompt for project details
    prompt_for_details "$detected_type"
    
    # Create agent instruction files
    create_agent_files
    
    # Show summary
    show_summary
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --update|-u)
                UPDATE_MODE=true
                shift
                ;;
            --help|-h)
                usage
                ;;
            -*)
                echo "Unknown option: $1"
                usage
                ;;
            *)
                # This is the project directory
                TARGET_ARG="$1"
                shift
                ;;
        esac
    done
    
    if [[ -z "${TARGET_ARG:-}" ]]; then
        TARGET_ARG="."
    fi
}

# Main execution
parse_args "$@"
main "$TARGET_ARG"
