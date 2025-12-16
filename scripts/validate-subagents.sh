#!/usr/bin/env bash
# Validate Subagent Files Against Master Templates
# Checks that copilot and opencode files have identical content (excluding headers)

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
METADATA_FILE="$CONFIG_DIR/templates/subagents/master/METADATA.json"

# Header line counts (line before content starts) - read from METADATA.json
get_header_lines() {
    local agent="$1"
    local system="$2"
    
    # Try to read from METADATA.json first
    if [[ -f "$METADATA_FILE" ]] && command -v python3 &> /dev/null; then
        local line_count=$(python3 -c "import json; data=json.load(open('$METADATA_FILE')); print(data['subagents']['$agent']['header_lines']['$system'])" 2>/dev/null || echo "")
        if [[ -n "$line_count" ]]; then
            echo "$line_count"
            return 0
        fi
    fi
    
    # Fallback to hardcoded values if METADATA.json not available
    case "$system:$agent" in
        copilot:debugger) echo "5" ;;
        copilot:planner) echo "4" ;;
        copilot:reviewer) echo "5" ;;
        copilot:implementer) echo "4" ;;
        copilot:refactor) echo "4" ;;
        opencode:debugger) echo "46" ;;
        opencode:planner) echo "25" ;;
        opencode:reviewer) echo "45" ;;
        opencode:implementer) echo "45" ;;
        opencode:refactor) echo "46" ;;
        *) echo "0" ;;
    esac
}

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

validate_agent() {
    local agent="$1"
    
    local copilot_file="$CONFIG_DIR/copilot/.copilot/agents/${agent}.agent.md"
    local opencode_file="$CONFIG_DIR/opencode/.config/opencode/agent/${agent}.md"
    
    print_step "Validating $agent..."
    
    # Check files exist
    if [[ ! -f "$copilot_file" ]]; then
        print_error "Copilot file not found: $copilot_file"
        return 1
    fi
    
    if [[ ! -f "$opencode_file" ]]; then
        print_error "Opencode file not found: $opencode_file"
        return 1
    fi
    
    # Get header line counts
    local copilot_header=$(get_header_lines "$agent" "copilot")
    local opencode_header=$(get_header_lines "$agent" "opencode")
    
    local copilot_start=$((copilot_header + 1))
    local opencode_start=$((opencode_header + 1))
    
    # Extract content (skip headers)
    local copilot_content=$(tail -n +${copilot_start} "$copilot_file")
    local opencode_content=$(tail -n +${opencode_start} "$opencode_file")
    
    # Compare content
    if [[ "$copilot_content" == "$opencode_content" ]]; then
        local line_count=$(echo "$copilot_content" | wc -l | tr -d ' ')
        print_info "$agent content identical (${line_count} lines)"
        return 0
    else
        print_error "$agent content differs!"
        echo "  Copilot: $copilot_file (content from line $copilot_start)"
        echo "  Opencode: $opencode_file (content from line $opencode_start)"
        
        # Show diff summary
        local diff_lines=$(diff <(echo "$copilot_content") <(echo "$opencode_content") | wc -l | tr -d ' ')
        echo "  Diff: $diff_lines lines differ"
        
        return 1
    fi
}

main() {
    echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║    Validate Subagent Content Sync         ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
    echo ""
    
    local agents=(debugger planner reviewer implementer refactor)
    local all_valid=true
    
    for agent in "${agents[@]}"; do
        if ! validate_agent "$agent"; then
            all_valid=false
        fi
    done
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    if [[ "$all_valid" == true ]]; then
        print_info "All subagents are in sync!"
        echo ""
        echo "✓ Copilot and Opencode files have identical content"
        echo "✓ Only headers differ (as expected)"
        exit 0
    else
        print_error "Some subagents are out of sync!"
        echo ""
        echo "Run: ./scripts/update-subagents.sh --agent=all --force"
        echo "Or:  ./scripts/update-subagents.sh --agent=<name> --force"
        exit 1
    fi
}

main "$@"
