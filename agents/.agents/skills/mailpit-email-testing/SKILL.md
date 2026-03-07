---
name: mailpit-email-testing
description: "Verify email-delivery and email-content flows against Mailpit or another locally confirmed inbox capture service. Use when checking signup, password reset, invite, magic-link, or notification emails; locating captured messages; extracting links or tokens; asserting text/HTML content or attachments; or polling a confirmed local inbox conservatively during development or end-to-end verification."
---

# Mailpit Email Testing

Verify captured-email flows against a local inbox capture service without assuming a specific project setup.

## Run local preflight checks

- Verify the inbox capture base URL from project config or environment before using examples; do not assume `http://localhost:8025` unless you have confirmed it locally.
- Check reachability first with a simple HTTP request such as `curl -fsS "$MAILPIT_BASE_URL/api/v1/info"`.
- Prefer API-based assertions over scraping the Mailpit UI.
- If Mailpit is absent, unreachable, or protected by auth you do not have, stop and report that state instead of inventing setup details.

## Follow a mailbox verification workflow

1. Start from an isolated mailbox state only when the email check needs it.
2. Trigger the signup, reset, invite, or other mail-producing app action.
3. Poll conservatively for the expected message instead of sleeping blindly.
4. Select the target message by recipient, subject, or search query.
5. Extract the verification link, OTP, or token from text, HTML, or raw content.
6. Assert the subject, recipients, body content, and attachment presence needed for that email flow.
7. Load [references/mailpit-api-queries.md](references/mailpit-api-queries.md) for availability, search, and cleanup commands.
8. Load [references/mailpit-flow-checks.md](references/mailpit-flow-checks.md) for signup/reset/invite recipes, token extraction, and polling patterns.

## Keep the skill conservative and inbox-scoped

- Use Mailpit-specific endpoints only when you have confirmed Mailpit is the service in use; otherwise adapt the same workflow to the local inbox tool that is actually present.
- Treat localhost URLs and unauthenticated examples as defaults to verify in the current environment, not durable repository facts.
- Prefer stable text, recipient, and URL assertions over brittle full-HTML snapshots.
- Keep polling loops short and bounded; surface timeout context instead of retrying indefinitely.
