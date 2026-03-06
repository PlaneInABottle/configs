---
name: agent-browser
description: Browser automation CLI for AI agents. Use when the user needs to interact with websites, including navigating pages, filling forms, clicking buttons, taking screenshots, extracting data, testing web apps, or automating any browser task. Triggers include requests to "open a website", "fill out a form", "click a button", "take a screenshot", "scrape data from a page", "test this web app", "login to a site", "verify frontend features after implementation", "check if features work correctly", "automate browser actions", or any task requiring programmatic web interaction.
allowed-tools: Bash(agent-browser:*)
---

# Browser Automation with `agent-browser`

Use `agent-browser` as an interactive browser REPL: open a page, inspect it with `snapshot -i`, interact using refs, then re-snapshot whenever the DOM changes.

## Quick Start

```bash
agent-browser open https://example.com/login
agent-browser snapshot -i
# Output: @e1 [input type="email"], @e2 [input type="password"], @e3 [button] "Sign in"

agent-browser fill @e1 "user@example.com"
agent-browser fill @e2 "password123"
agent-browser click @e3
agent-browser wait --url "**/dashboard"
agent-browser snapshot -i
```

## Core Workflow

1. **Open** the target page with `agent-browser open <url>`.
2. **Inspect** with `agent-browser snapshot -i`.
3. **Interact** using refs like `@e1`, `@e2`, `@e3`.
4. **Wait** for navigation, async data, or UI transitions.
5. **Re-snapshot** after any DOM or page change.

## Essential Commands

```bash
# Navigation
agent-browser open <url>
agent-browser close

# Inspect
agent-browser snapshot -i
agent-browser snapshot -s "#main"

# Interact
agent-browser click @e1
agent-browser fill @e2 "text"
agent-browser type @e2 "text"
agent-browser select @e3 "option"
agent-browser check @e4
agent-browser press Enter

# Wait and verify
agent-browser wait @e1
agent-browser wait --url "**/dashboard"
agent-browser wait --load networkidle
agent-browser get text @e1
agent-browser get url
agent-browser screenshot
```

## Non-Negotiable Guardrails

- Always run `snapshot -i` before interacting with a page.
- Never guess refs from memory; use the current snapshot output.
- Re-snapshot after navigation, modal opens, async mutations, or any DOM change.
- Prefer refs over handwritten selectors for day-to-day interaction.
- In headed/manual flows, re-snapshot after the human finishes interacting.

## Choose the Right Persistence Mode

| If you need... | Use | Why |
|---|---|---|
| Separate live browser contexts | `--session <name>` | Isolates the active browser session |
| Persist a full browser profile directory | `--profile <path>` | Reuses browser-level profile data for long-lived or manual flows |
| Persist named browser state across restarts | `--session-name <name>` | CLI-managed named persistence |
| Save state to a specific file | `state save` / `state load` | Explicit, portable persistence |
| Load a saved file during startup | `--state <path>` | Shortcut for known-good state files |

Quick examples:

```bash
# Isolated active session
agent-browser --session qa open https://example.com

# Reuse a persistent browser profile directory
agent-browser --profile ~/.agent-browser/profiles/billing open https://app.example.com/login

# CLI-managed persistent named state
agent-browser --session-name billing open https://app.example.com/login
agent-browser close
agent-browser --session-name billing open https://app.example.com/dashboard

# Explicit file-based persistence
agent-browser state save ./auth-state.json
agent-browser --state ./auth-state.json open https://app.example.com/dashboard
```

Choose `--profile <path>` when you need a durable browser profile directory for repeated manual debugging or browser-level state. Choose `--session-name <name>` when local help's CLI-managed persistence for cookies and `localStorage` fits your case; this skill locally re-confirmed save-on-close, and you should verify restore behavior on your installed version if it matters. Choose `state save/load` or `--state <path>` when you need an explicit JSON artifact you can name, inspect, or move.

Read [references/session-management.md](references/session-management.md) before making assumptions about `close`, persistence paths, encryption, or cleanup.

## Authentication and Manual Debugging

Use the browser normally for auth flows, but choose persistence intentionally.

```bash
agent-browser open https://app.example.com/login
agent-browser snapshot -i
agent-browser fill @e1 "$APP_USERNAME"
agent-browser fill @e2 "$APP_PASSWORD"
agent-browser click @e3
agent-browser wait --url "**/dashboard"
```

For manual verification or 2FA:

```bash
agent-browser --headed open https://app.example.com/login
agent-browser snapshot -i
```

`--headed` only makes the browser visible. It does **not** replace `--session-name` or `state save/load`.

## Useful Alternatives

### Semantic locators

When refs are unavailable or a page is changing rapidly:

```bash
agent-browser find text "Sign In" click
agent-browser find label "Email" fill "user@example.com"
agent-browser find role button click --name "Submit"
```

### JavaScript evaluation

Use `eval --stdin` or `eval -b` for complex scripts so the shell does not corrupt the JavaScript.

```bash
agent-browser eval --stdin <<'EVALEOF'
JSON.stringify(Array.from(document.querySelectorAll('a')).map(a => a.href))
EVALEOF
```

## Read This Next

| Need | Read |
|---|---|
| Common command syntax plus the locally re-checked flags used in this skill | [references/commands.md](references/commands.md) |
| `--session` vs `--profile` vs `--session-name` vs `--state` vs `state save/load` | [references/session-management.md](references/session-management.md) |
| Login flows, OAuth, 2FA, reusable auth state | [references/authentication.md](references/authentication.md) |
| Ref invalidation and documented scoped snapshots | [references/snapshot-refs.md](references/snapshot-refs.md) |
| Headed debugging, recording, traces | [references/video-recording.md](references/video-recording.md) and [references/session-management.md](references/session-management.md) |
| Proxy usage and TLS/proxy troubleshooting | [references/proxy-support.md](references/proxy-support.md) |

## Templates and Starter Scripts

| Template | Purpose |
|---|---|
| [templates/form-automation.sh](templates/form-automation.sh) | Guided form filling workflow |
| [templates/authenticated-session.sh](templates/authenticated-session.sh) | Discovery-first auth scaffold; customize refs, then save and reuse state |
| [templates/capture-workflow.sh](templates/capture-workflow.sh) | Capture text and screenshots |

```bash
./templates/form-automation.sh https://example.com/form
./templates/authenticated-session.sh https://app.example.com/login
./templates/capture-workflow.sh https://example.com ./output
```
