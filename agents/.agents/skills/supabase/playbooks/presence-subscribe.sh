#!/usr/bin/env bash
# presence-subscribe.sh — Verify Supabase Realtime Presence via WebSocket
#
# Usage:
#   CHANNEL="room-lobby" \
#   SUPABASE_URL="wss://<project>.supabase.co" \
#   SUPABASE_ANON_KEY="ey..." \
#   ./presence-subscribe.sh
#
# Connects to a Realtime channel, tracks presence, and verifies the
# presence state update arrives. Times out after 10 seconds.
#
# Requires: wscat (npm install -g wscat)
set -euo pipefail

CHANNEL="${CHANNEL:-room-lobby}"
WS_URL="${SUPABASE_URL}/realtime/v1/websocket"
AUTH_PAYLOAD=$(cat <<EOF
{
  "type": "access_token",
  "token": "${SUPABASE_ANON_KEY}"
}
EOF
)

SUBSCRIBE_PAYLOAD=$(cat <<EOF
{
  "type": "subscribe",
  "channel": "${CHANNEL}",
  "config": {
    "broadcast": { "ack": true },
    "presence": { "key": "user-id" }
  }
}
EOF
)

TRACK_PAYLOAD=$(cat <<EOF
{
  "type": "presence",
  "event": "track",
  "channel": "${CHANNEL}",
  "payload": {
    "user_id": "test-user-123",
    "online_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  }
}
EOF
)

PRESENCE_GET_PAYLOAD=$(cat <<EOF
{
  "type": "presence",
  "event": "presence_get",
  "channel": "${CHANNEL}"
}
EOF
)

echo "Connecting to ${WS_URL} ..."
echo "Channel: ${CHANNEL}"
echo ""

# Use a temporary file as IPC mechanism
TMP_OUT=$(mktemp)
trap 'rm -f "$TMP_OUT"' EXIT

# Open WebSocket, authenticate, subscribe, track, then read presence state
{
  # Step 1: Authenticate
  echo "${AUTH_PAYLOAD}"
  sleep 0.3

  # Step 2: Subscribe to channel
  echo "${SUBSCRIBE_PAYLOAD}"
  sleep 0.5

  # Step 3: Track presence
  echo "${TRACK_PAYLOAD}"
  sleep 0.5

  # Step 4: Get presence state
  echo "${PRESENCE_GET_PAYLOAD}"
  sleep 1
} | timeout 10 wscat -c "${WS_URL}" 2>/dev/null | tee "$TMP_OUT"

echo ""
# Verify we got presence state back
if grep -q "presence_state" "$TMP_OUT" 2>/dev/null; then
  echo "✓ Presence state received successfully"
  # Extract and show the presence data
  grep "presence_state" "$TMP_OUT" | python3 -m json.tool 2>/dev/null || true
  exit 0
else
  echo "✗ Presence state NOT received"
  echo "Check that the Realtime server is reachable and the channel is valid."
  exit 1
fi
