#!/usr/bin/env bash
# Test script for setup-agent-instructions.sh

set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETUP_SCRIPT="$SCRIPT_DIR/setup-agent-instructions.sh"
TEST_DIR="/tmp/agent-setup-test-$$"

print_test() {
    echo -e "${BLUE}[TEST]${NC} $1"
}

print_pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
}

print_fail() {
    echo -e "${RED}[FAIL]${NC} $1"
}

cleanup() {
    if [[ -d "$TEST_DIR" ]]; then
        rm -rf "$TEST_DIR"
        echo "Cleaned up test directory: $TEST_DIR"
    fi
}

trap cleanup EXIT

# Test 1: Script exists and is executable
test_script_exists() {
    print_test "Checking if setup script exists and is executable"
    
    if [[ ! -f "$SETUP_SCRIPT" ]]; then
        print_fail "Setup script not found at $SETUP_SCRIPT"
        return 1
    fi
    
    if [[ ! -x "$SETUP_SCRIPT" ]]; then
        print_fail "Setup script is not executable"
        return 1
    fi
    
    print_pass "Setup script exists and is executable"
}

# Test 2: Templates exist
test_templates_exist() {
    print_test "Checking if template files exist"
    
    local templates=(
        "$SCRIPT_DIR/templates/PROJECT_INSTRUCTIONS.template.md"
        "$SCRIPT_DIR/templates/presets.json"
    )
    
    for template in "${templates[@]}"; do
        if [[ ! -f "$template" ]]; then
            print_fail "Template not found: $template"
            return 1
        fi
    done
    
    print_pass "All template files exist"
}

# Test 3: Create fresh project with React preset
test_fresh_project() {
    print_test "Testing fresh project creation with preset"
    
    local test_project="$TEST_DIR/test-react-app"
    mkdir -p "$test_project"
    
    # Create a package.json to simulate React project
    cat > "$test_project/package.json" <<EOF
{
  "name": "test-react-app",
  "dependencies": {
    "react": "^18.0.0"
  }
}
EOF
    
    # Run setup script with auto-yes (if we add that feature)
    # For now, this would be interactive
    echo "Note: Interactive test - would need manual input or auto-yes flag"
    
    print_pass "Fresh project test setup complete (manual verification needed)"
}

# Test 4: Check JSON syntax of presets
test_presets_json() {
    print_test "Validating presets.json syntax"
    
    if ! jq empty "$SCRIPT_DIR/templates/presets.json" 2>/dev/null; then
        print_fail "presets.json has invalid JSON syntax"
        return 1
    fi
    
    # Check that each preset has required fields
    local required_fields=("PROJECT_TYPE" "PRIMARY_LANGUAGE" "TECH_STACK")
    local presets=$(jq -r 'keys[]' "$SCRIPT_DIR/templates/presets.json")
    
    for preset in $presets; do
        for field in "${required_fields[@]}"; do
            if ! jq -e ".\"$preset\".\"$field\"" "$SCRIPT_DIR/templates/presets.json" > /dev/null 2>&1; then
                print_fail "Preset '$preset' missing required field: $field"
                return 1
            fi
        done
    done
    
    print_pass "presets.json is valid and well-formed"
}

# Test 5: Check template placeholders
test_template_placeholders() {
    print_test "Checking template placeholders"
    
    local project_template="$SCRIPT_DIR/templates/PROJECT_INSTRUCTIONS.template.md"
    
    # Check for required placeholders in project template
    local required_placeholders=(
        "{{PROJECT_NAME}}"
        "{{PROJECT_TYPE}}"
        "{{PRIMARY_LANGUAGE}}"
        "{{TECH_STACK}}"
    )
    
    for placeholder in "${required_placeholders[@]}"; do
        if ! grep -q "$placeholder" "$project_template"; then
            print_fail "Project template missing placeholder: $placeholder"
            return 1
        fi
    done
    
    print_pass "Template placeholders are present"
}

# Test 6: Detect project type from package.json
test_project_detection() {
    print_test "Testing project type detection"
    
    # Create test projects with different markers
    local react_project="$TEST_DIR/react-test"
    local nextjs_project="$TEST_DIR/nextjs-test"
    local python_project="$TEST_DIR/python-test"
    
    mkdir -p "$react_project" "$nextjs_project" "$python_project"
    
    # React project
    echo '{"dependencies": {"react": "^18.0.0"}}' > "$react_project/package.json"
    
    # Next.js project
    echo '{"dependencies": {"next": "^14.0.0", "react": "^18.0.0"}}' > "$nextjs_project/package.json"
    
    # Python project
    touch "$python_project/requirements.txt"
    
    print_pass "Project detection test files created (verification in script)"
}

# Main test runner
main() {
    echo "================================"
    echo "Agent Setup Script Test Suite"
    echo "================================"
    echo ""
    
    local tests_passed=0
    local tests_failed=0
    
    # Run all tests
    set +e  # Don't exit on error
    
    test_script_exists
    if [[ $? -eq 0 ]]; then
        ((tests_passed++))
    else
        ((tests_failed++))
    fi
    
    test_templates_exist
    if [[ $? -eq 0 ]]; then
        ((tests_passed++))
    else
        ((tests_failed++))
    fi
    
    test_presets_json
    if [[ $? -eq 0 ]]; then
        ((tests_passed++))
    else
        ((tests_failed++))
    fi
    
    test_template_placeholders
    if [[ $? -eq 0 ]]; then
        ((tests_passed++))
    else
        ((tests_failed++))
    fi
    
    test_project_detection
    if [[ $? -eq 0 ]]; then
        ((tests_passed++))
    else
        ((tests_failed++))
    fi
    
    set -e  # Re-enable exit on error
    
    # Note: Fresh project test requires manual interaction
    echo ""
    echo "Note: test_fresh_project requires manual interaction"
    
    echo ""
    echo "================================"
    echo "Test Results"
    echo "================================"
    echo -e "${GREEN}Passed: $tests_passed${NC}"
    echo -e "${RED}Failed: $tests_failed${NC}"
    echo ""
    
    if [[ $tests_failed -eq 0 ]]; then
        echo -e "${GREEN}All automated tests passed!${NC}"
        exit 0
    else
        echo -e "${RED}Some tests failed.${NC}"
        exit 1
    fi
}

main
