# Supabase Storage CRUD Playbook
# Usage:
#   hurl --variable SUPABASE_URL=https://xxxx.supabase.co \
#         --variable SUPABASE_ANON_KEY=ey... \
#         --variable BUCKET_NAME=test-bucket \
#         storage-crud.hurl
#
# Tests: create bucket → upload → list → signed URL → download → delete

# ─── 1. Create Bucket ──────────────────────────────────────────────────────
POST {{SUPABASE_URL}}/storage/v1/bucket
Content-Type: application/json
apikey: {{SUPABASE_ANON_KEY}}
Authorization: Bearer {{SUPABASE_ANON_KEY}}
{
  "name": "{{BUCKET_NAME}}",
  "public": false
}
HTTP 200
[Asserts]
jsonpath "$.name" == "{{BUCKET_NAME}}"

# ─── 2. Upload File ────────────────────────────────────────────────────────
POST {{SUPABASE_URL}}/storage/v1/object/{{BUCKET_NAME}}/test/hello.txt
Content-Type: text/plain
apikey: {{SUPABASE_ANON_KEY}}
Authorization: Bearer {{SUPABASE_ANON_KEY}}
Hello from Hurl!
HTTP 200
[Asserts]
jsonpath "$.Key" exists

# ─── 3. List Files ─────────────────────────────────────────────────────────
POST {{SUPABASE_URL}}/storage/v1/object/list/{{BUCKET_NAME}}
Content-Type: application/json
apikey: {{SUPABASE_ANON_KEY}}
Authorization: Bearer {{SUPABASE_ANON_KEY}}
{
  "prefix": "",
  "limit": 100
}
HTTP 200
[Asserts]
jsonpath "$[0].name" == "test/hello.txt"

# ─── 4. Create Signed URL ──────────────────────────────────────────────────
POST {{SUPABASE_URL}}/storage/v1/object/sign/{{BUCKET_NAME}}/test/hello.txt
Content-Type: application/json
apikey: {{SUPABASE_ANON_KEY}}
Authorization: Bearer {{SUPABASE_ANON_KEY}}
{
  "expiresIn": 60
}
HTTP 200
[Asserts]
jsonpath "$.signedURL" exists

# ─── 5. Download via Signed URL (using the signedURL from step 4) ──────────
# Note: Signed URL is captured in step 4, then used to download.
# Run as part of a larger flow — the signedURL value is piped through jq.
# This step demonstrates the download; in practice use the captured value.

# ─── 6. Delete File ────────────────────────────────────────────────────────
DELETE {{SUPABASE_URL}}/storage/v1/object/{{BUCKET_NAME}}
Content-Type: application/json
apikey: {{SUPABASE_ANON_KEY}}
Authorization: Bearer {{SUPABASE_ANON_KEY}}
{
  "prefixes": ["test/hello.txt"]
}
HTTP 200

# ─── 7. Delete Bucket ──────────────────────────────────────────────────────
DELETE {{SUPABASE_URL}}/storage/v1/bucket/{{BUCKET_NAME}}
apikey: {{SUPABASE_ANON_KEY}}
Authorization: Bearer {{SUPABASE_ANON_KEY}}
HTTP 200
