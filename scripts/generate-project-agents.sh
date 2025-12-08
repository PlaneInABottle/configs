#!/usr/bin/env bash
# Generate Project-Specific AI Agents
# Creates customized agent instructions for individual projects
# Supports auto-detection and presets for different project types

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Config directory - auto-detect script location (resolve symlinks)
# Works on both Linux and macOS
SCRIPT_PATH="${BASH_SOURCE[0]}"

# Resolve symlinks to get actual script location
while [ -L "$SCRIPT_PATH" ]; do
    SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"
    SCRIPT_PATH="$(readlink "$SCRIPT_PATH")"
    # Handle relative symlink paths
    [[ $SCRIPT_PATH != /* ]] && SCRIPT_PATH="$SCRIPT_DIR/$SCRIPT_PATH"
done

# Get the directory containing the script
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"

# Config directory is the parent of the scripts directory
CONFIG_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
TEMPLATES_DIR="$CONFIG_DIR/templates"

# Template files
PROJECT_TEMPLATE="$TEMPLATES_DIR/PROJECT_INSTRUCTIONS.template.md"

# Global variables
TARGET_DIR=""
UPDATE_MODE=false
FORCE_MODE=false
ONLY_FILES="all"

# Project variables (initialized with defaults)
PROJECT_DESCRIPTION=""
KEY_TECHNOLOGIES=""
FEW_SHOT_EXAMPLES=""
SPECIALIZED_AGENTS=""
ARCHITECTURE_PATTERNS=""
CODE_STYLE_GUIDE=""
FILE_ORGANIZATION=""
TESTING_STRATEGY=""
DEPENDENCY_GUIDELINES=""
DEVELOPMENT_WORKFLOW=""
IMPLEMENTATION_GUIDELINES=""
COMMON_PATTERNS=""
TROUBLESHOOTING=""
PROJECT_NOTES=""
TIMESTAMP=""

# Override variables for --set-* flags
OVERRIDE_DESCRIPTION=""
OVERRIDE_TECHNOLOGIES=""
OVERRIDE_FEW_SHOT=""
OVERRIDE_SPECIALIZED_AGENTS=""
OVERRIDE_ARCHITECTURE=""
OVERRIDE_CODE_STYLE=""
OVERRIDE_FILE_ORG=""
OVERRIDE_TESTING=""
OVERRIDE_DEPENDENCIES=""
OVERRIDE_WORKFLOW=""
OVERRIDE_IMPLEMENTATION=""
OVERRIDE_PATTERNS=""
OVERRIDE_TROUBLESHOOTING=""
OVERRIDE_NOTES=""

# Usage function
usage() {
    echo "Usage: $0 [OPTIONS] <project_directory>"
    echo ""
    echo "Creates or updates AI agent instruction files in the specified project directory."
    echo ""
    echo "Options:"
    echo "  --update, -u              Update existing project instructions"
    echo "  --force, -f               Overwrite files without prompting"
    echo "  --only=FILE               Update only specific files (claude|gemini|qwen|agents|all)"
    echo "  --help, -h                Show this help message"
    echo ""
    echo "Value Override Flags (use with --update):"
    echo "  --set-description=VALUE       Set project description"
    echo "  --set-technologies=VALUE      Set key technologies"
    echo "  --set-few-shot=VALUE          Set few-shot examples"
    echo "  --set-specialized-agents=VALUE Set specialized agents"
    echo "  --set-architecture=VALUE      Set architecture patterns"
    echo "  --set-code-style=VALUE        Set code style guide"
    echo "  --set-file-org=VALUE          Set file organization"
    echo "  --set-testing=VALUE           Set testing strategy"
    echo "  --set-dependencies=VALUE      Set dependency guidelines"
    echo "  --set-workflow=VALUE          Set development workflow"
    echo "  --set-implementation=VALUE    Set implementation guidelines"
    echo "  --set-patterns=VALUE          Set common code patterns"
    echo "  --set-troubleshooting=VALUE   Set troubleshooting guide"
    echo "  --set-notes=VALUE             Set project notes"
    echo ""
    echo "Generated files:"
    echo "  • .claude/CLAUDE.md       - Claude Code (project-specific)"
    echo "  • .gemini/GEMINI.md       - Gemini Code (project-specific)"
    echo "  • .qwen/QWEN.md           - Qwen Code (project-specific)"
    echo "  • AGENTS.md               - GitHub Copilot + OpenCode (project-specific)"
    echo ""
    echo "Examples:"
    echo "  $0 ~/projects/my-new-project"
    echo "  $0 --update ~/projects/my-new-project"
    echo "  $0 --update --force --set-technologies=\"Vue, TypeScript, Vite\" ."
    echo "  $0 --update --force --only=agents --set-technologies=\"Go, Gin\" ."
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
    # No external dependencies required (removed jq requirement with presets)
    return 0
}

check_templates() {
    if [[ ! -f "$PROJECT_TEMPLATE" ]]; then
        print_error "Project template not found: $PROJECT_TEMPLATE"
        echo ""
        print_error "Template files are missing. Please ensure configs are properly set up."
        exit 1
    fi
}


load_existing_values() {
    local project_file="$TARGET_DIR/.claude/CLAUDE.md"
    
    if [[ ! -f "$project_file" ]]; then
        return 1
    fi
    
    print_info "Loading existing project values..."

    # Extract multi-line sections (simplified)
    PROJECT_DESCRIPTION=$(sed -n '/^### Description$/,/^###/p' "$project_file" | grep -v "^###" | grep -v "^$" || echo "")
    
    return 0
}

apply_overrides() {
    # Apply flag overrides if provided
    [[ -n "$OVERRIDE_DESCRIPTION" ]] && PROJECT_DESCRIPTION="$OVERRIDE_DESCRIPTION" || true
    [[ -n "$OVERRIDE_TECHNOLOGIES" ]] && KEY_TECHNOLOGIES="$OVERRIDE_TECHNOLOGIES" || true
    [[ -n "$OVERRIDE_FEW_SHOT" ]] && FEW_SHOT_EXAMPLES="$OVERRIDE_FEW_SHOT" || true
    [[ -n "$OVERRIDE_SPECIALIZED_AGENTS" ]] && SPECIALIZED_AGENTS="$OVERRIDE_SPECIALIZED_AGENTS" || true
    [[ -n "$OVERRIDE_ARCHITECTURE" ]] && ARCHITECTURE_PATTERNS="$OVERRIDE_ARCHITECTURE" || true
    [[ -n "$OVERRIDE_CODE_STYLE" ]] && CODE_STYLE_GUIDE="$OVERRIDE_CODE_STYLE" || true
    [[ -n "$OVERRIDE_FILE_ORG" ]] && FILE_ORGANIZATION="$OVERRIDE_FILE_ORG" || true
    [[ -n "$OVERRIDE_TESTING" ]] && TESTING_STRATEGY="$OVERRIDE_TESTING" || true
    [[ -n "$OVERRIDE_DEPENDENCIES" ]] && DEPENDENCY_GUIDELINES="$OVERRIDE_DEPENDENCIES" || true
    [[ -n "$OVERRIDE_WORKFLOW" ]] && DEVELOPMENT_WORKFLOW="$OVERRIDE_WORKFLOW" || true
    [[ -n "$OVERRIDE_IMPLEMENTATION" ]] && IMPLEMENTATION_GUIDELINES="$OVERRIDE_IMPLEMENTATION" || true
    [[ -n "$OVERRIDE_PATTERNS" ]] && COMMON_PATTERNS="$OVERRIDE_PATTERNS" || true
    [[ -n "$OVERRIDE_TROUBLESHOOTING" ]] && TROUBLESHOOTING="$OVERRIDE_TROUBLESHOOTING" || true
    [[ -n "$OVERRIDE_NOTES" ]] && PROJECT_NOTES="$OVERRIDE_NOTES" || true
}

prompt_for_details() {
    # First, apply any --set-* flag overrides
    apply_overrides

    # If in update mode, try to load existing values
    if [[ "$UPDATE_MODE" = true ]]; then
        if load_existing_values; then
            # Load remaining values from existing file (disable pipefail for these)
            set +e
            [[ -z "$KEY_TECHNOLOGIES" ]] && KEY_TECHNOLOGIES="$(sed -n '/<project_identity>/,/<\/project_identity>/p' "$TARGET_DIR/.claude/CLAUDE.md" | sed -n '/^### Key Technologies$/,/^<\/project_identity>/p' | grep -v "^###" | grep -v "^<" | grep -v "^$" || echo "")"
            [[ -z "$FEW_SHOT_EXAMPLES" ]] && FEW_SHOT_EXAMPLES="$(sed -n '/<few_shot_examples>/,/<\/few_shot_examples>/p' "$TARGET_DIR/.claude/CLAUDE.md" | grep -v "^<" | grep -v "^##" | grep -v "^$" || echo "")"
            [[ -z "$SPECIALIZED_AGENTS" ]] && SPECIALIZED_AGENTS="$(sed -n '/<specialized_agents>/,/<\/specialized_agents>/p' "$TARGET_DIR/.claude/CLAUDE.md" | grep -v "^<" | grep -v "^##" | grep -v "^$" || echo "")"
            [[ -z "$ARCHITECTURE_PATTERNS" ]] && ARCHITECTURE_PATTERNS="$(sed -n '/<architecture>/,/<\/architecture>/p' "$TARGET_DIR/.claude/CLAUDE.md" | grep -v "^<" | grep -v "^##" | grep -v "^$" || echo "")"
            [[ -z "$CODE_STYLE_GUIDE" ]] && CODE_STYLE_GUIDE="$(sed -n '/<code_style>/,/<\/code_style>/p' "$TARGET_DIR/.claude/CLAUDE.md" | grep -v "^<" | grep -v "^##" | grep -v "^$" || echo "")"
            [[ -z "$FILE_ORGANIZATION" ]] && FILE_ORGANIZATION="$(sed -n '/<file_organization>/,/<\/file_organization>/p' "$TARGET_DIR/.claude/CLAUDE.md" | grep -v "^<" | grep -v "^##" | grep -v "^$" || echo "")"
            [[ -z "$TESTING_STRATEGY" ]] && TESTING_STRATEGY="$(sed -n '/<testing>/,/<\/testing>/p' "$TARGET_DIR/.claude/CLAUDE.md" | grep -v "^<" | grep -v "^##" | grep -v "^$" || echo "")"
            [[ -z "$DEPENDENCY_GUIDELINES" ]] && DEPENDENCY_GUIDELINES="$(sed -n '/<dependencies>/,/<\/dependencies>/p' "$TARGET_DIR/.claude/CLAUDE.md" | grep -v "^<" | grep -v "^##" | grep -v "^$" || echo "")"
            [[ -z "$PROJECT_NOTES" ]] && PROJECT_NOTES="$(sed -n '/<project_notes>/,/<\/project_notes>/p' "$TARGET_DIR/.claude/CLAUDE.md" | grep -v "^<" | grep -v "^##" | grep -v "^$" || echo "")"
            set -e

            # Apply any flag overrides again (to override loaded values)
            apply_overrides

            # Show current values (after overrides) if not in force mode
            if [[ "$FORCE_MODE" = false ]]; then
                print_info "Current values loaded from existing file"
                echo ""
                read -p "Keep existing values? (Y/n): " -r
                if [[ ! $REPLY =~ ^[Nn]$ ]]; then
                    TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
                    return 0
                fi
            else
                # Force mode: just use the values (with overrides applied)
                TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
                return 0
            fi
        else
            print_warning "No existing project files found. Creating new..."
        fi
    fi

    # Check if all required values are provided
    if [[ -z "$PROJECT_DESCRIPTION" ]] || [[ -z "$KEY_TECHNOLOGIES" ]] || [[ -z "$FEW_SHOT_EXAMPLES" ]] || \
       [[ -z "$ARCHITECTURE_PATTERNS" ]] || [[ -z "$CODE_STYLE_GUIDE" ]] || [[ -z "$FILE_ORGANIZATION" ]] || \
       [[ -z "$TESTING_STRATEGY" ]] || [[ -z "$DEPENDENCY_GUIDELINES" ]] || [[ -z "$PROJECT_NOTES" ]]; then

        print_error "Missing required values. All values must be provided via --set-* flags."
        echo ""
        echo "Required flags:"
        echo "  --set-description=VALUE"
        echo "  --set-technologies=VALUE"
        echo "  --set-few-shot=VALUE"
        echo "  --set-architecture=VALUE"
        echo "  --set-code-style=VALUE"
        echo "  --set-file-org=VALUE"
        echo "  --set-testing=VALUE"
        echo "  --set-dependencies=VALUE"
        echo "  --set-notes=VALUE"
        exit 1
    fi

    TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
}

replace_placeholders() {
    local template_file="$1"
    local output_file="$2"

    # Read template
    local content=$(<"$template_file")

    # Replace all placeholders (handling literal \n characters as newlines)
    content="${content//\{\{PROJECT_DESCRIPTION\}\}/$PROJECT_DESCRIPTION}"
    # For multiline values, replace \n with actual newlines
    KEY_TECHNOLOGIES_NEWLINE=$(printf '%s\n' "$KEY_TECHNOLOGIES" | sed 's/\\n/\n/g')
    content="${content//\{\{KEY_TECHNOLOGIES\}\}/$KEY_TECHNOLOGIES_NEWLINE}"
    FEW_SHOT_EXAMPLES_NEWLINE=$(printf '%s\n' "$FEW_SHOT_EXAMPLES" | sed 's/\\n/\n/g')
    content="${content//\{\{FEW_SHOT_EXAMPLES\}\}/$FEW_SHOT_EXAMPLES_NEWLINE}"
    SPECIALIZED_AGENTS_NEWLINE=$(printf '%s\n' "$SPECIALIZED_AGENTS" | sed 's/\\n/\n/g')
    content="${content//\{\{SPECIALIZED_AGENTS\}\}/$SPECIALIZED_AGENTS_NEWLINE}"
    ARCHITECTURE_PATTERNS_NEWLINE=$(printf '%s\n' "$ARCHITECTURE_PATTERNS" | sed 's/\\n/\n/g')
    content="${content//\{\{ARCHITECTURE_PATTERNS\}\}/$ARCHITECTURE_PATTERNS_NEWLINE}"
    CODE_STYLE_GUIDE_NEWLINE=$(printf '%s\n' "$CODE_STYLE_GUIDE" | sed 's/\\n/\n/g')
    content="${content//\{\{CODE_STYLE_GUIDE\}\}/$CODE_STYLE_GUIDE_NEWLINE}"
    FILE_ORGANIZATION_NEWLINE=$(printf '%s\n' "$FILE_ORGANIZATION" | sed 's/\\n/\n/g')
    content="${content//\{\{FILE_ORGANIZATION\}\}/$FILE_ORGANIZATION_NEWLINE}"
    TESTING_STRATEGY_NEWLINE=$(printf '%s\n' "$TESTING_STRATEGY" | sed 's/\\n/\n/g')
    content="${content//\{\{TESTING_STRATEGY\}\}/$TESTING_STRATEGY_NEWLINE}"
    DEPENDENCY_GUIDELINES_NEWLINE=$(printf '%s\n' "$DEPENDENCY_GUIDELINES" | sed 's/\\n/\n/g')
    content="${content//\{\{DEPENDENCY_GUIDELINES\}\}/$DEPENDENCY_GUIDELINES_NEWLINE}"
    DEVELOPMENT_WORKFLOW_NEWLINE=$(printf '%s\n' "$DEVELOPMENT_WORKFLOW" | sed 's/\\n/\n/g')
    content="${content//\{\{DEVELOPMENT_WORKFLOW\}\}/$DEVELOPMENT_WORKFLOW_NEWLINE}"
    IMPLEMENTATION_GUIDELINES_NEWLINE=$(printf '%s\n' "$IMPLEMENTATION_GUIDELINES" | sed 's/\\n/\n/g')
    content="${content//\{\{IMPLEMENTATION_GUIDELINES\}\}/$IMPLEMENTATION_GUIDELINES_NEWLINE}"
    COMMON_PATTERNS_NEWLINE=$(printf '%s\n' "$COMMON_PATTERNS" | sed 's/\\n/\n/g')
    content="${content//\{\{COMMON_PATTERNS\}\}/$COMMON_PATTERNS_NEWLINE}"
    TROUBLESHOOTING_NEWLINE=$(printf '%s\n' "$TROUBLESHOOTING" | sed 's/\\n/\n/g')
    content="${content//\{\{TROUBLESHOOTING\}\}/$TROUBLESHOOTING_NEWLINE}"
    PROJECT_NOTES_NEWLINE=$(printf '%s\n' "$PROJECT_NOTES" | sed 's/\\n/\n/g')
    content="${content//\{\{PROJECT_NOTES\}\}/$PROJECT_NOTES_NEWLINE}"
    content="${content//\{\{TIMESTAMP\}\}/$TIMESTAMP}"

    # Write output with proper newline handling
    printf '%b\n' "$content" > "$output_file"
}

create_agent_files() {
    echo ""
    print_step "Generating agent instructions..."
    echo ""
    
    local should_create_file
    
    # Create .claude/CLAUDE.md
    if [[ "$ONLY_FILES" == "all" || "$ONLY_FILES" == "claude" ]]; then
        mkdir -p "$TARGET_DIR/.claude"
        should_create_file=false
        if [[ -f "$TARGET_DIR/.claude/CLAUDE.md" ]]; then
            if [[ "$FORCE_MODE" = true ]]; then
                should_create_file=true
            else
                print_warning "Claude instructions already exist"
                read -p "Overwrite? (y/N): " -r
                [[ $REPLY =~ ^[Yy]$ ]] && should_create_file=true
            fi
        else
            should_create_file=true
        fi
        
        if [[ "$should_create_file" = true ]]; then
            replace_placeholders "$PROJECT_TEMPLATE" "$TARGET_DIR/.claude/CLAUDE.md"
            print_info "Created .claude/CLAUDE.md"
        fi
    fi
    
    # Create .gemini/GEMINI.md
    if [[ "$ONLY_FILES" == "all" || "$ONLY_FILES" == "gemini" ]]; then
        mkdir -p "$TARGET_DIR/.gemini"
        should_create_file=false
        if [[ -f "$TARGET_DIR/.gemini/GEMINI.md" ]]; then
            if [[ "$FORCE_MODE" = true ]]; then
                should_create_file=true
            else
                print_warning "Gemini instructions already exist"
                read -p "Overwrite? (y/N): " -r
                [[ $REPLY =~ ^[Yy]$ ]] && should_create_file=true
            fi
        else
            should_create_file=true
        fi
        
        if [[ "$should_create_file" = true ]]; then
            replace_placeholders "$PROJECT_TEMPLATE" "$TARGET_DIR/.gemini/GEMINI.md"
            print_info "Created .gemini/GEMINI.md"
        fi
    fi
    
    # Create .qwen/QWEN.md
    if [[ "$ONLY_FILES" == "all" || "$ONLY_FILES" == "qwen" ]]; then
        mkdir -p "$TARGET_DIR/.qwen"
        should_create_file=false
        if [[ -f "$TARGET_DIR/.qwen/QWEN.md" ]]; then
            if [[ "$FORCE_MODE" = true ]]; then
                should_create_file=true
            else
                print_warning "Qwen instructions already exist"
                read -p "Overwrite? (y/N): " -r
                [[ $REPLY =~ ^[Yy]$ ]] && should_create_file=true
            fi
        else
            should_create_file=true
        fi
        
        if [[ "$should_create_file" = true ]]; then
            replace_placeholders "$PROJECT_TEMPLATE" "$TARGET_DIR/.qwen/QWEN.md"
            print_info "Created .qwen/QWEN.md"
        fi
    fi
    
    # Create AGENTS.md (project-specific for Copilot + OpenCode)
    if [[ "$ONLY_FILES" == "all" || "$ONLY_FILES" == "agents" ]]; then
        should_create_file=false
        if [[ -f "$TARGET_DIR/AGENTS.md" ]]; then
            if [[ "$FORCE_MODE" = true ]]; then
                should_create_file=true
            else
                print_warning "AGENTS.md already exists"
                read -p "Overwrite? (y/N): " -r
                [[ $REPLY =~ ^[Yy]$ ]] && should_create_file=true
            fi
        else
            should_create_file=true
        fi

        if [[ "$should_create_file" = true ]]; then
            replace_placeholders "$PROJECT_TEMPLATE" "$TARGET_DIR/AGENTS.md"
            print_info "Created AGENTS.md"
        fi
    fi
}

show_summary() {
    echo ""
    print_info "Setup complete!"
    echo ""
    echo -e "${BLUE}Files created in $TARGET_DIR:${NC}"
    echo "  • .claude/CLAUDE.md       - Claude Code (project-specific)"
    echo "  • .gemini/GEMINI.md       - Gemini Code (project-specific)"
    echo "  • .qwen/QWEN.md           - Qwen Code (project-specific)"
    echo "  • AGENTS.md               - GitHub Copilot + OpenCode (project-specific)"
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo "  1. Review and customize files for your specific project needs"
    echo "  2. Add to version control to share with your team"
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
    
    # Prompt for project details
    prompt_for_details
    
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
            --force|-f)
                FORCE_MODE=true
                shift
                ;;
            --only=*)
                ONLY_FILES="${1#*=}"
                shift
                ;;
            --set-description=*)
                OVERRIDE_DESCRIPTION="${1#*=}"
                shift
                ;;
            --set-technologies=*)
                OVERRIDE_TECHNOLOGIES="${1#*=}"
                shift
                ;;
            --set-few-shot=*)
                OVERRIDE_FEW_SHOT="${1#*=}"
                shift
                ;;
            --set-specialized-agents=*)
                OVERRIDE_SPECIALIZED_AGENTS="${1#*=}"
                shift
                ;;
            --set-architecture=*)
                OVERRIDE_ARCHITECTURE="${1#*=}"
                shift
                ;;
            --set-code-style=*)
                OVERRIDE_CODE_STYLE="${1#*=}"
                shift
                ;;
            --set-file-org=*)
                OVERRIDE_FILE_ORG="${1#*=}"
                shift
                ;;
            --set-testing=*)
                OVERRIDE_TESTING="${1#*=}"
                shift
                ;;
            --set-dependencies=*)
                OVERRIDE_DEPENDENCIES="${1#*=}"
                shift
                ;;
            --set-workflow=*)
                OVERRIDE_WORKFLOW="${1#*=}"
                shift
                ;;
            --set-implementation=*)
                OVERRIDE_IMPLEMENTATION="${1#*=}"
                shift
                ;;
            --set-patterns=*)
                OVERRIDE_PATTERNS="${1#*=}"
                shift
                ;;
            --set-troubleshooting=*)
                OVERRIDE_TROUBLESHOOTING="${1#*=}"
                shift
                ;;
            --set-notes=*)
                OVERRIDE_NOTES="${1#*=}"
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
