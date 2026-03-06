# Proxy Support

Proxy configuration for geo-testing, corporate networks, and scraping workflows.

**Related**: [commands.md](commands.md) for global options, [SKILL.md](../SKILL.md) for quick start.

## Contents

- [Preferred Pattern](#preferred-pattern)
- [Basic Proxy Configuration](#basic-proxy-configuration)
- [Authenticated Proxy](#authenticated-proxy)
- [Common Use Cases](#common-use-cases)
- [Verifying Proxy Connection](#verifying-proxy-connection)
- [Troubleshooting](#troubleshooting)
- [Best Practices](#best-practices)

## Preferred Pattern

Local CLI help exposes the global `--proxy <url>` option, so this file uses that as the primary documented pattern.

```bash
agent-browser --proxy http://proxy.example.com:8080 open https://example.com
```

If your environment also depends on shell-level proxy environment variables, verify that behavior locally before standardizing on it.

## Basic Proxy Configuration

```bash
agent-browser --proxy http://proxy.example.com:8080 open https://example.com
agent-browser --proxy https://proxy.example.com:8080 open https://example.com
```

## Authenticated Proxy

```bash
agent-browser --proxy http://username:password@proxy.example.com:8080 open https://example.com
```

## Common Use Cases

### Geo-testing

```bash
agent-browser --proxy http://us-proxy.example.com:8080 open https://example.com
agent-browser screenshot ./us.png
agent-browser close

agent-browser --proxy http://eu-proxy.example.com:8080 open https://example.com
agent-browser screenshot ./eu.png
agent-browser close
```

### Rotating proxies for scraping

```bash
#!/bin/bash
set -euo pipefail

PROXIES=(
  "http://proxy1.example.com:8080"
  "http://proxy2.example.com:8080"
  "http://proxy3.example.com:8080"
)

URLS=(
  "https://site.com/page1"
  "https://site.com/page2"
  "https://site.com/page3"
)

for i in "${!URLS[@]}"; do
  proxy_index=$((i % ${#PROXIES[@]}))
  agent-browser --proxy "${PROXIES[$proxy_index]}" open "${URLS[$i]}"
  agent-browser get text body > "output-$i.txt"
  agent-browser close
  sleep 1
done
```

### Corporate access via a fixed proxy

```bash
agent-browser --proxy http://corpproxy.company.com:8080 open https://external-vendor.com
agent-browser --proxy http://corpproxy.company.com:8080 open https://status.vendor.com
```

## Verifying Proxy Connection

```bash
agent-browser --proxy http://proxy.example.com:8080 open https://httpbin.org/ip
agent-browser get text body
```

The reported IP should match the proxy egress, not your local machine.

## Troubleshooting

### Proxy connection failed

```bash
curl -x http://proxy.example.com:8080 https://httpbin.org/ip
agent-browser --proxy http://proxy.example.com:8080 open https://example.com
```

### TLS inspection or certificate errors

Some corporate proxies intercept TLS. For temporary debugging only:

```bash
agent-browser --proxy http://proxy.example.com:8080 --ignore-https-errors open https://example.com
```

### Slow performance

- Use a proxy only for the requests that actually need it.
- Reuse the same proxy long enough to complete a single flow before rotating.
- Capture screenshots or `get text body` output early so a flaky proxy does not force a full rerun.

## Best Practices

1. Prefer the documented `--proxy` flag in shared examples.
2. Keep credentials out of committed scripts when possible.
3. Verify a proxy with a simple page before running a long workflow.
4. Treat `--ignore-https-errors` as a debugging escape hatch, not a default.
5. When comparing regions, save screenshots or text output immediately after load.
