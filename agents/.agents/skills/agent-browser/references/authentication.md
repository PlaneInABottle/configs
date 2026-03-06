# Authentication Patterns

Login flows, auth-state reuse, OAuth, and manual verification patterns.

**Related**: [session-management.md](session-management.md) for persistence semantics, [commands.md](commands.md) for exact syntax, [SKILL.md](../SKILL.md) for quick start.

## Contents

- [Basic Login Flow](#basic-login-flow)
- [Reuse Auth with Explicit State Files](#reuse-auth-with-explicit-state-files)
- [Reuse Auth with --session-name](#reuse-auth-with---session-name)
- [OAuth and SSO Flows](#oauth-and-sso-flows)
- [Two-Factor Authentication](#two-factor-authentication)
- [HTTP Basic Auth](#http-basic-auth)
- [Cookie-Based Auth](#cookie-based-auth)
- [Token Refresh Handling](#token-refresh-handling)
- [Security Best Practices](#security-best-practices)

## Basic Login Flow

```bash
agent-browser open https://app.example.com/login
agent-browser wait --load networkidle
agent-browser snapshot -i

agent-browser fill @e1 "$APP_USERNAME"
agent-browser fill @e2 "$APP_PASSWORD"
agent-browser click @e3
agent-browser wait --url "**/dashboard"
agent-browser snapshot -i
```

Keep auth examples focused on the login flow itself. Pick persistence separately using [session-management.md](session-management.md).

## Reuse Auth with Explicit State Files

Use explicit state files when you want a named artifact and controlled save/load steps.

```bash
# Authenticate once
agent-browser open https://app.example.com/login
agent-browser snapshot -i
agent-browser fill @e1 "$APP_USERNAME"
agent-browser fill @e2 "$APP_PASSWORD"
agent-browser click @e3
agent-browser wait --url "**/dashboard"
agent-browser state save ./auth-state.json

# Reuse later
agent-browser state load ./auth-state.json
agent-browser open https://app.example.com/dashboard
```

Shortcut form when you already trust the file:

```bash
agent-browser --state ./auth-state.json open https://app.example.com/dashboard
```

## Reuse Auth with `--session-name`

Use `--session-name` when you want CLI-managed named persistence without manually saving a file after each run. Use `--profile <path>` instead when you need a durable browser profile directory, or `state save/load` when you need an explicit reusable file artifact.

```bash
agent-browser --session-name myapp open https://app.example.com/login
# ... complete login ...
agent-browser close

agent-browser --session-name myapp open https://app.example.com/dashboard
```

Local validation re-confirmed save-on-close in this mode. For restore semantics and version-sensitive caveats, read [session-management.md](session-management.md).

## OAuth and SSO Flows

```bash
agent-browser open https://app.example.com/auth/google
agent-browser wait --url "**accounts.google.com**"
agent-browser snapshot -i

agent-browser fill @e1 "$GOOGLE_USERNAME"
agent-browser click @e2
agent-browser wait 2000
agent-browser snapshot -i
agent-browser fill @e3 "$GOOGLE_PASSWORD"
agent-browser click @e4

agent-browser wait --url "**app.example.com**"
agent-browser state save ./oauth-state.json
```

Expect redirects, intermediate consent screens, and provider-owned DOM changes. Re-snapshot after each step that changes the page.

## Two-Factor Authentication

Use `--headed` when a human must finish a step that automation cannot safely complete.

```bash
agent-browser --headed open https://app.example.com/login
agent-browser snapshot -i
agent-browser fill @e1 "$APP_USERNAME"
agent-browser fill @e2 "$APP_PASSWORD"
agent-browser click @e3

echo "Complete 2FA in the visible browser window..."
agent-browser wait --url "**/dashboard"
agent-browser snapshot -i
agent-browser state save ./2fa-state.json
```

After any manual interaction in a visible browser, re-snapshot before continuing. If your installed `agent-browser wait --help` documents a timeout form you want to use for long manual steps, re-check that syntax locally before adding it.

## HTTP Basic Auth

```bash
agent-browser set credentials username password
agent-browser open https://protected.example.com/api
```

## Cookie-Based Auth

```bash
agent-browser cookies set session_token "abc123xyz" --url https://app.example.com/dashboard
agent-browser open https://app.example.com/dashboard
```

If you omit `--url`, `--domain`, and `--path`, `agent-browser` uses the current page URL. That means you must either provide those options explicitly or open the target origin before setting cookies.

## Token Refresh Handling

```bash
#!/bin/bash
set -euo pipefail

STATE_FILE="./auth-state.json"

if [[ -f "$STATE_FILE" ]]; then
    agent-browser --state "$STATE_FILE" open https://app.example.com/dashboard
    CURRENT_URL=$(agent-browser get url)

    if [[ "$CURRENT_URL" == *"/login"* ]] || [[ "$CURRENT_URL" == *"/signin"* ]]; then
        echo "Saved session expired; re-authenticating..."
        agent-browser close || true
    else
        agent-browser snapshot -i
        exit 0
    fi
fi

agent-browser open https://app.example.com/login
agent-browser snapshot -i
agent-browser fill @e1 "$APP_USERNAME"
agent-browser fill @e2 "$APP_PASSWORD"
agent-browser click @e3
agent-browser wait --url "**/dashboard"
agent-browser state save "$STATE_FILE"
agent-browser snapshot -i
```

## Security Best Practices

1. **Never commit auth state files**
   ```bash
   printf "auth-state.json\noauth-state.json\n2fa-state.json\n" >> .gitignore
   ```
2. **Use environment variables for credentials**
   ```bash
   export APP_USERNAME='user@example.com'
   export APP_PASSWORD='super-secret'
   ```
3. **Delete explicit state files when no longer needed**
   ```bash
   rm -f ./auth-state.json ./oauth-state.json ./2fa-state.json
   ```
4. **Scope CI guidance correctly**
   ```bash
   # If you do not use --session-name, --profile, or state save, close ends the in-memory session only
   agent-browser open https://app.example.com/login
   # ... login and perform checks ...
   agent-browser close
   ```
5. **Use persistent modes intentionally**
   - `--session-name` for CLI-managed persisted state; this skill locally re-confirmed save-on-close, and restore behavior should be verified locally when it matters
   - `--profile <path>` for a durable browser profile directory that persists browser-level state across runs
   - `state save/load` or `--state` for explicit reusable files
