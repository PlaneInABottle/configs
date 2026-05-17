#!/usr/bin/env bash
# verify-storage.sh — Test Supabase Storage operations end-to-end
#
# Usage:
#   SUPABASE_URL=https://xxxx.supabase.co SUPABASE_ANON_KEY=ey... ./verify-storage.sh
#
# Tests: create bucket → upload → list → signed URL → download → delete → remove bucket
# Exits 0 on all-pass, 1 on any failure.
set -euo pipefail

# ── Colors ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; NC='\033[0m'
pass() { echo -e "  ${GREEN}✓${NC} $1"; }
fail() { echo -e "  ${RED}✗${NC} $1"; exit 1; }

# ── Validate inputs ─────────────────────────────────────────────────────────
[[ -n "${SUPABASE_URL:-}" ]] || { echo "ERROR: SUPABASE_URL not set" >&2; exit 1; }
[[ -n "${SUPABASE_ANON_KEY:-}" ]] || { echo "ERROR: SUPABASE_ANON_KEY not set" >&2; exit 1; }

URL="${SUPABASE_URL%/}"
AUTH="Authorization: Bearer ${SUPABASE_ANON_KEY}"
APIKEY="apikey: ${SUPABASE_ANON_KEY}"
BUCKET="verify-test-$(date +%s)"
FILE_PATH="test/hello-world.txt"
FILE_CONTENT="Hello Supabase Storage! $(date)"
TEMP_FILE=$(mktemp)
trap 'rm -f "$TEMP_FILE"' EXIT

echo "Supabase Storage Verification"
echo "  URL:    ${URL}"
echo "  Bucket: ${BUCKET}"
echo ""

# ── 1. Create bucket ────────────────────────────────────────────────────────
echo "1. Creating bucket..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X POST \
  "${URL}/storage/v1/bucket" \
  -H "${AUTH}" \
  -H "${APIKEY}" \
  -H "Content-Type: application/json" \
  -d "{\"name\":\"${BUCKET}\",\"public\":false}")
[[ "$HTTP_CODE" =~ ^2 ]] && pass "Bucket created (HTTP ${HTTP_CODE})" || fail "Bucket create failed (HTTP ${HTTP_CODE})"

# ── 2. Upload file ──────────────────────────────────────────────────────────
echo "2. Uploading file..."
echo -n "$FILE_CONTENT" > "$TEMP_FILE"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X POST \
  "${URL}/storage/v1/object/${BUCKET}/${FILE_PATH}" \
  -H "${AUTH}" \
  -H "${APIKEY}" \
  -H "Content-Type: text/plain" \
  --data-binary @"${TEMP_FILE}")
[[ "$HTTP_CODE" =~ ^2 ]] && pass "File uploaded (HTTP ${HTTP_CODE})" || fail "Upload failed (HTTP ${HTTP_CODE})"

# ── 3. List files ───────────────────────────────────────────────────────────
echo "3. Listing files..."
LIST=$(curl -s -X POST \
  "${URL}/storage/v1/object/list/${BUCKET}" \
  -H "${AUTH}" \
  -H "${APIKEY}" \
  -H "Content-Type: application/json" \
  -d '{"prefix":"","limit":100}')
echo "$LIST" | jq -e '.[] | select(.name == "test/hello-world.txt")' > /dev/null 2>&1 \
  && pass "File found in listing" || fail "File not found in listing"

# ── 4. Create signed URL ────────────────────────────────────────────────────
echo "4. Creating signed URL..."
SIGNED=$(curl -s -X POST \
  "${URL}/storage/v1/object/sign/${BUCKET}/${FILE_PATH}" \
  -H "${AUTH}" \
  -H "${APIKEY}" \
  -H "Content-Type: application/json" \
  -d '{"expiresIn":60}')
SIGNED_URL=$(echo "$SIGNED" | jq -r '.signedURL // .signedUrl // empty')
[[ -n "$SIGNED_URL" ]] && pass "Signed URL obtained" || fail "Signed URL not returned"

# ── 5. Download via signed URL ──────────────────────────────────────────────
echo "5. Downloading via signed URL..."
if [[ "$SIGNED_URL" == https://* ]]; then
  DOWNLOADED=$(curl -s "$SIGNED_URL")
elif [[ "$SIGNED_URL" == /* ]]; then
  DOWNLOADED=$(curl -s "${URL}${SIGNED_URL}")
else
  DOWNLOADED=$(curl -s "${URL}/${SIGNED_URL}")
fi
[[ "$DOWNLOADED" == "$FILE_CONTENT" ]] \
  && pass "Downloaded content matches" || fail "Download content mismatch"

# ── 6. Delete file ──────────────────────────────────────────────────────────
echo "6. Deleting file..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X DELETE \
  "${URL}/storage/v1/object/${BUCKET}" \
  -H "${AUTH}" \
  -H "${APIKEY}" \
  -H "Content-Type: application/json" \
  -d "{\"prefixes\":[\"${FILE_PATH}\"]}")
[[ "$HTTP_CODE" =~ ^2 ]] && pass "File deleted (HTTP ${HTTP_CODE})" || fail "Delete failed (HTTP ${HTTP_CODE})"

# ── 7. Remove bucket ────────────────────────────────────────────────────────
echo "7. Removing bucket..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X DELETE \
  "${URL}/storage/v1/bucket/${BUCKET}" \
  -H "${AUTH}" \
  -H "${APIKEY}")
[[ "$HTTP_CODE" =~ ^2 ]] && pass "Bucket removed (HTTP ${HTTP_CODE})" || fail "Bucket remove failed (HTTP ${HTTP_CODE})"

echo ""
echo "${GREEN}All storage operations verified successfully.${NC}"
