#!/usr/bin/env bash
# Update Subagent Files from Master Templates
# Generates copilot and opencode subagent files from master templates + headers

set -eo pipefail

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
MASTER_DIR="$CONFIG_DIR/templates/subagents/master"
HEADERS_DIR="$CONFIG_DIR/templates/subagents/headers"
METADATA_FILE="$MASTER_DIR/METADATA.json"

# Options
AGENT=""
SYSTEM="all"
DRY_RUN=false

usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Updates subagent files from master templates."
    echo ""
    echo "Options:"
    echo "  --agent=NAME          Update specific agent (planner|reviewer|implementer|coordinator|prompt-creator|all)"
    echo "  --system=NAME         Update specific system (copilot|opencode|claude|all) [default: all]"
    echo "  --dry-run             Show what would be updated without making changes"
    echo "  --help, -h            Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 --agent=planner"
    echo "  $0 --agent=all --system=copilot"
    echo "  $0 --agent=planner --dry-run"
    exit 1
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

print_dry_run() {
    echo -e "${CYAN}[DRY RUN]${NC} $1"
}

check_prerequisites() {
    if [[ ! -f "$METADATA_FILE" ]]; then
        print_error "METADATA.json not found. Run extract-to-master.sh first."
        exit 1
    fi

    if ! command -v python3 &> /dev/null; then
        print_error "python3 is required for metadata parsing"
        exit 1
    fi
}

get_metadata_value() {
    local agent="$1"
    local key="$2"
    python3 -c "import json; d=json.load(open('$METADATA_FILE')); print(d['subagents']['$agent']['$key'])"
}

get_metadata_value_or_default() {
    # Usage: get_metadata_value_or_default planner mode subagent
    local agent="$1"
    local key="$2"
    local default_value="$3"

    python3 -c "
import json, sys
path, agent, key, default_value = '$METADATA_FILE', '$agent', '$key', '$default_value'
d = json.load(open(path))
print(d.get('subagents', {}).get(agent, {}).get(key, default_value))
" 2>/dev/null || true
}

get_metadata_lines() {
    # Prints joined lines from a JSON list.
    # Usage: get_metadata_lines subagents debugger examples
    local root="$1"
    local agent="$2"
    local key="$3"

    python3 -c "
import json, sys
path, root, agent, key = '$METADATA_FILE', '$root', '$agent', '$key'
d = json.load(open(path))
print('\n'.join(d[root][agent].get(key, [])))
" 2>/dev/null || true
}

get_default_lines() {
    local system="$1"
    local key="$2"

    python3 -c "
import json, sys
path, system, key = '$METADATA_FILE', '$system', '$key'
d = json.load(open(path))
print('\n'.join(d.get('defaults', {}).get(system, {}).get(key, [])))
" 2>/dev/null || true
}

get_opencode_lines_for_agent() {
    local agent="$1"
    local key="$2"

    python3 -c "
import json, sys
path, agent, key = '$METADATA_FILE', '$agent', '$key'
d = json.load(open(path))
sub = d.get('subagents', {}).get(agent, {})
override = sub.get('opencode', {}).get(key)
if override:
    print('\n'.join(override))
else:
    print('\n'.join(d.get('defaults', {}).get('opencode', {}).get(key, [])))
" 2>/dev/null || true
}

process_includes() {
    local base_dir="$CONFIG_DIR"
    
    python3 -c '
import sys, re, os

base_dir = sys.argv[1]
content = sys.stdin.read()

def replace_include(match):
    rel_path = match.group(1).strip()
    full_path = os.path.join(base_dir, rel_path)
    if os.path.exists(full_path):
        with open(full_path, "r", encoding="utf-8") as f:
            return f.read()
    return f"<!-- ERROR: Include not found {rel_path} -->"

# Process includes recursively (simple single-pass for now)
print(re.sub(r"<!-- INCLUDE:(.*?) -->", replace_include, content))
' "$base_dir"
}

filter_sections_for_system() {
    # Filter SECTION markers based on target system
    # Supports: all, inclusion (copilot,claude), exclusion (!copilot)
    local system="$1"
    
    python3 -c '
import re
import sys

target_system = sys.argv[1]
content = sys.stdin.read()

# Pattern to match section markers
# <!-- SECTION:section_id:START:system1,system2 -->...<!-- SECTION:section_id:END -->
pattern = r"<!-- SECTION:(\w+):START:([\w,!]+) -->\n?(.*?)\n?<!-- SECTION:\1:END -->"

def should_include_section(enabled_for_str, target):
    enabled_systems = [s.strip() for s in enabled_for_str.split(",")]
    
    # Check for exclusion syntax (e.g., !copilot means all except copilot)
    exclusions = [s[1:] for s in enabled_systems if s.startswith("!")]
    inclusions = [s for s in enabled_systems if not s.startswith("!")]
    
    # If there are exclusions, include unless target is excluded
    if exclusions:
        return target not in exclusions
    
    # Otherwise, check inclusions
    return target in inclusions or "all" in inclusions

result = content
for match in re.finditer(pattern, content, re.DOTALL):
    section_id = match.group(1)
    enabled_for = match.group(2)
    section_content = match.group(3)
    full_match = match.group(0)
    
    if should_include_section(enabled_for, target_system):
        # Keep section content but remove markers
        result = result.replace(full_match, section_content)
    else:
        # Remove entire section including markers
        result = result.replace(full_match, "")

print(result, end="")
' "$system"
}

generate_header() {
    local agent="$1"
    local system="$2"

    local name=$(get_metadata_value "$agent" "name")
    local description=$(get_metadata_value "$agent" "description")

    if [[ "$system" == "copilot" ]]; then
        cat <<EOF
---
name: ${name}
description: "${description}"
---
EOF
        return 0
    fi

    if [[ "$system" == "claude" ]]; then
        cat <<EOF
---
name: ${name}
description: "${description}"
model: inherit
---
EOF
        return 0
    fi

    # opencode
    local examples="$(get_metadata_lines subagents "$agent" examples)"
    local permission_lines="$(get_opencode_lines_for_agent "$agent" permission_lines)"

    local mode
    mode="$(get_metadata_value_or_default "$agent" "mode" "subagent")"

    cat <<EOF
---
description: "${description}"
mode: ${mode}
examples:
${examples}
permission:
${permission_lines}
---
EOF
}

update_agent() {
    local agent="$1"
    local system="$2"

    # Check if agent is enabled for this system
    local has_header
    has_header=$(python3 -c "import json; d=json.load(open('$METADATA_FILE')); print('$system' in d['subagents']['$agent'].get('header_lines', {}))")

    if [[ "$has_header" != "True" ]]; then
        print_warning "Skipping ${system}/${agent}: Not enabled for this system in metadata."
        return 0
    fi
    
    local master_file="$MASTER_DIR/${agent}.md"
    
    if [[ ! -f "$master_file" ]]; then
        print_error "Master template not found: ${agent}.md"
        return 1
    fi
    
    # Determine output file
    local output_file=""
    if [[ "$system" == "copilot" ]]; then
        output_file="$CONFIG_DIR/copilot/.copilot/agents/${agent}.agent.md"
    elif [[ "$system" == "claude" ]]; then
        output_file="$CONFIG_DIR/claude/.claude/agents/${agent}.md"
    else
        output_file="$CONFIG_DIR/opencode/.config/opencode/agent/${agent}.md"
    fi
    
    print_step "Updating ${system}/${agent}..."
    
    if [[ "$DRY_RUN" == true ]]; then
        print_dry_run "Would update: $output_file"
        return 0
    fi
    
    # Generate header
    local header
    header=$(generate_header "$agent" "$system")
    
    # Combine header + content, process includes, then filter sections
    {
        echo "$header"
        echo ""
        cat "$master_file"
    } | process_includes | filter_sections_for_system "$system" > "$output_file"
    
    local line_count
    line_count=$(wc -l < "$output_file" | tr -d ' ')
    print_info "Updated ${system}/${agent} (${line_count} lines)"
}

main() {
    echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║   Update Subagents from Master Templates  ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
    echo ""
    
    check_prerequisites
    
    # Determine which systems to update
    local systems_to_update=()
    if [[ "$SYSTEM" == "all" ]]; then
        systems_to_update=(copilot opencode claude)
    else
        systems_to_update=("$SYSTEM")
    fi

    # Update each system
    for sys in "${systems_to_update[@]}"; do
        local agents_to_update=()
        if [[ "$AGENT" == "all" ]]; then
            # Dynamically get all subagent keys from METADATA.json
            agents_to_update=($(python3 -c "import json; d=json.load(open('$METADATA_FILE')); print(' '.join(d['subagents'].keys()))"))
        else
            agents_to_update=("$AGENT")
        fi

        for agent in "${agents_to_update[@]}"; do
            update_agent "$agent" "$sys"
        done
    done
    
    echo ""
    if [[ "$DRY_RUN" == true ]]; then
        print_info "Dry run complete! No files were modified."
    else
        print_info "Update complete!"
    fi
    echo ""
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --agent=*)
            AGENT="${1#*=}"
            shift
            ;;
        --system=*)
            SYSTEM="${1#*=}"
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --force)
            # Ignored for backward compatibility
            shift
            ;;
        --help|-h)
            usage
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

# Validate arguments
if [[ -z "$AGENT" ]]; then
    echo "Error: --agent is required"
    usage
fi

if [[ "$AGENT" != "all" ]] && [[ "$AGENT" != "planner" ]] && \
   [[ "$AGENT" != "reviewer" ]] && [[ "$AGENT" != "implementer" ]] && \
   [[ "$AGENT" != "coordinator" ]] && [[ "$AGENT" != "prompt-creator" ]]; then
    echo "Error: Invalid agent name: $AGENT"
    usage
fi

if [[ "$SYSTEM" != "all" ]] && [[ "$SYSTEM" != "copilot" ]] && \
   [[ "$SYSTEM" != "opencode" ]] && [[ "$SYSTEM" != "claude" ]]; then
    echo "Error: Invalid system name: $SYSTEM"
    usage
fi

main
