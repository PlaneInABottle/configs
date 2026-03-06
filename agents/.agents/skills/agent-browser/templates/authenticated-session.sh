#!/bin/bash
# Template: Authenticated Session Workflow
# Purpose: Discovery-first auth session scaffold; customize refs before saving reusable state
# Usage: ./authenticated-session.sh <login-url> [state-file]
#
# Environment variables:
#   APP_USERNAME - Login username/email
#   APP_PASSWORD - Login password
#
# Workflow:
#   1. If a saved state file exists, load it and test whether it still works
#   2. If not, open the login page in discovery mode so you can map refs
#   3. Replace the LOGIN FLOW section with site-specific refs
#   4. Save state explicitly with `state save`
#
# Optional shortcut once the state file exists:
#   agent-browser --state ./auth-state.json open https://app.example.com/dashboard

set -euo pipefail

LOGIN_URL="${1:?Usage: $0 <login-url> [state-file]}"
STATE_FILE="${2:-./auth-state.json}"

is_login_like_url() {
    local url="$1"
    [[ "$url" == *"login"* ]] || [[ "$url" == *"signin"* ]] || [[ "$url" == *"auth"* ]]
}

echo "Authentication workflow: $LOGIN_URL"

# ================================================================
# SAVED STATE: Reuse explicit state file when it is still valid
# ================================================================
if [[ -f "$STATE_FILE" ]]; then
    echo "Loading saved state from $STATE_FILE..."
    agent-browser state load "$STATE_FILE"
    agent-browser open "$LOGIN_URL"
    agent-browser wait --load networkidle

    CURRENT_URL="$(agent-browser get url)"
    if ! is_login_like_url "$CURRENT_URL"; then
        echo "Session restored successfully"
        agent-browser snapshot -i
        exit 0
    fi

    echo "Saved session appears expired; removing stale state and continuing to discovery/login flow..."
    rm -f "$STATE_FILE"
    agent-browser close || true
fi

# ================================================================
# DISCOVERY MODE: Show form structure so you can map refs safely
# ================================================================
echo "Opening login page..."
agent-browser open "$LOGIN_URL"
agent-browser wait --load networkidle

echo ""
echo "Login form structure:"
echo "---"
agent-browser snapshot -i
echo "---"
echo ""
echo "Next steps:"
echo "  1. Note the refs: username=@e?, password=@e?, submit=@e?"
echo "  2. Update the LOGIN FLOW section below with those refs"
echo "  3. Set: export APP_USERNAME='...' APP_PASSWORD='...'"
echo "  4. Delete this DISCOVERY MODE section once your refs are stable"
echo ""
agent-browser close
exit 0

# ================================================================
# LOGIN FLOW: Uncomment and customize after discovery
# ================================================================
# : "${APP_USERNAME:?Set APP_USERNAME environment variable}"
# : "${APP_PASSWORD:?Set APP_PASSWORD environment variable}"
#
# agent-browser open "$LOGIN_URL"
# agent-browser wait --load networkidle
# agent-browser snapshot -i
#
# # Fill credentials (update refs to match your form)
# agent-browser fill @e1 "$APP_USERNAME"
# agent-browser fill @e2 "$APP_PASSWORD"
# agent-browser click @e3
# agent-browser wait --url "**/dashboard"
# agent-browser snapshot -i
#
# FINAL_URL="$(agent-browser get url)"
# if is_login_like_url "$FINAL_URL"; then
#     echo "Login failed - still on login/auth page"
#     agent-browser screenshot /tmp/login-failed.png
#     agent-browser close
#     exit 1
# fi
#
# echo "Saving explicit state to $STATE_FILE"
# agent-browser state save "$STATE_FILE"
# echo "Login successful"
# echo "Future shortcut: agent-browser --state $STATE_FILE open https://app.example.com/dashboard"
