# Playbook: API & Contract Testing

**Goal:** Verify API endpoints and state changes without writing language-specific tests (e.g., `pytest`, `Jest`). Treat the application as a black box and interact over HTTP.

## 1. Automated Contract Testing with Hurl

Use `.hurl` files to define declarative, language-agnostic API tests. 

### Action: Creating a Hurl Test
Create a `tests/api/` directory and write `.hurl` files.

```hurl
# tests/api/create_user.hurl
POST http://localhost:8000/api/users
Content-Type: application/json
{
  "name": "Agent User",
  "email": "agent@test.com"
}

# Assert the HTTP status code
HTTP 201

# Assert on the JSON response
[Asserts]
jsonpath "$.id" isInteger
jsonpath "$.status" == "pending"
```

### Action: Executing the Test
Run the tests via the CLI:
```bash
# Run a single test
hurl --test tests/api/create_user.hurl

# Run all tests in a directory with variables
hurl --test --variables-file .env.test tests/api/*.hurl
```

---

## 2. Iterative Bash Construction for Ad-Hoc Verification

When verifying side-effects (like checking if an email was caught by Mailpit) during active development, **do not write custom TypeScript or Python parsing scripts.** Instead, iteratively construct bash pipelines.

### Action: The Iterative Pipeline

**Always use `set -euo pipefail` and `curl -sSf` (silent, show-error, fail-fast) so network errors or 500s don't silently disappear down the bash pipe.**

**Step 1: Discover the shape of the data**
```bash
curl -sSf "http://localhost:8025/api/v1/search?query=to:test@example.com"
```

**Step 2: Wait for Asynchronous State (Polling)**
If the email is sent by a background worker, don't just run the curl once. Write a short bash loop to wait for the data (appending `|| true` to the curl command inside the loop so it doesn't break `set -e` on early failures):
```bash
for i in {1..5}; do
  MESSAGE_ID=$(curl -sSf "http://localhost:8025/api/v1/search?query=to:test@example.com" 2>/dev/null | jq -r '.messages[0].ID // empty' || true)
  if [ -n "$MESSAGE_ID" ]; then break; fi
  sleep 2
done
echo "Message ID: $MESSAGE_ID"
```

**Step 3: Chain commands to fetch nested data**
```bash
curl -sSf "http://localhost:8025/api/v1/message/${MESSAGE_ID}" | jq -r '.Text'
```

**Step 4: Extract the final value (e.g., a reset token)**
```bash
set -euo pipefail
curl -sSf "http://localhost:8025/api/v1/message/${MESSAGE_ID}" | jq -r '.Text' | grep -o 'token=[^&]*' | cut -d= -f2
```

**Why this is AI-Native:** You have a persistent shell. Testing standard outputs interactively is faster and less brittle than scaffolding test scripts for one-off verifications.
