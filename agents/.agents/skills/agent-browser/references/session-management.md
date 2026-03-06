# Session Management

Choose the right isolation and persistence mode for `agent-browser`.

**Related**: [commands.md](commands.md) for syntax, [authentication.md](authentication.md) for login flows, [SKILL.md](../SKILL.md) for quick start.

## Contents

- [Decision Matrix](#decision-matrix)
- [Active Session Isolation with --session](#active-session-isolation-with---session)
- [Persistent Named State with --session-name](#persistent-named-state-with---session-name)
- [Explicit State Files with state-save--load](#explicit-state-files-with-state-saveload)
- [Startup Shortcut with --state](#startup-shortcut-with---state)
- [Close and Persistence Semantics](#close-and-persistence-semantics)
- [Persistence Paths and Cleanup](#persistence-paths-and-cleanup)
- [Headed Debugging Guidance](#headed-debugging-guidance)
- [Common Patterns](#common-patterns)
- [Best Practices](#best-practices)

## Decision Matrix

| Need | Primary tool | What it does | What it does not do |
|---|---|---|---|
| Keep two active browser contexts separate right now | `--session <name>` | Selects an isolated active browser session | Does not itself document auto-persistence across restarts |
| Reuse a durable browser profile directory | `--profile <path>` | Persists browser-profile data in a directory you choose | Does not create a portable JSON state artifact for you |
| Persist named browser state across restarts | `--session-name <name>` | CLI-managed persisted state across restarts | Does not replace active-session selection semantics |
| Save state to a specific file you control | `state save <path>` / `state load <path>` | Explicit file-based persistence | Does not auto-save unless you run it |
| Load a saved state file before opening | `--state <path>` | Startup shortcut for loading a state file | Does not explain or manage the file lifecycle for you |

Use `--session` for *live isolation*. Use `--profile`, `--session-name`, or `state save/load` for *restart persistence*, depending on what kind of artifact you need.

## Active Session Isolation with `--session`

`--session <name>` chooses the active browser session for a command.

```bash
agent-browser --session auth open https://app.example.com/login
agent-browser --session public open https://example.com

agent-browser --session auth snapshot -i
agent-browser --session public get text body
```

Each isolated session has its own in-memory browser context, including cookies, storage, open tabs, and history.

When you omit `--session`, commands use the default active session.

```bash
agent-browser open https://example.com
agent-browser snapshot -i
agent-browser close
```

## Persistent Browser Profiles with `--profile`

`--profile <path>` points `agent-browser` at a browser profile directory that stays on disk.

```bash
agent-browser --profile ~/.agent-browser/profiles/myapp open https://app.example.com/login
# ... authenticate or debug manually ...
agent-browser close

agent-browser --profile ~/.agent-browser/profiles/myapp open https://app.example.com/dashboard
```

Choose this when you want a durable browser profile path for repeated manual work, browser-level settings, or debugging sessions tied to one machine. Prefer `--session-name` when CLI-managed cookies and `localStorage` persistence is enough. Prefer `state save/load` when you need an explicit JSON file you can name, inspect, or move between environments.

## Persistent Named State with `--session-name`

`--session-name <name>` is the CLI-managed named persistence path.

Local help describes it as auto-save/restore across restarts. During this update, local validation re-confirmed that:
- `agent-browser --session-name <name> ...` created a file under `~/.agent-browser/sessions/` on `close`
- the saved JSON contained the expected origin and `localStorage` entries

The same validation did **not** re-confirm `localStorage` restoration after reopen, so treat restore behavior as version-sensitive and verify locally if persisted storage is mission-critical.

```bash
agent-browser --session-name myapp open https://app.example.com/login
# ... authenticate ...
agent-browser close

agent-browser --session-name myapp open https://app.example.com/dashboard
```

Use this when you want CLI-managed saved state without manually handling JSON files or choosing a profile directory yourself.

## Explicit State Files with `state save` / `load`

Use explicit state files when you want a portable artifact, a checked path, or one-time reuse across environments.

```bash
agent-browser open https://app.example.com/login
agent-browser snapshot -i
# ... complete login ...
agent-browser state save ./auth-state.json

agent-browser state load ./auth-state.json
agent-browser open https://app.example.com/dashboard
```

`agent-browser state --help` describes these operations as managing browser state including cookies, `localStorage`, and `sessionStorage`.

Available state operations from local help:

```bash
agent-browser state save <path>
agent-browser state load <path>
agent-browser state list
agent-browser state show <filename>
agent-browser state rename <old-name> <new-name>
agent-browser state clear [session-name] [--all]
agent-browser state clean --older-than <days>
```

## Startup Shortcut with `--state`

`--state <path>` is the fast path when you want to load a state file as part of opening or another command.

```bash
agent-browser --state ./auth-state.json open https://app.example.com/dashboard
```

Prefer teaching `state save/load` first because it makes the persistence step explicit. Use `--state` when you already have a known-good JSON state file and want a shorter startup command.

## Close and Persistence Semantics

`agent-browser close --help` says only: “Closes the browser instance for the current session.”

That means persistence depends on the mode you chose before closing:

- With `--profile <path>`: browser-profile data remains in the directory you chose.
- With `--session-name <name>`: local validation re-confirmed save-on-close and the presence of saved storage data; if restore-on-reopen is critical, verify it on your installed version.
- With explicit `state save <path>`: only the state you already saved persists.
- With neither `--session-name` nor `state save`: `close` ends the current in-memory browser instance without creating a persisted state artifact.

This resolves the common confusion: `close` is not universally “persistent” or “non-persistent”; the outcome depends on whether you selected a persistence mechanism.

## Persistence Paths and Cleanup

### Named-session persistence path

Local validation re-confirmed that CLI-managed named-session files are stored under:

```text
~/.agent-browser/sessions/
```

Do **not** assume an exact filename template in shared docs. The filename format can vary by version or implementation details. Inspect the directory locally when you need the exact saved filename:

```bash
ls ~/.agent-browser/sessions
agent-browser state list
```

### Encryption and expiry

Local help documents these environment variables:

```bash
export AGENT_BROWSER_ENCRYPTION_KEY="$(openssl rand -hex 32)"
export AGENT_BROWSER_STATE_EXPIRE_DAYS=30
```

- `AGENT_BROWSER_ENCRYPTION_KEY` enables AES-256-GCM encryption for saved state.
- `AGENT_BROWSER_STATE_EXPIRE_DAYS` controls automatic cleanup age for saved states.

### Cleanup commands

```bash
agent-browser state list
agent-browser state show <filename-from-state-list>
agent-browser state clear myapp
agent-browser state clear --all
agent-browser state clean --older-than 7
```

## Headed Debugging Guidance

Use `--headed` to make the browser visible during debugging or manual steps such as 2FA:

```bash
agent-browser --headed open https://app.example.com/login
```

Keep these semantics separate:

- `--headed` controls visibility.
- `--session` controls active-session isolation.
- `--profile` controls a persistent browser profile directory.
- `--session-name` and `state save/load` control persistence.

No additional headed-mode daemon-reuse caveat was locally verified during this documentation update, so this file intentionally avoids stronger claims.

## Common Patterns

### Isolated parallel work

```bash
agent-browser --session site1 open https://site1.com
agent-browser --session site2 open https://site2.com

agent-browser --session site1 snapshot -i
agent-browser --session site2 snapshot -i
```

### Reopen with CLI-managed saved state

```bash
agent-browser --session-name billing open https://app.example.com/login
# ... authenticate once ...
agent-browser close

agent-browser --session-name billing open https://app.example.com/dashboard
```

### Explicit reusable state file

```bash
agent-browser open https://app.example.com/login
# ... authenticate ...
agent-browser state save ./billing-auth.json

agent-browser --state ./billing-auth.json open https://app.example.com/dashboard
```

### Persistent local browser profile

```bash
agent-browser --profile ~/.agent-browser/profiles/support-debug open https://app.example.com/login
# ... inspect, log in, or debug ...
agent-browser close

agent-browser --profile ~/.agent-browser/profiles/support-debug open https://app.example.com/dashboard
```

## Best Practices

1. Choose persistence deliberately instead of assuming `close` will do the right thing.
2. Use semantic session names such as `github-auth`, `checkout-smoke`, or `docs-scrape`.
3. Prefer `state save/load` when you need a portable artifact with an explicit path.
4. Prefer `--profile` when you need a durable local browser profile directory for repeated manual or machine-local work.
5. Prefer `--session-name` when you want CLI-managed named persistence without manual file handling.
6. Keep saved state files and profile directories out of version control because they can contain session tokens.
7. Re-snapshot after reopening or after any manual interaction in a headed browser.
