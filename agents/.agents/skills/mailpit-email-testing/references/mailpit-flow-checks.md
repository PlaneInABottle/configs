# Mailpit flow checks

## Flow-specific checks

Prefer targeted queries over `latest` shortcuts when multiple emails may arrive close together.

Signup confirmation:

```bash
curl -fsS \
  "$MAILPIT_BASE_URL/api/v1/search?query=to:\"new.user@example.com\" subject:\"Confirm your account\"" \
  | jq .
```

Password reset:

```bash
curl -fsS \
  "$MAILPIT_BASE_URL/api/v1/search?query=to:\"user@example.com\" subject:\"Reset your password\"" \
  | jq .
```

Invite flow:

```bash
curl -fsS \
  "$MAILPIT_BASE_URL/api/v1/search?query=to:\"invitee@example.com\" subject:\"You have been invited\"" \
  | jq .
```

Use `latest` only when the mailbox is already isolated for that test:

```bash
curl -fsS "$MAILPIT_BASE_URL/api/v1/message/latest" | jq .
curl -fsS "$MAILPIT_BASE_URL/view/latest.txt"
curl -fsS "$MAILPIT_BASE_URL/view/latest.html"
```

## Body, links, and attachments

Fetch message metadata, then inspect the rendered part or raw source that best matches the assertion:

```bash
MESSAGE_ID="replace-with-message-id"
curl -fsS "$MAILPIT_BASE_URL/api/v1/message/$MESSAGE_ID" | jq .
curl -fsS "$MAILPIT_BASE_URL/api/v1/message/$MESSAGE_ID/headers" | jq .
curl -fsS "$MAILPIT_BASE_URL/api/v1/message/$MESSAGE_ID/raw"
curl -fsS "$MAILPIT_BASE_URL/view/$MESSAGE_ID.txt"
curl -fsS "$MAILPIT_BASE_URL/view/$MESSAGE_ID.html"
```

Extract a verification URL or token from text first when possible:

```bash
curl -fsS "$MAILPIT_BASE_URL/view/$MESSAGE_ID.txt" \
  | rg -o 'https?://[^ ]+'

curl -fsS "$MAILPIT_BASE_URL/view/$MESSAGE_ID.txt" \
  | rg -o '[A-Z0-9]{6,}'
```

Use HTML only when the email has no text alternative or you need markup-level checks:

```bash
curl -fsS "$MAILPIT_BASE_URL/view/$MESSAGE_ID.html" \
  | rg 'Reset your password|Accept invite|Confirm account'
```

Attachment presence can be checked from message metadata before downloading binaries. If the metadata is not obvious on your installed version, inspect the JSON once with `jq .` and adapt from there:

```bash
curl -fsS "$MAILPIT_BASE_URL/api/v1/message/$MESSAGE_ID" | jq .
```

Download a specific attachment part only when needed:

```bash
PART_ID="replace-with-part-id"
curl -fsS "$MAILPIT_BASE_URL/api/v1/message/$MESSAGE_ID/part/$PART_ID" -o attachment.bin
test -s attachment.bin
```

## Polling and failure handling

Use bounded polling instead of fixed sleeps:

```bash
for attempt in 1 2 3 4 5 6 7 8 9 10; do
  result="$(curl -fsS \
    "$MAILPIT_BASE_URL/api/v1/search?query=to:\"user@example.com\" subject:\"Reset your password\"")" || exit 1
  echo "$result" | jq .
  echo "$result" | rg 'Reset your password' && break
  sleep 1
done
```

Keep waits short, print the last observed mailbox state on timeout, and stop rather than widening the polling window indefinitely.

When Mailpit is absent, auth-protected, or replaced by another inbox tool:

- Report what you actually verified locally.
- Keep command patterns generic and configurable.
- Reuse the same workflow: confirm service, isolate inbox if needed, trigger app action, search for the message, inspect body parts, and extract the link or token.
