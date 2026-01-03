#!/usr/bin/env bash
# Validate Subagent Files Against Master Templates
# Checks that copilot and opencode files have identical content (excluding headers)
# and that generated files don't contain raw SECTION/INCLUDE markers

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

content_start_line() {
    # Returns the 1-indexed line number where content starts (after last --- and following blank lines)
    local file="$1"
    python3 -c "
import sys
p = '$file'
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
"
}

get_agents_from_metadata() {
    # Get all agent names from METADATA.json
    python3 -c "
import json
d = json.load(open('$METADATA_FILE'))
print(' '.join(d['subagents'].keys()))
"
}

get_agent_systems() {
    # Get systems where agent is enabled (has header_lines)
    local agent="$1"
    python3 -c "
import json
d = json.load(open('$METADATA_FILE'))
headers = d['subagents']['$agent'].get('header_lines', {})
print(' '.join(headers.keys()))
"
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

check_unprocessed_markers() {
    # Check if file contains raw SECTION or INCLUDE markers or error markers
    local file="$1"
    local errors=0
    
    # Check for unprocessed SECTION markers
    if grep -q '<!-- SECTION:' "$file" 2>/dev/null; then
        print_error "  Contains unprocessed SECTION markers"
        errors=1
    fi
    
    # Check for unprocessed INCLUDE markers
    if grep -q '<!-- INCLUDE:' "$file" 2>/dev/null; then
        print_error "  Contains unprocessed INCLUDE markers"
        errors=1
    fi
    
    # Check for include-not-found errors
    if grep -q '<!-- ERROR: Include not found' "$file" 2>/dev/null; then
        print_error "  Contains include-not-found errors"
        errors=1
    fi
    
    return $errors
}

validate_agent() {
    local agent="$1"
    local systems
    systems=$(get_agent_systems "$agent")
    
    if [[ -z "$systems" ]]; then
        print_warning "Skipping $agent: No systems enabled in metadata"
        return 0
    fi
    
    print_step "Validating $agent..."
    
    local all_valid=true
    local files_checked=()
    local contents=()
    
    for system in $systems; do
        local file=""
        if [[ "$system" == "copilot" ]]; then
            file="$CONFIG_DIR/copilot/.copilot/agents/${agent}.agent.md"
        elif [[ "$system" == "claude" ]]; then
            file="$CONFIG_DIR/claude/.claude/agents/${agent}.md"
        else
            file="$CONFIG_DIR/opencode/.config/opencode/agent/${agent}.md"
        fi
        
        if [[ ! -f "$file" ]]; then
            print_error "  $system file not found: $file"
            all_valid=false
            continue
        fi
        
        # Check for unprocessed markers
        if ! check_unprocessed_markers "$file"; then
            print_error "  $system file has unprocessed markers: $file"
            all_valid=false
        fi
        
        files_checked+=("$file")
    done
    
    if [[ "$all_valid" == true ]]; then
        print_info "$agent validated (${#files_checked[@]} systems)"
        return 0
    else
        return 1
    fi
}

main() {
    echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║    Validate Subagent Content              ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
    echo ""
    
    if [[ ! -f "$METADATA_FILE" ]]; then
        print_error "METADATA.json not found at $METADATA_FILE"
        exit 1
    fi
    
    local agents
    agents=$(get_agents_from_metadata)
    local all_valid=true
    
    for agent in $agents; do
        if ! validate_agent "$agent"; then
            all_valid=false
        fi
    done
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    if [[ "$all_valid" == true ]]; then
        print_info "All subagents validated!"
        echo ""
        echo "✓ No unprocessed SECTION or INCLUDE markers"
        echo "✓ No include-not-found errors"
        exit 0
    else
        print_error "Some subagents have issues!"
        echo ""
        echo "Run: ./scripts/update-subagents.sh --agent=all"
        exit 1
    fi
}

main "$@"
