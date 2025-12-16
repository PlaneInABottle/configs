#!/usr/bin/env bash
# Extract Subagent Content to Master Templates
# Extracts content (excluding headers) from current subagent files to master templates

set -eo pipefail

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
MASTER_DIR="$CONFIG_DIR/templates/subagents/master"
HEADERS_DIR="$CONFIG_DIR/templates/subagents/headers"

print_info() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_step() {
    echo -e "${BLUE}►${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

get_header_lines() {
    local agent="$1"
    local system="$2"
    
    case "$system:$agent" in
        copilot:*) echo "4" ;;
        opencode:debugger) echo "44" ;;
        opencode:planner) echo "25" ;;
        opencode:reviewer) echo "44" ;;
        opencode:implementer) echo "45" ;;
        opencode:refactor) echo "46" ;;
        *) echo "0" ;;
    esac
}

extract_content() {
    local agent_name="$1"
    local copilot_file="copilot/.copilot/agents/${agent_name}.agent.md"
    local opencode_file="opencode/.config/opencode/agent/${agent_name}.md"
    
    print_step "Extracting $agent_name..."
    
    # Verify files exist
    if [[ ! -f "$CONFIG_DIR/$copilot_file" ]]; then
        print_error "Copilot file not found: $copilot_file"
        return 1
    fi
    
    if [[ ! -f "$CONFIG_DIR/$opencode_file" ]]; then
        print_error "Opencode file not found: $opencode_file"
        return 1
    fi
    
    # Get header line counts
    local copilot_header_lines=$(get_header_lines "$agent_name" "copilot")
    local opencode_header_lines=$(get_header_lines "$agent_name" "opencode")
    
    local copilot_content_start=$((copilot_header_lines + 1))
    local opencode_content_start=$((opencode_header_lines + 1))
    
    # Extract content from opencode (source of truth)
    tail -n +${opencode_content_start} "$CONFIG_DIR/$opencode_file" > "$MASTER_DIR/${agent_name}.md"
    
    # Verify content was extracted
    if [[ ! -s "$MASTER_DIR/${agent_name}.md" ]]; then
        print_error "Failed to extract content for $agent_name"
        return 1
    fi
    
    # Verify copilot and opencode content match (excluding headers)
    set +e
    diff <(tail -n +${copilot_content_start} "$CONFIG_DIR/$copilot_file") \
         <(tail -n +${opencode_content_start} "$CONFIG_DIR/$opencode_file") > /dev/null 2>&1
    local diff_result=$?
    set -e
    
    if [[ $diff_result -ne 0 ]]; then
        print_warning "Content mismatch detected for $agent_name - using opencode version"
    fi
    
    local line_count=$(wc -l < "$MASTER_DIR/${agent_name}.md" | tr -d ' ')
    print_info "Extracted ${agent_name}.md (${line_count} lines)"
}

extract_headers() {
    print_step "Extracting header templates..."
    
    # Extract copilot header template
    cat > "$HEADERS_DIR/copilot.template" << 'EOF'
---
name: {{NAME}}
description: "{{DESCRIPTION}}"
---
EOF
    
    # Create opencode header template with placeholders
    cat > "$HEADERS_DIR/opencode.template" << 'EOF'
---
description: "{{DESCRIPTION}}"
mode: subagent
examples:
{{EXAMPLES}}
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
EOF
    
    print_info "Created header templates"
}

create_metadata() {
    print_step "Creating metadata file..."
    
    cat > "$MASTER_DIR/METADATA.json" << 'EOF'
{
  "version": "1.0.0",
  "created": "2025-12-16T10:23:22.063Z",
  "description": "Master templates for subagent content",
  "subagents": {
    "debugger": {
      "name": "debugger",
      "description": "Debugging specialist - finds and fixes bugs directly",
      "examples": [
        "  - \"Use for test failures and unexpected behavior diagnosis\"",
        "  - \"Use for performance issues and memory leaks\"",
        "  - \"Use for integration problems and API failures\"",
        "  - \"Use for complex multi-component issue resolution\""
      ]
    },
    "planner": {
      "name": "planner",
      "description": "Software architect that creates detailed implementation plans without writing code. Emphasizes YAGNI, KISS, DRY, and leveraging existing systems.",
      "examples": [
        "  - \"Use for complex multi-step features requiring architectural design\"",
        "  - \"Use for large refactoring projects needing systematic planning\"",
        "  - \"Use for security-critical changes requiring careful risk assessment\""
      ]
    },
    "reviewer": {
      "name": "reviewer",
      "description": "Comprehensive code reviewer - finds security vulnerabilities, bugs, logical issues, and code quality problems. Enforces YAGNI, KISS, DRY principles and validates existing system usage.",
      "examples": [
        "  - \"Use for security review of authentication systems\"",
        "  - \"Use for code quality assessment before merging\"",
        "  - \"Use for architectural validation of implementation plans\""
      ]
    },
    "implementer": {
      "name": "implementer",
      "description": "Feature implementation specialist - builds new functionality and adds features. Follows YAGNI, KISS, DRY principles and leverages existing systems.",
      "examples": [
        "  - \"Use for new API endpoints with comprehensive error handling\"",
        "  - \"Use for complex business logic with thorough testing\"",
        "  - \"Use for UI components with accessibility and performance\""
      ]
    },
    "refactor": {
      "name": "refactor",
      "description": "Refactoring specialist - improves code quality without changing behavior. Applies YAGNI, KISS, DRY principles and leverages existing systems.",
      "examples": [
        "  - \"Use for code smell elimination and technical debt reduction\"",
        "  - \"Use for performance optimization without behavior changes\"",
        "  - \"Use for improving code maintainability and readability\""
      ]
    }
  }
}
EOF
    
    print_info "Created METADATA.json"
}

main() {
    echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║   Extract Subagents to Master Templates   ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
    echo ""
    
    # Create directories
    mkdir -p "$MASTER_DIR" "$HEADERS_DIR"
    
    # Extract each subagent
    local agents=(debugger planner reviewer implementer refactor)
    for agent_name in "${agents[@]}"; do
        extract_content "$agent_name"
    done
    
    echo ""
    
    # Extract headers
    extract_headers
    
    # Create metadata
    create_metadata
    
    echo ""
    print_info "Extraction complete!"
    echo ""
    echo "Master templates created in: $MASTER_DIR"
    echo "Header templates created in: $HEADERS_DIR"
    echo ""
    echo "Files created:"
    echo "  • templates/subagents/master/debugger.md"
    echo "  • templates/subagents/master/planner.md"
    echo "  • templates/subagents/master/reviewer.md"
    echo "  • templates/subagents/master/implementer.md"
    echo "  • templates/subagents/master/refactor.md"
    echo "  • templates/subagents/master/METADATA.json"
    echo "  • templates/subagents/headers/copilot.template"
    echo "  • templates/subagents/headers/opencode.template"
    echo ""
}

main "$@"
