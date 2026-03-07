# Mailpit API queries

## Preflight and availability

Use a configurable base URL and keep examples override-friendly:

```bash
MAILPIT_BASE_URL="${MAILPIT_BASE_URL:-http://localhost:8025}"
```

Confirm the service before triggering mail flows:

```bash
curl -fsS "$MAILPIT_BASE_URL/api/v1/info" | jq .
```

If that fails, stop and report the missing, unreachable, or auth-protected service. Treat localhost examples as defaults to verify in the current run, not facts to assume.

Use basic auth only when the local instance requires it:

```bash
curl -fsS -u "$MAILPIT_USER:$MAILPIT_PASSWORD" \
  "$MAILPIT_BASE_URL/api/v1/info" | jq .
```

If your installed Mailpit version exposes `/api/v1/info`, use it as a lightweight availability check. When the local service is configured with basic auth, include credentials on API requests.

## Inbox state and message selection

List messages newest-first:

```bash
curl -fsS "$MAILPIT_BASE_URL/api/v1/messages?limit=20" | jq .
```

Search by recipient, subject, or attachment presence:

```bash
curl -fsS "$MAILPIT_BASE_URL/api/v1/search?query=to:\"user@example.com\"" | jq .
curl -fsS "$MAILPIT_BASE_URL/api/v1/search?query=subject:\"Reset your password\"" | jq .
curl -fsS "$MAILPIT_BASE_URL/api/v1/search?query=has:attachment" | jq .
```

Common Mailpit search filters include `to:`, `from:`, `subject:`, `has:attachment`, `has:inline`, `is:read`, `before:`, and `after:`. Confirm supported filters on the installed version if a query behaves differently.

Delete all messages only when the test needs a clean inbox:

```bash
curl -fsS -X DELETE "$MAILPIT_BASE_URL/api/v1/messages"
```

Delete only a matching slice when broad cleanup would hide parallel activity:

```bash
curl -fsS -X DELETE \
  "$MAILPIT_BASE_URL/api/v1/search?query=to:\"user@example.com\""
```
