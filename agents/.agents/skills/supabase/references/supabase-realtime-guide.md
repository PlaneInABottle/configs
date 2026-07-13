# Supabase Realtime Guide

## Contents

- [Channel Basics](#channel-basics)
- [Broadcast](#broadcast)
- [Presence](#presence)
- [Private Channels](#private-channels)
- [RLS Policies for Realtime](#rls-policies-for-realtime)
- [Rooms / Users Schema](#rooms-users-schema)
- [REST API Broadcast](#rest-api-broadcast)
- [Broadcast Replay](#broadcast-replay)
- [postgres_changes](#postgres_changes)
- [References](#references)

- [Channel Basics](#channel-basics)
- [Broadcast](#broadcast)
- [Presence](#presence)
- [Private Channels](#private-channels)
- [RLS Policies for Realtime](#rls-policies-for-realtime)
- [Rooms / Users Schema](#rooms--users-schema)
- [REST API Broadcast](#rest-api-broadcast)
- [Broadcast Replay](#broadcast-replay)
- [postgres_changes](#postgres_changes)

---

## Channel Basics

Create a channel and subscribe. Channel names are arbitrary strings — use a convention like `room-<id>` or `topic:<scope>`.

```typescript
const channel = supabase.channel('room-1')

channel.subscribe((status, err) => {
  if (status === 'SUBSCRIBED') console.log('Connected')
  if (status === 'CHANNEL_ERROR') console.error('Error:', err)
  if (status === 'TIMED_OUT') console.log('Timed out')
  if (status === 'CLOSED') console.log('Closed')
})

// Cleanup
supabase.removeChannel(channel)
// or
await channel.unsubscribe()
supabase.removeChannel(channel)
```

Channel lifecycle:
1. `supabase.channel(name, opts?)` — create (does not connect yet)
2. `channel.subscribe(callback)` — initiate WebSocket connection
3. `channel.unsubscribe()` / `supabase.removeChannel(channel)` — disconnect and release

Always remove channels when leaving a screen or component to prevent memory leaks.

---

## Broadcast

Send and receive ephemeral messages between clients subscribed to the same channel.

```typescript
const channel = supabase.channel('room-1', {
  config: {
    broadcast: {
      ack: false,  // request acknowledgment (default: false)
      self: true,  // receive own messages (default: false)
    },
  },
})

// Listen for a specific event
channel.on('broadcast', { event: 'message_sent' }, (payload) => {
  console.log('Received:', payload)
  // payload: { type: 'broadcast', event: 'message_sent', payload: { text: 'Hello' } }
})

await channel.subscribe()

// Send a broadcast message
await channel.send({
  type: 'broadcast',
  event: 'message_sent',
  payload: { text: 'Hello' },
})
```

**Options:**

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `ack` | `boolean` | `false` | Wait for server acknowledgment before resolving `send()` |
| `self` | `boolean` | `false` | Deliver the message back to the sender |

---

## Presence

Track online users and their shared state across clients.

```typescript
const channel = supabase.channel('room-1', {
  config: {
    presence: {
      key: currentUserId, // unique per user (default: auto-generated UUID)
    },
  },
})

// React to presence state changes
channel
  .on('presence', { event: 'sync' }, () => {
    const state = channel.presenceState()
    // Map<key, { presences: Array<payload> }>
    // { 'user-uuid': [{ user_id: 'uuid', online_at: '...' }] }
    console.log('Current presences:', state)
  })
  .on('presence', { event: 'join' }, ({ newPresences }) => {
    console.log('Users joined:', newPresences)
  })
  .on('presence', { event: 'leave' }, ({ leftPresences }) => {
    console.log('Users left:', leftPresences)
  })
  .subscribe(async (status) => {
    if (status === 'SUBSCRIBED') {
      await channel.track({
        user_id: currentUserId,
        online_at: new Date().toISOString(),
        display_name: 'Alice',
      })
    }
  })

// Untrack (removes this client from presence state)
await channel.untrack()
```

**Events:**

| Event | Fires | Payload |
|-------|-------|---------|
| `sync` | Full state recomputed after any join/leave | — (read via `channel.presenceState()`) |
| `join` | One or more users appear | `{ newPresences: Array<payload> }` |
| `leave` | One or more users disappear | `{ leftPresences: Array<payload> }` |

---

## Private Channels

Private channels enforce Row Level Security (RLS) on every broadcast and presence operation. The connecting user's JWT is validated against database policies.

```typescript
const channel = supabase.channel('room-1', {
  config: { private: true },
})

// Subscribe — the Supabase client automatically passes the current
// session JWT. RLS policies on `realtime.messages` govern access.
channel.subscribe((status, err) => {
  if (status === 'SUBSCRIBED') console.log('Connected to private channel')
  if (status === 'CHANNEL_ERROR') console.error('RLS denied or auth error:', err)
})

// Broadcast and presence work identically on private channels
channel.on('broadcast', { event: 'message_sent' }, (payload) => {
  console.log('Private message:', payload)
})

await channel.send({
  type: 'broadcast',
  event: 'message_sent',
  payload: { text: 'Hello from private channel' },
})
```

### Custom JWT Tokens

To use a custom JWT (e.g., from a third-party auth provider), call `setAuth` before subscribing:

```typescript
// Set a custom JWT (preserved across removeChannel and resubscribe)
await supabase.realtime.setAuth('my-custom-jwt')

// Then subscribe with private: true
const channel = supabase.channel('room-1', {
  config: { private: true },
})
await channel.subscribe()
```

To switch back to the default session-based token, call `setAuth()` without arguments:

```typescript
await supabase.realtime.setAuth()
```

**Important:** The Supabase client automatically manages auth via the `accessToken` callback for standard email/OAuth flows. Use `setAuth(customJwt)` only when providing a token from a non-Supabase source.

---

## RLS Policies for Realtime

Private channels evaluate RLS policies on the `realtime.messages` table. Reads (subscription authorization) go through `FOR SELECT`, writes (broadcast send, presence track) go through `FOR INSERT`.

Use `realtime.topic()` inside policies to reference the channel name.

### Read (subscribe) policy

```sql
CREATE POLICY "read_broadcast_presence" ON "realtime"."messages"
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.rooms_users
      WHERE user_id = (select auth.uid())
        AND room_topic = realtime.topic()
        AND realtime.messages.extension IN ('broadcast', 'presence')
    )
  );
```

### Write (send / track) policy

```sql
CREATE POLICY "write_broadcast_presence" ON "realtime"."messages"
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.rooms_users
      WHERE user_id = (select auth.uid())
        AND room_topic = realtime.topic()
        AND realtime.messages.extension IN ('broadcast', 'presence')
    )
  );
```

**Key functions in Realtime policies:**

| Function | Purpose |
|----------|---------|
| `realtime.topic()` | Returns the channel topic name (e.g., `room-1`) |
| `auth.uid()` | Current authenticated user ID |
| `realtime.messages.extension` | Message type: `'broadcast'` or `'presence'` |

Policies apply only when `private: true` is set on the channel. Public channels skip RLS entirely.

---

## Rooms / Users Schema

The companion tables for channel authorization. Join `rooms_users` to `rooms` to map users to allowed channels.

```sql
-- Define available rooms/channels
CREATE TABLE public.rooms (
  id        bigint GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  topic     text NOT NULL UNIQUE
);

-- Map users to allowed rooms
CREATE TABLE public.rooms_users (
  user_id     uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  room_topic  text REFERENCES public.rooms(topic) ON DELETE CASCADE,
  created_at  timestamptz DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id, room_topic)
);

-- Enable RLS on both tables
ALTER TABLE public.rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.rooms_users ENABLE ROW LEVEL SECURITY;

-- Grant users access to a room
INSERT INTO public.rooms (topic) VALUES ('room-1'), ('room-2');
INSERT INTO public.rooms_users (user_id, room_topic) VALUES
  ('<auth-user-uuid>', 'room-1'),
  ('<auth-user-uuid>', 'room-2');
```

### Admin policy example

```sql
-- Admins can manage rooms
CREATE POLICY "admin_rooms" ON public.rooms
  FOR ALL USING (
    (select auth.uid()) IN (
      SELECT user_id FROM public.rooms_users
      WHERE room_topic = 'admin'
    )
  );

-- Users can only see their own memberships
CREATE POLICY "select_own_rooms" ON public.rooms_users
  FOR SELECT USING (user_id = (select auth.uid()));

-- Admins can insert memberships
CREATE POLICY "admin_insert_rooms" ON public.rooms_users
  FOR INSERT WITH CHECK (
    (select auth.uid()) IN (
      SELECT user_id FROM public.rooms_users
      WHERE room_topic = 'admin'
    )
  );
```

---

## REST API Broadcast

Send broadcast messages from a server (or trusted client) via HTTP without a persistent WebSocket connection.

### Via the Realtime API endpoint

```typescript
await fetch(`https://<project>.supabase.co/rest/v1/rpc/broadcast`, {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'apikey': '<SERVICE_ROLE_KEY>',
    'Authorization': `Bearer <SERVICE_ROLE_KEY>`,
  },
  body: JSON.stringify({
    topic: 'room-1',
    event: 'message_sent',
    payload: { text: 'Server broadcast' },
    private: true,
  }),
})
```

### Via the Realtime HTTP endpoint (multiple messages)

```typescript
await fetch(`https://<project>.supabase.co/realtime/v1/api/broadcast`, {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'apikey': '<SERVICE_ROLE_KEY>',
  },
  body: JSON.stringify({
    messages: [
      {
        topic: 'room-1',
        event: 'message_sent',
        payload: { text: 'Hello room 1!' },
        private: true,
      },
    ],
  }),
})
```

The REST API approach is useful for:
- Server-to-client notifications (e.g., from a webhook handler)
- Scheduled / cron-based broadcasts
- Broadcasting when no WebSocket client is available

**Note:** For private channels, the REST API bypasses per-user RLS — the request authenticates with the service role key. Design your server-side flow accordingly.

---

## Broadcast Replay

Private channels can replay missed broadcast messages to newly connected clients. Messages published from the database (via `realtime.messages` INSERT) are eligible for replay.

```typescript
const channel = supabase.channel('room-1', {
  config: {
    private: true,
    broadcast: {
      replay: {
        since: Date.now() - 12 * 60 * 60 * 1000, // 12 hours ago
        limit: 25,                                  // max messages to replay
      },
    },
  },
})

channel.on('broadcast', { event: 'message_sent' }, (payload) => {
  if (payload?.meta?.replayed) {
    console.log('Historical message:', payload)
  } else {
    console.log('Live message:', payload)
  }
}).subscribe()
```

**Requirements:**
- Channel must be `private: true`
- `since` is an epoch timestamp (milliseconds)
- `limit` defaults to 25
- Only messages persisted via database INSERT are replayed (not in-memory ephemeral broadcasts)

---

## postgres_changes

Listen to database row changes on subscribed tables. Already covered in the main skill — brief reference here.

```typescript
const channel = supabase
  .channel('todos-changes')
  .on(
    'postgres_changes',
    {
      event: '*',                    // INSERT | UPDATE | DELETE | *
      schema: 'public',
      table: 'todos',
      filter: `user_id=eq.${userId}`,
    },
    (payload) => {
      console.log(payload.eventType, payload.new, payload.old)
    }
  )
  .subscribe()
```

Enable the table in the publication:

```sql
ALTER PUBLICATION supabase_realtime ADD TABLE todos;
```

See the main skill README or the [Supabase Realtime docs](https://supabase.com/docs/guides/realtime) for full `postgres_changes` coverage.

---

## References

- [Supabase Realtime docs](https://supabase.com/docs/guides/realtime)
- `scripts/verify-connection.sh` — Connection health check
