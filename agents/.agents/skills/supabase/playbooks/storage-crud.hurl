# Requires an existing disposable bucket and an authenticated disposable user.
# Bucket creation and removal are intentionally outside this client-level flow.

POST {{SUPABASE_URL}}/storage/v1/object/{{BUCKET_NAME}}/verification/hello.txt
Content-Type: text/plain
apikey: {{SUPABASE_ANON_KEY}}
Authorization: Bearer {{SUPABASE_ACCESS_TOKEN}}
```
Hello from Hurl!
```
HTTP 200
[Asserts]
jsonpath "$.Key" exists

POST {{SUPABASE_URL}}/storage/v1/object/list/{{BUCKET_NAME}}
Content-Type: application/json
apikey: {{SUPABASE_ANON_KEY}}
Authorization: Bearer {{SUPABASE_ACCESS_TOKEN}}
{
  "prefix": "verification",
  "limit": 100
}
HTTP 200
[Asserts]
jsonpath "$[*].name" includes "hello.txt"

POST {{SUPABASE_URL}}/storage/v1/object/sign/{{BUCKET_NAME}}/verification/hello.txt
Content-Type: application/json
apikey: {{SUPABASE_ANON_KEY}}
Authorization: Bearer {{SUPABASE_ACCESS_TOKEN}}
{
  "expiresIn": 60
}
HTTP 200
[Asserts]
jsonpath "$.signedURL" exists

DELETE {{SUPABASE_URL}}/storage/v1/object/{{BUCKET_NAME}}
Content-Type: application/json
apikey: {{SUPABASE_ANON_KEY}}
Authorization: Bearer {{SUPABASE_ACCESS_TOKEN}}
{
  "prefixes": ["verification/hello.txt"]
}
HTTP 200
