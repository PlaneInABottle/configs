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
FORCE=false

usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Updates subagent files from master templates."
    echo ""
    echo "Options:"
    echo "  --agent=NAME          Update specific agent (debugger|planner|reviewer|implementer|refactor|coordinator|prompt-creator|all)"
    echo "  --system=NAME         Update specific system (copilot|opencode|all) [default: all]"
    echo "  --dry-run             Show what would be updated without making changes"
    echo "  --force               Overwrite without confirmation"
    echo "  --help, -h            Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 --agent=debugger"
    echo "  $0 --agent=all --system=copilot"
    echo "  $0 --agent=planner --dry-run"
    echo "  $0 --agent=all --force"
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

    python3 - <<'PY' "$METADATA_FILE" "$agent" "$key" "$default_value" 2>/dev/null || true
import json, sys
path, agent, key, default_value = sys.argv[1:5]
d = json.load(open(path))
print(d.get('subagents', {}).get(agent, {}).get(key, default_value))
PY
}

get_metadata_lines() {
    # Prints joined lines from a JSON list.
    # Usage: get_metadata_lines subagents debugger examples
    local root="$1"
    local agent="$2"
    local key="$3"

    python3 - <<'PY' "$METADATA_FILE" "$root" "$agent" "$key" 2>/dev/null || true
import json, sys
path, root, agent, key = sys.argv[1:5]
d = json.load(open(path))
print("\n".join(d[root][agent].get(key, [])))
PY
}

get_default_lines() {
    # Usage: get_default_lines opencode tools_lines
    local system="$1"
    local key="$2"

    python3 - <<'PY' "$METADATA_FILE" "$system" "$key" 2>/dev/null || true
import json, sys
path, system, key = sys.argv[1:4]
d = json.load(open(path))
print("\n".join(d.get('defaults', {}).get(system, {}).get(key, [])))
PY
}

get_opencode_lines_for_agent() {
    # Usage: get_opencode_lines_for_agent reviewer tools_lines
    # Falls back to defaults.opencode.<key> if subagents.<agent>.opencode.<key> is empty/missing
    local agent="$1"
    local key="$2"

    python3 - <<'PY' "$METADATA_FILE" "$agent" "$key" 2>/dev/null || true
import json, sys
path, agent, key = sys.argv[1:4]
d = json.load(open(path))
sub = d.get('subagents', {}).get(agent, {})
override = sub.get('opencode', {}).get(key)
if override:
    print("\n".join(override))
else:
    print("\n".join(d.get('defaults', {}).get('opencode', {}).get(key, [])))
PY
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

    # opencode
    local examples="$(get_metadata_lines subagents "$agent" examples)"
    local tools_lines="$(get_opencode_lines_for_agent "$agent" tools_lines)"
    local permission_lines="$(get_opencode_lines_for_agent "$agent" permission_lines)"

    # Read mode from metadata; default to subagent
    local mode
    mode="$(get_metadata_value_or_default "$agent" "mode" "subagent")"

    cat <<EOF
---
description: "${description}"
mode: ${mode}
examples:
${examples}
tools:
${tools_lines}
permission:
${permission_lines}
---
EOF
}

update_agent() {
    local agent="$1"
    local system="$2"
    
    local master_file="$MASTER_DIR/${agent}.md"
    
    if [[ ! -f "$master_file" ]]; then
        print_error "Master template not found: ${agent}.md"
        return 1
    fi
    
    # Determine output file
    local output_file=""
    if [[ "$system" == "copilot" ]]; then
        output_file="$CONFIG_DIR/copilot/.copilot/agents/${agent}.agent.md"
    else
        output_file="$CONFIG_DIR/opencode/.config/opencode/agent/${agent}.md"
    fi
    
    print_step "Updating ${system}/${agent}..."
    
    if [[ "$DRY_RUN" == true ]]; then
        print_dry_run "Would update: $output_file"
        return 0
    fi
    
    # Check if file exists and not in force mode
    if [[ -f "$output_file" ]] && [[ "$FORCE" == false ]]; then
        read -p "File exists. Overwrite $output_file? (y/N): " -r
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_warning "Skipped ${system}/${agent}"
            return 0
        fi
    fi
    
    # Generate header
    local header=$(generate_header "$agent" "$system")
    
    # Combine header + content
    {
        echo "$header"
        echo ""
        cat "$master_file"
    } > "$output_file"
    
    local line_count=$(wc -l < "$output_file" | tr -d ' ')
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
        systems_to_update=(copilot opencode)
    else
        systems_to_update=("$SYSTEM")
    fi

    # Update each system (agent logic moved into the loop for system-specific handling)
    for sys in "${systems_to_update[@]}"; do
        local agents_to_update=()
        if [[ "$AGENT" == "all" ]]; then
            if [[ "$sys" == "copilot" ]]; then
                agents_to_update=(planner reviewer implementer)  # Skip coordinator and prompt-creator for copilot
            else
                agents_to_update=(planner reviewer implementer coordinator prompt-creator)
            fi
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
            FORCE=true
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
   [[ "$AGENT" != "reviewer" ]] && [[ "$AGENT" != "implementer" ]] && [[ "$AGENT" != "coordinator" ]] && [[ "$AGENT" != "prompt-creator" ]]; then
    echo "Error: Invalid agent name: $AGENT"
    usage
fi

if [[ "$SYSTEM" != "all" ]] && [[ "$SYSTEM" != "copilot" ]] && [[ "$SYSTEM" != "opencode" ]]; then
    echo "Error: Invalid system name: $SYSTEM"
    usage
fi

main
