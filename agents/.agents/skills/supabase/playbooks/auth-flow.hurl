# Authentication verification for a pre-created, confirmed disposable user.
# Create and confirm the user through the project's normal test fixture or local
# inbox flow before running this file.

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

GET {{SUPABASE_URL}}/auth/v1/user
apikey: {{SUPABASE_ANON_KEY}}
Authorization: Bearer {{access_token}}
HTTP 200
[Asserts]
jsonpath "$.id" == "{{user_id}}"
jsonpath "$.email" == "{{TEST_EMAIL}}"

POST {{SUPABASE_URL}}/auth/v1/token?grant_type=refresh_token
Content-Type: application/json
apikey: {{SUPABASE_ANON_KEY}}
{
  "refresh_token": "{{refresh_token}}"
}
HTTP 200
[Captures]
refreshed_access_token: jsonpath "$.access_token"
[Asserts]
jsonpath "$.token_type" == "bearer"

POST {{SUPABASE_URL}}/auth/v1/logout
apikey: {{SUPABASE_ANON_KEY}}
Authorization: Bearer {{refreshed_access_token}}
HTTP 204
