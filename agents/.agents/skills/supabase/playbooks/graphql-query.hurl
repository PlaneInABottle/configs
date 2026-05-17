# Supabase GraphQL Playbook
# Usage:
#   hurl --variable SUPABASE_URL=https://xxxx.supabase.co \
#         --variable SUPABASE_ANON_KEY=ey... \
#         graphql-query.hurl
#
# Requires pg_graphql extension enabled.
# The schema is auto-generated from your Postgres tables.

POST {{SUPABASE_URL}}/graphql/v1
Content-Type: application/json
apiKey: {{SUPABASE_ANON_KEY}}
{
  "query": "{ __schema { types { name } } }"
}
HTTP 200
[Asserts]
jsonpath "$.data.__schema" exists

# ─── Query a table (replace "profileCollection" with your table) ───────────
# POST {{SUPABASE_URL}}/graphql/v1
# Content-Type: application/json
# apiKey: {{SUPABASE_ANON_KEY}}
# {
#   "query": "{ profileCollection(first: 10) { edges { node { id username } } } }"
# }
# HTTP 200
# [Asserts]
# jsonpath "$.data.profileCollection" exists
