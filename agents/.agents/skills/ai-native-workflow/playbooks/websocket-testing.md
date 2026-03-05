# Playbook: WebSocket Testing

**Goal:** Test WebSocket-based real-time features without writing language-specific tests. Use CLI tools to connect, send messages, and verify responses interactively.

**Core Principle:** *WebSockets are bidirectional and stateful.* Unlike HTTP, the connection stays open. Test both the connection lifecycle and message exchange patterns.

---

## 1. Introduction: When to Use WebSocket Testing

WebSocket testing is essential when your application uses real-time, bidirectional communication:

- **Chat applications** — sending and receiving messages in real-time
- **Live notifications** — server-pushed alerts or updates
- **Collaborative editing** — sync state across multiple clients
- **Real-time dashboards** — live data streams (stock prices, IoT sensors)
- **Gaming** — low-latency client-server communication

**AI-Native Approach:** Use CLI tools (`wscat`, `websocat`) to interact with WebSocket endpoints directly. This mirrors how users/browsers interact with your real-time features.

---

## 2. Tools: CLI WebSocket Clients

Install the primary tools for WebSocket testing:

```bash
# wscat - Node.js based, widely used
npm install -g wscat

# websocat - Rust-based, feature-rich (recommended for advanced patterns)
# macOS
brew install websocat

# Linux
cargo install websocat
```

**Tool Comparison:**

| Tool | Strength | Best For |
|------|----------|----------|
| `wscat` | Simple, Node.js ecosystem | Basic connect/send/receive |
| `websocat` | Advanced piping, SSL, stdin/stdout | Bash integration, complex scripts |
| `curl` | Built-in (via `curl -N`) | Simple one-liners |

---

## 3. Basic Connection: Connecting to a WebSocket Endpoint

### Action: Connect to a Local WebSocket Server

```bash
# Connect to a WebSocket endpoint (ws:// or wss:// for secure)
wscat -c ws://localhost:8080/ws

# Connect with a subprotocol (if required)
wscat -c ws://localhost:8080/ws --subprotocol "graphql-ws"
```

### Action: Using websocat for Advanced Connections

```bash
# Basic connection
websocat ws://localhost:8080/ws

# Connect via SSL/TLS
websocat wss://secure.example.com/socket

# Connect and print only incoming messages (quiet mode)
websocat -q ws://localhost:8080/ws
```

### Action: Quick Connection Test with curl

For a simple connection verification (no message exchange):

```bash
# curl can upgrade to WebSocket but is limited for interaction
curl -N \
  -H "Connection: Upgrade" \
  -H "Upgrade: websocket" \
  -H "Sec-WebSocket-Version: 13" \
  -H "Sec-WebSocket-Key: $(echo -n 'randomkey' | base64)" \
  ws://localhost:8080/ws
```

---

## 4. Sending and Receiving Messages

### Action: Interactive Message Exchange with wscat

Once connected, type messages directly or use pipe input:

```bash
# Connect and send a single message via stdin
echo '{"type": "ping"}' | wscat -c ws://localhost:8080/ws

# Connect and send multiple messages (one per line)
printf '%s\n' '{"action": "subscribe", "channel": "updates"}' '{"action": "getLatest"}' | wscat -c ws://localhost:8080/ws
```

### Action: Using websocat with File Input

```bash
# Send messages from a file (one JSON per line)
websocat ws://localhost:8080/ws < messages.jsonl

# Bidirectional: send from file, capture responses to file
websocat ws://localhost:8080/ws < requests.jsonl > responses.jsonl
```

### Action: Expecting Responses with Timeout

Use `timeout` or `websocat` features to wait for responses:

```bash
# Wait up to 5 seconds for a response after sending
{ echo '{"type": "getData"}'; sleep 5; } | wscat -c ws://localhost:8080/ws

# With websocat: timeout after no activity
websocat --timeout 5 ws://localhost:8080/ws
```

---

## 5. Authentication: Handling WebSocket Auth

WebSocket authentication differs from HTTP — tokens typically go in query parameters or headers.

### Action: Auth via Query Parameters

```bash
# Token in query string
wscat -c "ws://localhost:8080/ws?token=eyJhbGciOiJIUzI1NiIs..."

# Multiple auth params
wscat -c "ws://localhost:8080/ws?token=xxx&clientId=agent-001"
```

### Action: Auth via Headers (wscat limitation)

`wscat` does not support custom headers directly. Use `websocat` instead:

```bash
# Send custom headers for authentication
websocat -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIs..." ws://localhost:8080/ws

# Multiple headers
websocat \
  -H "Authorization: Bearer token123" \
  -H "X-Client-ID: test-agent" \
  ws://localhost:8080/ws
```

### Action: GraphQL-WS Protocol Auth

For GraphQL subscriptions using `graphql-ws` protocol:

```bash
# Connect and send connection_init with auth
wscat -c ws://localhost:4000/graphql --subprotocol graphql-ws
# Then send: {"type":"connection_init","payload":{"authToken":"..."}}
```

---

## 6. Testing Patterns

### Pattern 1: Connection Open/Close Verification

**Action: Verify Connection Lifecycle**

```bash
# Connect and immediately disconnect (verify no errors)
timeout 2 wscat -c ws://localhost:8080/ws || echo "Connection closed gracefully"

# Check connection closes properly (code 1000 = normal closure)
websocat ws://localhost:8080/ws &
WEBSOCKET_PID=$!
sleep 2
kill $WEBSOCKET_PID
wait $WEBSOCKET_PID 2>/dev/null && echo "Clean close"
```

### Pattern 2: Message Exchange

**Action: Request-Response Pattern**

```bash
# Send request, capture response
REQUEST='{"id":"1","type":"getUser","payload":{"userId":42}}'
RESPONSE=$(echo "$REQUEST" | wscat -c ws://localhost:8080/ws 2>/dev/null)
echo "$RESPONSE" | jq .
```

**Action: Subscribe to Ongoing Updates**

```bash
# Subscribe to a channel, then listen for multiple messages
{
  echo '{"type":"subscribe","channel":"notifications"}'
  sleep 10
} | wscat -c ws://localhost:8080/ws
```

### Pattern 3: Error Handling

**Action: Test Invalid Message Handling**

```bash
# Send malformed JSON
echo 'not valid json' | wscat -c ws://localhost:8080/ws

# Send valid JSON but invalid schema
echo '{"type":"unknownAction","data":{}}' | wscat -c ws://localhost:8080/ws

# Verify error response format
ERROR_RESPONSE=$(echo '{"type":"bad"}' | wscat -c ws://localhost:8080/ws 2>&1)
echo "$ERROR_RESPONSE" | jq -r '.error' 2>/dev/null || echo "No error field"
```

### Pattern 4: Real-Time Updates Verification

**Action: Verify Server-Push Updates**

```bash
# Subscribe and wait for server-initiated messages
{
  echo '{"type":"subscribe","channel":"stock-AAPL"}'
  # Keep connection open to receive updates
  sleep 15
} | wscat -c ws://localhost:8080/ws 2>/dev/null | head -n 5
```

---

## 7. Integration with Bash Pipelines

WebSocket tools integrate naturally with bash for complex testing scenarios.

### Action: Sending and Parsing Responses

```bash
# Send request, parse response with jq
RESPONSE=$(echo '{"type":"getItems"}' | wscat -c ws://localhost:8080/ws 2>/dev/null)
echo "$RESPONSE" | jq -r '.payload.items[] | .name'
```

### Action: Waiting for Asynchronous Events

```bash
# Poll for a specific condition in WebSocket messages
for i in {1..10}; do
  MESSAGES=$(wscat -c ws://localhost:8080/ws 2>/dev/null)
  if echo "$MESSAGES" | jq -e '.type == "update"' > /dev/null; then
    echo "Update received!"
    break
  fi
  sleep 2
done
```

### Action: Using websocat with External Process

```bash
# Process each incoming message through jq
websocat ws://localhost:8080/ws | jq -r '.payload.message'
```

---

## 8. Real-World Examples

### Example 1: Chat Application Testing

```bash
# Join a chat room and send a message
{
  echo '{"type":"join","room":"general"}'
  sleep 1
  echo '{"type":"message","content":"Hello from test agent","room":"general"}'
  sleep 2
} | wscat -c ws://localhost:8080/chat
```

### Example 2: Notification System Verification

```bash
# Subscribe to notifications, verify delivery
{
  echo '{"action":"subscribe","channel":"alerts"}'
  # Server should push notifications here
  sleep 5
} | wscat -c "ws://localhost:8080/notifications?token=$TOKEN" | \
  jq 'select(.type == "alert")'
```

### Example 3: Real-Time Data Stream (Stock Prices)

```bash
# Subscribe to price updates, capture first 3 updates
{
  echo '{"symbol":"AAPL","action":"subscribe"}'
  sleep 8
} | wscat -c ws://localhost:8080/stream | head -n 3 | jq .
```

### Example 4: Collaborative Editing Sync

```bash
# Join a document session and verify sync messages
{
  echo '{"type":"join","docId":"doc-123","userId":"agent"}'
  sleep 1
  echo '{"type":"edit","docId":"doc-123","ops":[{"insert":"test"}]}'
  sleep 2
} | wscat -c ws://localhost:8080/collab | jq '.type, .ops'
```

### Example 5: Authentication Flow

```bash
# Full auth flow: connect, authenticate, verify token
{
  echo '{"type":"auth","token":"invalid-token"}'
  sleep 1
  echo '{"type":"auth","token":"valid-token-123"}'
  sleep 1
} | wscat -c ws://localhost:8080/ws 2>&1 | jq '.type, .status'
```

---

## Quick Reference

```bash
# Install tools
npm install -g wscat
brew install websocat

# Basic connect
wscat -c ws://localhost:8080/ws

# Send message
echo '{"type":"ping"}' | wscat -c ws://localhost:8080/ws

# With auth header
websocat -H "Authorization: Bearer token" ws://localhost:8080/ws

# Listen for updates
websocat ws://localhost:8080/ws | jq .

# Send and save response
echo '{"type":"getData"}' | wscat -c ws://localhost:8080/ws > response.json
```
