---
name: websocket-testing
description: "Test WebSocket connections, message framing, reconnection patterns, and real-time communication. Use when testing real-time APIs, WebSocket endpoints, message brokers, or any bidirectional communication."
---

# WebSocket Testing

Test WebSocket connections, message handling, and real-time communication patterns.

## Quick Start

```bash
# Test WebSocket connection with wscat
wscat -c wss://api.example.com/ws

# Test with websocat
websocat wss://api.example.com/ws
```

## When to Use This Skill

- **Real-time APIs**: Testing WebSocket endpoints
- **Bidirectional Communication**: Message sending/receiving
- **Connection Lifecycle**: Connect, disconnect, reconnect
- **Message Protocols**: JSON, text, binary messages

## Tools

| Tool | Purpose |
|------|---------|
| wscat | CLI WebSocket client |
| websocat | Rust-based WebSocket tool |
| Python websockets | Programmatic testing |

## Core Workflow

### 1. Basic Connection Test

```bash
# Connect and verify
wscat -c wss://api.example.com/ws
# Connected (press ctrl-c to exit)
```

### 2. Message Testing

```bash
# Send message and expect response
echo '{"type":"ping"}' | websocat wss://api.example.com/ws
```

### 3. Python Test Script

```python
import asyncio
import websockets
import json

async def test_websocket():
    uri = "wss://api.example.com/ws"
    async with websockets.connect(uri) as ws:
        # Send message
        await ws.send(json.dumps({"type": "subscribe", "channel": "updates"}))
        
        # Receive response
        response = await ws.recv()
        data = json.loads(response)
        print(f"Received: {data}")
        
        # Assert response
        assert "type" in data
        print("Test passed!")

asyncio.run(test_websocket())
```

### 4. Connection Lifecycle

```python
import asyncio
import websockets

async def test_lifecycle():
    uri = "wss://api.example.com/ws"
    
    # Connect
    ws = await websockets.connect(uri)
    print("Connected")
    
    # Send/Receive
    await ws.send('{"action":"hello"}')
    response = await asyncio.wait_for(ws.recv(), timeout=5)
    print(f"Response: {response}")
    
    # Close
    await ws.close()
    print("Closed")

asyncio.run(test_lifecycle())
```

### 5. Reconnection Test

```python
import asyncio
import websockets

async def test_reconnect():
    uri = "wss://api.example.com/ws"
    
    for attempt in range(3):
        try:
            ws = await websockets.connect(uri, ping_interval=None)
            print(f"Attempt {attempt + 1}: Connected")
            await ws.close()
        except Exception as e:
            print(f"Attempt {attempt + 1}: Failed - {e}")
        
        await asyncio.sleep(1)

asyncio.run(test_reconnect())
```

## Advanced Patterns

### Authentication

```python
async def test_auth_websocket():
    uri = "wss://api.example.com/ws?token=YOUR_TOKEN"
    async with websockets.connect(uri) as ws:
        await ws.send('{"action":"auth"}')
        response = await ws.recv()
        data = json.loads(response)
        assert data.get("authenticated") == True

asyncio.run(test_auth_websocket())
```

### Ping/Pong

```python
async def test_ping_pong():
    uri = "wss://api.example.com/ws"
    async with websockets.connect(uri, ping_interval=5) as ws:
        # Server should respond to pings
        await asyncio.sleep(6)
        print("Ping/Pong working")

asyncio.run(test_ping_pong())
```

### Message Framing

```bash
# Send binary message
echo -n '{"data":"test"}' | websocat --binary wss://api.example.com/ws
```

### Subscribe/Unsubscribe

```python
async def test_subscribe():
    uri = "wss://api.example.com/ws"
    async with websockets.connect(uri) as ws:
        # Subscribe
        await ws.send(json.dumps({
            "action": "subscribe",
            "channels": ["events", "updates"]
        }))
        
        # Receive multiple messages
        for _ in range(5):
            msg = await asyncio.wait_for(ws.recv(), timeout=10)
            print(f"Received: {msg}")
        
        # Unsubscribe
        await ws.send(json.dumps({
            "action": "unsubscribe",
            "channels": ["events"]
        }))

asyncio.run(test_subscribe())
```

## Testing Strategy

| Test Type | What to Test |
|-----------|--------------|
| Connection | Connect, disconnect, error handling |
| Authentication | Token-based, headers, cookies |
| Messages | Send, receive, framing |
| Subscriptions | Subscribe, unsubscribe, events |
| Reconnection | Auto-reconnect, exponential backoff |
| Error Cases | Invalid messages, timeouts |

## Common Issues

- **Connection refused**: Server not running or wrong port
- **SSL errors**: Use `wss://` not `ws://` for TLS
- **Timeout**: Check firewall, add timeout to tests
- **Message order**: Use sequence numbers in messages

## References

- [websockets Python library](https://websockets.readthedocs.io/)
- [WebSocket Protocol](https://www.rfc-editor.org/rfc/rfc6455)

## See Also

- [async-worker-testing](./async-worker-testing) - Background job testing
- [agent-browser](./agent-browser) - Browser WebSocket testing