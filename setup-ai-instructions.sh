#!/usr/bin/env bash

# Setup script for global AI instruction files
# Manages instruction files for Claude, Copilot, Gemini, Qwen, and OpenCode
# AI provides the full instruction content via --set-content flag

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Config directory
CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES_DIR="$CONFIG_DIR/templates"

# Template file
TEMPLATE_FILE="$TEMPLATES_DIR/AI_INSTRUCTIONS.template.md"

# AI tools to manage
AI_TOOLS=("claude" "copilot" "gemini" "qwen" "opencode")

# Initialize variables with defaults
DESCRIPTION="Global AI development standards and best practices"
CONTENT=""

# Flags
UPDATE_MODE=false
FORCE_OVERWRITE=false
ONLY_TOOLS=""

# Print colored output
print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1" >&2
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Usage function
show_help() {
    cat << 'EOF'
Usage: setup-ai-instructions.sh [OPTIONS]

Generate global AI instruction files for Claude, Copilot, Gemini, Qwen, and OpenCode.
Requires AI to analyze and provide the instruction content.

OPTIONS:
  -h, --help                              Show this help message
  -u, --update                            Update existing instruction files
  -f, --force                             Overwrite files without prompting
  --only=TOOL[,TOOL]                      Generate only specific tool(s): claude|copilot|gemini|qwen|opencode|all

  --set-description="TEXT"                Set description (default: Global AI development standards...)
  --set-content="TEXT"                    Set instruction content (multiline, use \n for newlines)

EXAMPLES:
  # Generate Claude instructions (AI provides full content via --set-content)
  ./setup-ai-instructions.sh \
    --set-description="Global AI standards" \
    --set-content="# Quick Start\n\n1. Try simple first\n2. Never guess\n..."

  # Update only Copilot with new content
  ./setup-ai-instructions.sh --update --only=copilot \
    --set-content="..."

  # Generate all tools with same content
  ./setup-ai-instructions.sh --force \
    --set-content="..."

EOF
}

# Check dependencies
check_dependencies() {
    # No external dependencies required
    return 0
}

# Check template exists
check_templates() {
    if [[ ! -f "$TEMPLATE_FILE" ]]; then
        print_error "Template file not found: $TEMPLATE_FILE"
        return 1
    fi
    return 0
}

# Parse command line arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -u|--update)
                UPDATE_MODE=true
                shift
                ;;
            -f|--force)
                FORCE_OVERWRITE=true
                shift
                ;;
            --only=*)
                ONLY_TOOLS="${1#*=}"
                shift
                ;;
            --set-description=*)
                DESCRIPTION="${1#*=}"
                shift
                ;;
            --set-content=*)
                CONTENT="${1#*=}"
                shift
                ;;
            *)
                print_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# Validate required values
validate_values() {
    if [[ -z "$CONTENT" ]]; then
        print_error "Missing required value: --set-content"
        print_error "Content must be provided via --set-content flag"
        show_help
        exit 1
    fi

    if [[ -z "$DESCRIPTION" ]]; then
        print_error "Missing required value: --set-description"
        show_help
        exit 1
    fi
}

# Get tools to process
get_tools_to_process() {
    local tools_array=()

    if [[ -z "$ONLY_TOOLS" ]]; then
        # Process all tools
        tools_array=("${AI_TOOLS[@]}")
    else
        # Parse comma-separated tool list
        IFS=',' read -ra TOOL_LIST <<< "$ONLY_TOOLS"
        for tool in "${TOOL_LIST[@]}"; do
            tool=$(echo "$tool" | xargs) # Trim whitespace
            if [[ "$tool" == "all" ]]; then
                tools_array=("${AI_TOOLS[@]}")
                break
            elif [[ " ${AI_TOOLS[@]} " =~ " ${tool} " ]]; then
                tools_array+=("$tool")
            else
                print_warning "Unknown tool: $tool (skipping)"
            fi
        done
    fi

    printf '%s\n' "${tools_array[@]}"
}

# Replace placeholders in template
replace_placeholders() {
    local template_content="$1"

    # Create a temporary file for content to avoid sed escaping issues
    local temp_content=$(mktemp)
    printf '%s' "$CONTENT" > "$temp_content"

    # Replace DESCRIPTION using sed
    template_content=$(printf '%s\n' "$template_content" | sed "s|{{DESCRIPTION}}|${DESCRIPTION}|g")

    # Replace CONTENT by reading from temp file and inserting
    # Use a different approach: read entire content and replace as a block
    local content_file=$(mktemp)
    cat "$temp_content" > "$content_file"

    # Use awk to handle content replacement safely
    awk -v file="$content_file" '
    /\{\{CONTENT\}\}/ {
        while ((getline line < file) > 0) print line
        next
    }
    { print }
    ' <<< "$template_content"

    rm -f "$temp_content" "$content_file"
}

# Get output path for tool
get_output_path() {
    local tool=$1

    case "$tool" in
        claude)
            echo "${CONFIG_DIR}/claude/.claude/CLAUDE.md"
            ;;
        copilot)
            echo "${CONFIG_DIR}/copilot/.copilot/instructions.md"
            ;;
        gemini)
            echo "${CONFIG_DIR}/gemini/.gemini/GEMINI.md"
            ;;
        qwen)
            echo "${CONFIG_DIR}/qwen/.qwen/QWEN.md"
            ;;
        opencode)
            echo "${CONFIG_DIR}/opencode/.config/opencode/OPENCODE.md"
            ;;
    esac
}

# Create directory if needed
ensure_directory_exists() {
    local file_path=$1
    local dir=$(dirname "$file_path")

    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
        print_info "Created directory: $dir"
    fi
}

# Ask for confirmation before overwriting
ask_overwrite() {
    local file=$1

    if [[ "$FORCE_OVERWRITE" == true ]]; then
        return 0
    fi

    read -p "File exists: $file. Overwrite? (y/n) " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}

# Generate instruction file for a tool
generate_instruction_file() {
    local tool=$1
    local output_path

    output_path=$(get_output_path "$tool")

    # Ensure directory exists
    ensure_directory_exists "$output_path"

    # Read template
    local template_content
    template_content=$(< "$TEMPLATE_FILE")

    # Replace placeholders
    local final_content
    final_content=$(replace_placeholders "$template_content")

    # Check if file exists
    if [[ -f "$output_path" ]] && ! ask_overwrite "$output_path"; then
        print_warning "Skipped: $tool"
        return 1
    fi

    # Write file
    printf '%b' "$final_content" > "$output_path"
    print_success "Generated: $tool → $output_path"
    return 0
}

# Main function
main() {
    print_info "AI Instructions Setup Script"
    print_info "============================"

    # Parse arguments
    parse_arguments "$@"

    # Check dependencies and templates
    check_dependencies || exit 1
    check_templates || exit 1

    # Validate that required values are provided
    validate_values

    # Get tools to process
    local tools
    mapfile -t tools < <(get_tools_to_process)

    if [[ ${#tools[@]} -eq 0 ]]; then
        print_error "No valid tools specified"
        exit 1
    fi

    # Print configuration
    print_info "Configuration:"
    echo "  Description: $DESCRIPTION"
    echo "  Content length: ${#CONTENT} characters"
    echo "  Tools to generate: ${#tools[@]}"
    echo ""

    # Generate instruction files
    print_info "Generating instruction files..."
    local success_count=0
    local total_count=0

    for tool in "${tools[@]}"; do
        ((total_count++))
        if generate_instruction_file "$tool"; then
            ((success_count++))
        fi
    done

    print_info "============================"
    print_success "Complete: $success_count/$total_count files generated"

    if [[ $success_count -eq $total_count ]]; then
        print_success "All instruction files are ready!"
        return 0
    else
        print_warning "Some files were not generated"
        return 1
    fi
}

# Run main function
main "$@"
