#!/usr/bin/env bash
# Verify upload, listing, signed download, and cleanup in an existing disposable bucket.
set -euo pipefail

for tool in curl jq; do
  command -v "$tool" >/dev/null || { printf 'ERROR: %s is required\n' "$tool" >&2; exit 1; }
done

: "${SUPABASE_URL:?Set SUPABASE_URL}"
: "${SUPABASE_ANON_KEY:?Set SUPABASE_ANON_KEY or publishable key}"
: "${SUPABASE_ACCESS_TOKEN:?Set an authenticated disposable user access token}"
: "${SUPABASE_TEST_BUCKET:?Set an existing disposable bucket name}"

url="${SUPABASE_URL%/}"
bucket="$SUPABASE_TEST_BUCKET"
object_path="verification/$(date +%s)-$$.txt"
content="Supabase storage verification $(date -u +%Y-%m-%dT%H:%M:%SZ)"
temp_file="$(mktemp)"

cleanup() {
  rm -f "$temp_file"
  curl -fsS -X DELETE "${url}/storage/v1/object/${bucket}" \
    -H "apikey: ${SUPABASE_ANON_KEY}" \
    -H "Authorization: Bearer ${SUPABASE_ACCESS_TOKEN}" \
    -H 'Content-Type: application/json' \
    -d "{\"prefixes\":[\"${object_path}\"]}" >/dev/null 2>&1 || true
}
trap cleanup EXIT
printf '%s' "$content" > "$temp_file"

curl -fsS -X POST "${url}/storage/v1/object/${bucket}/${object_path}" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -H "Authorization: Bearer ${SUPABASE_ACCESS_TOKEN}" \
  -H 'Content-Type: text/plain' \
  --data-binary "@${temp_file}" >/dev/null

listing="$(curl -fsS -X POST "${url}/storage/v1/object/list/${bucket}" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -H "Authorization: Bearer ${SUPABASE_ACCESS_TOKEN}" \
  -H 'Content-Type: application/json' \
  -d '{"prefix":"verification","limit":100}')"
object_name="${object_path#verification/}"
jq -e --arg name "$object_name" '.[] | select(.name == $name)' <<<"$listing" >/dev/null

signed="$(curl -fsS -X POST "${url}/storage/v1/object/sign/${bucket}/${object_path}" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -H "Authorization: Bearer ${SUPABASE_ACCESS_TOKEN}" \
  -H 'Content-Type: application/json' \
  -d '{"expiresIn":60}')"
signed_path="$(jq -er '.signedURL // .signedUrl' <<<"$signed")"
if [[ "$signed_path" == http://* || "$signed_path" == https://* ]]; then
  download_url="$signed_path"
elif [[ "$signed_path" == /storage/v1/* ]]; then
  download_url="${url}${signed_path}"
elif [[ "$signed_path" == /object/* ]]; then
  download_url="${url}/storage/v1${signed_path}"
else
  download_url="${url}/storage/v1/${signed_path}"
fi

downloaded="$(curl -fsS "$download_url")"
[[ "$downloaded" == "$content" ]] || { printf 'ERROR: downloaded content mismatch\n' >&2; exit 1; }

printf 'Storage verification passed for bucket %s and object %s\n' "$bucket" "$object_path"
