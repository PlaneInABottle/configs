# Snapshot and Refs

Compact element references that keep browser interaction precise and token-efficient.

**Related**: [commands.md](commands.md) for syntax, [SKILL.md](../SKILL.md) for quick start.

## Contents

- [How Refs Work](#how-refs-work)
- [Taking Snapshots](#taking-snapshots)
- [Using Refs](#using-refs)
- [Ref Lifecycle](#ref-lifecycle)
- [Scoped Snapshots](#scoped-snapshots)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)

## How Refs Work

Traditional approach:

```text
Full DOM/HTML -> AI parses -> selector guess -> action
```

`agent-browser` approach:

```text
snapshot -> @refs assigned -> direct action
```

## Taking Snapshots

```bash
agent-browser snapshot
agent-browser snapshot -i
agent-browser snapshot -c
agent-browser snapshot -s "#main"
```

Use `snapshot -i` for most interactive work.

Example output:

```text
Page: Example Site - Home
URL: https://example.com

@e1 [header]
  @e2 [nav]
    @e3 [a] "Home"
    @e4 [a] "Products"
  @e5 [button] "Sign In"

@e6 [main]
  @e7 [form]
    @e8 [input type="email"] placeholder="Email"
    @e9 [input type="password"] placeholder="Password"
    @e10 [button type="submit"] "Log In"
```

## Using Refs

```bash
agent-browser click @e5
agent-browser fill @e8 "user@example.com"
agent-browser fill @e9 "password123"
agent-browser click @e10
```

## Ref Lifecycle

Refs are disposable. Refs from an older snapshot can point at the wrong thing after the page changes.

```bash
agent-browser snapshot -i
# @e1 [button] "Next"

agent-browser click @e1
agent-browser wait --load networkidle
agent-browser snapshot -i
# @e1 may now be a different element
```

Re-snapshot after:
- navigation
- form submit
- opening a dialog or dropdown
- async rendering or filtering
- manual interaction in a headed browser

## Scoped Snapshots

Use a smaller snapshot when the full page is noisy.

```bash
agent-browser snapshot -s "form"
```

Some versions may accept `snapshot @eN`, but this update did not re-confirm that ref-scoped snapshots reliably narrow the output. Prefer `snapshot -s` in shared or portable workflows.

## Best Practices

1. Snapshot before the first interaction.
2. Re-snapshot after every meaningful DOM change.
3. Prefer refs over guessed selectors.
4. Use scoped snapshots to cut noise on large pages.
5. If a ref stops working, assume the page changed and snapshot again.

## Troubleshooting

### "Ref not found"

```bash
agent-browser snapshot -i
```

### Element not visible yet

```bash
agent-browser wait 1000
agent-browser snapshot -i
```

### Too many elements in the output

```bash
agent-browser snapshot -s "main"
agent-browser get text @e7
```
