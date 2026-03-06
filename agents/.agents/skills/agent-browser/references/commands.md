# Command Reference

Reference for commonly used `agent-browser` syntax that was re-checked against local help during this update. Keep `SKILL.md` for quick start, and use `agent-browser <command> --help` to confirm less-common options on your installed version.

**Related**: [session-management.md](session-management.md) for persistence semantics, [snapshot-refs.md](snapshot-refs.md) for ref lifecycle, [SKILL.md](../SKILL.md) for quick start.

## Contents

- [Style Note](#style-note)
- [Navigation](#navigation)
- [Snapshot](#snapshot)
- [Interactions](#interactions)
- [Get Information](#get-information)
- [Check State](#check-state)
- [Capture Output](#capture-output)
- [Wait](#wait)
- [JavaScript Evaluation](#javascript-evaluation)
- [Semantic Locators](#semantic-locators)
- [Cookies](#cookies)
- [State and Session Commands](#state-and-session-commands)
- [Browser Settings](#browser-settings)
- [Debugging](#debugging)
- [Global Options](#global-options)
- [Environment Variables](#environment-variables)

## Style Note

Examples in this file place global options before the command for consistency:

```bash
agent-browser --session qa snapshot -i
```

## Navigation

```bash
agent-browser open <url>      # Navigate to URL (aliases: goto, navigate)
                              # Supports: https://, http://, file://, about:, data://
                              # Auto-prepends https:// if no protocol given
agent-browser back            # Go back
agent-browser forward         # Go forward
agent-browser reload          # Reload page
agent-browser close           # Close browser (aliases: quit, exit)
agent-browser connect 9222    # Connect to browser via CDP port
```

## Snapshot

```bash
agent-browser snapshot             # Full accessibility tree
agent-browser snapshot -i          # Interactive elements only (recommended)
agent-browser snapshot -c          # Compact output
agent-browser snapshot -d 3        # Limit depth to 3
agent-browser snapshot -s "#main"  # Scope to CSS selector
```

Use `snapshot -i` before interacting. Re-run it after navigation, modals, async loads, or any DOM change that could invalidate refs.

Prefer `snapshot -s "#selector"` for documented scoped snapshots. Some versions may accept `snapshot @eN`, but this update did not re-confirm ref-scoped narrowing behavior.

## Interactions

```bash
agent-browser click @e1           # Click
agent-browser dblclick @e1        # Double-click
agent-browser focus @e1           # Focus element
agent-browser fill @e2 "text"     # Clear and type
agent-browser type @e2 "text"     # Type without clearing
agent-browser press Enter         # Press key (alias: key)
agent-browser press Control+a     # Key combination
agent-browser keydown Shift       # Hold key down
agent-browser keyup Shift         # Release key
agent-browser hover @e1           # Hover
agent-browser check @e1           # Check checkbox
agent-browser uncheck @e1         # Uncheck checkbox
agent-browser select @e1 "value"  # Select dropdown option
agent-browser select @e1 "a" "b"  # Select multiple options
agent-browser scroll down 500     # Scroll page (default: down 300px)
agent-browser scrollintoview @e1  # Scroll element into view (alias: scrollinto)
agent-browser drag @e1 @e2        # Drag and drop
agent-browser upload @e1 file.pdf # Upload files
```

## Get Information

```bash
agent-browser get text @e1        # Get element text
agent-browser get html @e1        # Get innerHTML
agent-browser get value @e1       # Get input value
agent-browser get attr @e1 href   # Get attribute
agent-browser get title           # Get page title
agent-browser get url             # Get current URL
agent-browser get count ".item"   # Count matching elements
agent-browser get box @e1         # Get bounding box
agent-browser get styles @e1      # Get computed styles
```

## Check State

```bash
agent-browser is visible @e1      # Check if visible
agent-browser is enabled @e1      # Check if enabled
agent-browser is checked @e1      # Check if checked
```

## Capture Output

```bash
agent-browser screenshot          # Save to a temporary directory
agent-browser screenshot path.png # Save to a specific path
agent-browser screenshot --full   # Full-page screenshot
agent-browser pdf output.pdf      # Save as PDF

agent-browser record start ./demo.webm    # Start recording
agent-browser record stop                 # Stop and save video
agent-browser record restart ./take2.webm # Stop current + start new
```

## Wait

```bash
agent-browser wait @e1                     # Wait for element
agent-browser wait 2000                    # Wait milliseconds
agent-browser wait --text "Success"        # Wait for text
agent-browser wait --url "**/dashboard"    # Wait for URL pattern
agent-browser wait --load networkidle      # Wait for network idle
agent-browser wait --fn "window.ready"     # Wait for JS condition
agent-browser wait --download ./file.pdf   # Wait for download and save it
agent-browser wait --download ./file.pdf --timeout 30000
```

Local `wait --help` re-confirmed the forms above. In local help, `--timeout <ms>` is shown with `--download`; if you want to combine `--timeout` with other wait forms used elsewhere in this skill, re-check `agent-browser wait --help` on your installed version first.

## JavaScript Evaluation

```bash
agent-browser eval "document.title"                 # Evaluate inline JavaScript
agent-browser eval -b "ZG9jdW1lbnQudGl0bGU="        # Evaluate base64-encoded JavaScript
agent-browser eval --stdin <<'EVALEOF'              # Read JavaScript from stdin
document.title
EVALEOF
```

Local `eval --help` re-confirmed `-b`, `--base64`, and `--stdin`.

## Semantic Locators

```bash
agent-browser find role button click --name "Submit"
agent-browser find text "Sign In" click
agent-browser find text "Sign In" click --exact
agent-browser find label "Email" fill "user@test.com"
agent-browser find placeholder "Search" type "query"
agent-browser find alt "Logo" click
agent-browser find title "Close" click
agent-browser find testid "submit-btn" click
agent-browser find first ".item" click
agent-browser find last ".item" click
agent-browser find nth 2 "a" hover
```

Use refs when possible; use semantic locators when refs are unavailable or the page is highly dynamic.

## Cookies

```bash
agent-browser cookies get
agent-browser cookies set session_id "abc123" --url https://app.example.com
agent-browser cookies set auth_token "xyz789" --domain example.com --path /api --httpOnly --secure
agent-browser cookies set pref "dark" --sameSite Lax --expires 1767225600
agent-browser cookies clear
```

Local `cookies --help` re-confirmed these operations:

- `get`
- `set <name> <value> [options]`
- `clear`

Local help also states: if `--url`, `--domain`, and `--path` are all omitted, the cookie is set for the current page URL.

## State and Session Commands

```bash
agent-browser session                    # Show current session name
agent-browser session list               # List active sessions

agent-browser state save auth.json       # Save current state to a file
agent-browser state load auth.json       # Load state from a file
agent-browser state list                 # List saved state files
agent-browser state show myapp.json      # Show state summary
agent-browser state rename old new       # Rename state file
agent-browser state clear myapp          # Clear saved states for a name
agent-browser state clear --all          # Clear all saved states
agent-browser state clean --older-than 7 # Delete expired state files
```

Use these four persistence mechanisms intentionally:

- `--session <name>`: choose an isolated active browser session.
- `--profile <path>`: reuse a persistent browser profile directory.
- `--session-name <name>`: local help documents CLI-managed persisted state for cookies and `localStorage`; this update re-confirmed save-on-close, and restore behavior should be verified locally when it matters.
- `state save` / `state load`: explicit file-based persistence.
- `--state <path>`: load a state file up front before the command runs.

For behavior details, persistence paths, cleanup, and close semantics, read [session-management.md](session-management.md).

## Browser Settings

```bash
agent-browser set viewport 1920 1080          # Set viewport size
agent-browser set device "iPhone 14"          # Emulate device
agent-browser set geo 37.7749 -122.4194       # Set geolocation (alias: geolocation)
agent-browser set offline on                  # Toggle offline mode
agent-browser set headers '{"X-Key":"v"}'     # Extra HTTP headers
agent-browser set credentials user pass       # HTTP basic auth (alias: auth)
agent-browser set media dark                  # Emulate color scheme
agent-browser set media light reduced-motion  # Multiple media settings
```

## Debugging

```bash
agent-browser --headed open example.com   # Show browser window for debugging
agent-browser --cdp 9222 snapshot         # Connect via a Chrome DevTools Protocol port
agent-browser highlight @e1               # Highlight element
agent-browser console                     # View console messages
agent-browser console --clear             # Clear console messages
agent-browser errors                      # View page errors
agent-browser errors --clear              # Clear page errors
agent-browser trace start                 # Start recording a trace
agent-browser trace stop trace.zip        # Stop trace and save it
```

Use `--headed` only to make the browser visible. It does not replace explicit persistence decisions; use `--session-name` or `state save/load` when you need state to survive restarts.

## Global Options

```bash
agent-browser --session <name> ...           # Use an isolated active session
agent-browser --profile <path> ...           # Use a persistent browser profile directory
agent-browser --session-name <name> ...      # CLI-managed persisted state name for cookies and localStorage
agent-browser --state <path> ...             # Load storage state from JSON before running
agent-browser --json ...                     # Output as JSON
agent-browser --headed ...                   # Show browser window
agent-browser --full ...                     # Full-page screenshot shortcut
agent-browser --cdp <port> ...               # Connect via Chrome DevTools Protocol
agent-browser -p <provider> ...              # Browser provider (--provider)
agent-browser --proxy <url> ...              # Use a proxy server
agent-browser --headers <json> ...           # Extra HTTP headers
agent-browser --executable-path <path> ...   # Custom browser executable
agent-browser --extension <path> ...         # Load browser extension (repeatable)
agent-browser --ignore-https-errors ...      # Ignore SSL certificate errors
agent-browser --help                         # Show help
agent-browser --version                      # Show version
agent-browser <command> --help               # Show help for a command
```

## Environment Variables

Verified from local help:

```bash
AGENT_BROWSER_SESSION             # Default isolated session name
AGENT_BROWSER_SESSION_NAME        # Default CLI-managed persistence name
AGENT_BROWSER_ENCRYPTION_KEY      # 64-char hex key for AES-256-GCM state encryption
AGENT_BROWSER_STATE_EXPIRE_DAYS   # Auto-delete states older than N days (default: 30)
```
