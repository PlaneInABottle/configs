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

content_start_line() {
    # Returns the 1-indexed line number where content starts (after last --- and following blank lines)
    local file="$1"
    python3 - <<'PY' "$file"
import sys
p = sys.argv[1]
lines = open(p, 'r', encoding='utf-8', errors='replace').read().splitlines()
idxs = [i for i,l in enumerate(lines) if l.strip() == '---']
if not idxs:
    print(1)
    raise SystemExit(0)
start = idxs[-1] + 2  # line after closing --- (1-indexed)
# Skip blank lines
while start <= len(lines) and lines[start-1].strip() == '':
    start += 1
print(start)
PY
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
    
    local copilot_start=$(content_start_line "$copilot_file")
    local opencode_start=$(content_start_line "$opencode_file")

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
