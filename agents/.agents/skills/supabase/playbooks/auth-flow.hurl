# Supabase Auth Flow Playbook
# Usage:
#   hurl --variable SUPABASE_URL=https://xxxx.supabase.co \
#         --variable SUPABASE_ANON_KEY=ey... \
#         --variable TEST_EMAIL=user@example.com \
#         --variable TEST_PASSWORD=secureP@ss123 \
#         auth-flow.hurl
#
# Tests: signup → resend confirmation → login → get user → logout

# ─── 1. Sign Up ─────────────────────────────────────────────────────────────
POST {{SUPABASE_URL}}/auth/v1/signup
Content-Type: application/json
apikey: {{SUPABASE_ANON_KEY}}
{
  "email": "{{TEST_EMAIL}}",
  "password": "{{TEST_PASSWORD}}",
  "data": { "full_name": "Test User" }
}
HTTP 200
[Asserts]
jsonpath "$.email" == "{{TEST_EMAIL}}"
jsonpath "$.aud" == "authenticated"

# ─── 2. Resend Confirmation (if email confirmation enabled) ────────────────
POST {{SUPABASE_URL}}/auth/v1/resend
Content-Type: application/json
apikey: {{SUPABASE_ANON_KEY}}
{
  "email": "{{TEST_EMAIL}}",
  "type": "signup"
}
HTTP 200

# ─── 3. Sign In with Password ──────────────────────────────────────────────
POST {{SUPABASE_URL}}/auth/v1/token?grant_type=password
Content-Type: application/json
apikey: {{SUPABASE_ANON_KEY}}
{
  "email": "{{TEST_EMAIL}}",
  "password": "{{TEST_PASSWORD}}"
}
HTTP 200
[Captures]
access_token: jsonpath "$.access_token"
refresh_token: jsonpath "$.refresh_token"
user_id: jsonpath "$.user.id"
[Asserts]
jsonpath "$.user.email" == "{{TEST_EMAIL}}"
jsonpath "$.token_type" == "bearer"

# ─── 4. Get User (authenticated) ──────────────────────────────────────────
GET {{SUPABASE_URL}}/auth/v1/user
apikey: {{SUPABASE_ANON_KEY}}
Authorization: Bearer {{access_token}}
HTTP 200
[Asserts]
jsonpath "$.id" == "{{user_id}}"
jsonpath "$.email" == "{{TEST_EMAIL}}"

# ─── 5. Refresh Token ──────────────────────────────────────────────────────
POST {{SUPABASE_URL}}/auth/v1/token?grant_type=refresh_token
Content-Type: application/json
apikey: {{SUPABASE_ANON_KEY}}
{
  "refresh_token": "{{refresh_token}}"
}
HTTP 200
[Asserts]
jsonpath "$.token_type" == "bearer"

# ─── 6. Sign Out (global) ──────────────────────────────────────────────────
POST {{SUPABASE_URL}}/auth/v1/logout
apikey: {{SUPABASE_ANON_KEY}}
Authorization: Bearer {{access_token}}
HTTP 204
