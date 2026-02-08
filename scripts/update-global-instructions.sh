#!/usr/bin/env bash
# Update Global Instructions from Master Template
# Generates system-specific instruction files from master template + headers

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
TEMPLATE_DIR="$CONFIG_DIR/templates/global-instructions"
MASTER_FILE="$TEMPLATE_DIR/master.md"
HEADERS_DIR="$TEMPLATE_DIR/headers"
METADATA_FILE="$TEMPLATE_DIR/metadata.json"

# Options
SYSTEM="all"
DRY_RUN=false

usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Updates global instruction files from master template."
    echo ""
    echo "Options:"
    echo "  --system=NAME         Update specific system (copilot|opencode|claude|gemini|all) [default: all]"
    echo "  --dry-run             Show what would be updated without making changes"
    echo "  --help, -h            Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 --system=copilot"
    echo "  $0 --system=all --dry-run"
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
        print_error "METADATA.json not found at $METADATA_FILE"
        exit 1
    fi

    if [[ ! -f "$MASTER_FILE" ]]; then
        print_error "Master template not found at $MASTER_FILE"
        exit 1
    fi

    if ! command -v python3 &> /dev/null; then
        print_error "python3 is required for metadata parsing"
        exit 1
    fi
}

get_metadata_value() {
    local system="$1"
    local key="$2"

python3 -c "import json
with open('$METADATA_FILE', 'r', encoding='utf-8') as f:
    d = json.load(f)
value = d['systems']['$system']['$key']
if isinstance(value, bool):
    print(str(value).lower())
else:
    print(value)"
}

filter_sections_for_system() {
    local system="$1"
    local input_file="$2"
    
    python3 - "$system" "$input_file" "$METADATA_FILE" <<'PYTHON_SCRIPT'
import json
import re
import sys

target_system = sys.argv[1]
input_file = sys.argv[2]
metadata_file = sys.argv[3]

with open(input_file, 'r', encoding='utf-8') as f:
    content = f.read()

# Load metadata for text replacements
with open(metadata_file, 'r', encoding='utf-8') as f:
    metadata = json.load(f)

text_replacements = metadata.get('systems', {}).get(target_system, {}).get('text_replacements', {})

# Pattern to match section markers
# <!-- SECTION:section_id:START:system1,system2 -->...<!-- SECTION:section_id:END -->
pattern = r'<!-- SECTION:(\w+):START:([\w,!]+) -->\n?(.*?)\n?<!-- SECTION:\1:END -->'

def should_include_section(enabled_for_str, target):
    enabled_systems = [s.strip() for s in enabled_for_str.split(',')]
    
    # Check for exclusion syntax (e.g., !copilot means all except copilot)
    exclusions = [s[1:] for s in enabled_systems if s.startswith('!')]
    inclusions = [s for s in enabled_systems if not s.startswith('!')]
    
    # If there are exclusions, include unless target is excluded
    if exclusions:
        return target not in exclusions
    
    # Otherwise, check inclusions
    return target in inclusions or 'all' in inclusions

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
        result = result.replace(full_match, '')

# Apply text replacements if configured for this system
for old_text, new_text in text_replacements.items():
    result = result.replace(old_text, new_text)

print(result, end='')
PYTHON_SCRIPT
}

update_system() {
    local system="$1"

    local requires_header=$(get_metadata_value "$system" "requires_header")
    local target_file="$CONFIG_DIR/$(get_metadata_value "$system" "target_file")"
    local header_file="$HEADERS_DIR/${system}.header"

    print_step "Updating ${system} global instructions..."

    if [[ "$DRY_RUN" == true ]]; then
        print_dry_run "Would update: $target_file"
        return 0
    fi

    # Generate the instruction file
    if [[ "$requires_header" == "true" ]]; then
        # For systems that require headers (copilot)
        if [[ ! -f "$header_file" ]]; then
            print_error "Header file not found: $header_file"
            return 1
        fi

        {
            cat "$header_file"
            echo ""
            echo "<!-- sync-test: generated via templates/global-instructions/master.md + scripts/update-global-instructions.sh -->"
            echo ""
            filter_sections_for_system "$system" "$MASTER_FILE"
        } > "$target_file"
    else
        # For systems that don't require headers (opencode)
        {
            echo "<!-- sync-test: generated via templates/global-instructions/master.md + scripts/update-global-instructions.sh -->"
            echo ""
            filter_sections_for_system "$system" "$MASTER_FILE"
        } > "$target_file"
    fi

    local line_count=$(wc -l < "$target_file" | tr -d ' ')
    print_info "Updated ${system} (${line_count} lines)"
}

main() {
    echo -e "${BLUE}╔══════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║   Update Global Instructions from Template  ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════╝${NC}"
    echo ""

    check_prerequisites

    # Determine which systems to update
    local systems_to_update=()
    if [[ "$SYSTEM" == "all" ]]; then
        systems_to_update=(copilot opencode claude gemini)
    else
        systems_to_update=("$SYSTEM")
    fi

    # Update each system
    for sys in "${systems_to_update[@]}"; do
        update_system "$sys"
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
if [[ "$SYSTEM" != "all" ]] && [[ "$SYSTEM" != "copilot" ]] && \
   [[ "$SYSTEM" != "opencode" ]] && [[ "$SYSTEM" != "claude" ]] && \
   [[ "$SYSTEM" != "gemini" ]]; then
    echo "Error: Invalid system name: $SYSTEM"
    usage
fi

main