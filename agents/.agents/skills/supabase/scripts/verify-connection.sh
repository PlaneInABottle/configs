#!/usr/bin/env bash
# verify-connection.sh — Test Supabase connectivity
#
# Usage:
#   SUPABASE_URL=https://xxxx.supabase.co SUPABASE_ANON_KEY=ey... ./verify-connection.sh
#
# Exits 0 on success, 1 on failure.

set -euo pipefail

# ── Validate inputs ──────────────────────────────────────────────────────────
if [[ -z "${SUPABASE_URL:-}" ]]; then
  echo "ERROR: SUPABASE_URL is not set." >&2
  echo "Usage: SUPABASE_URL=https://<ref>.supabase.co SUPABASE_ANON_KEY=ey... $0" >&2
  exit 1
fi

if [[ -z "${SUPABASE_ANON_KEY:-}" ]]; then
  echo "ERROR: SUPABASE_ANON_KEY is not set." >&2
  exit 1
fi

# Strip trailing slash from URL
SUPABASE_URL="${SUPABASE_URL%/}"

# ── Hit the health endpoint ──────────────────────────────────────────────────
HEALTH_URL="${SUPABASE_URL}/rest/v1/?select=1"

echo "Testing Supabase connection..."
echo "  URL:  ${SUPABASE_URL}"
echo ""

HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -H "Authorization: Bearer ${SUPABASE_ANON_KEY}" \
  --max-time 10 \
  "${HEALTH_URL}")

# ── Evaluate result ──────────────────────────────────────────────────────────
if [[ "${HTTP_CODE}" -ge 200 && "${HTTP_CODE}" -lt 300 ]]; then
  echo "Connected! (HTTP ${HTTP_CODE})"
  exit 0
else
  echo "Connection failed. (HTTP ${HTTP_CODE})" >&2
  echo "" >&2
  echo "Troubleshooting:" >&2
  echo "  - Verify SUPABASE_URL matches your project dashboard URL." >&2
  echo "  - Verify SUPABASE_ANON_KEY is the anon/public key from Settings → API." >&2
  echo "  - Check that your project is not paused in the Supabase dashboard." >&2
  echo "  - Check firewall or network restrictions." >&2
  exit 1
fi
