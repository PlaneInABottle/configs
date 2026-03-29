# Supabase Push Trigger Reference

## Edge Function: Send Expo Push

```ts
// supabase/functions/send-push/index.ts
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const EXPO_PUSH_URL = "https://exp.host/--/api/v2/push/send";

Deno.serve(async (req) => {
  const { record } = await req.json();

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
  );

  const { data: tokens, error } = await supabase
    .from("push_tokens").select("token, platform")
    .eq("user_id", record.user_id);

  if (error || !tokens?.length) return new Response("No tokens", { status: 200 });

  const messages = tokens.map((t) => ({
    to: t.token, sound: "default",
    title: record.title, body: record.body,
    data: record.data ?? {},
    badge: record.badge ?? undefined,
    channelId: record.channel_id ?? undefined,
  }));

  // Send in batches of 100
  for (let i = 0; i < messages.length; i += 100) {
    const batch = messages.slice(i, i + 100);
    const res = await fetch(EXPO_PUSH_URL, {
      method: "POST",
      headers: { 
        Accept: "application/json", 
        "Content-Type": "application/json",
        Authorization: `Bearer ${Deno.env.get("EXPO_ACCESS_TOKEN")}`,
      },
      body: JSON.stringify(batch),
    });

    if (!res.ok) { console.error("Expo API error:", res.status); continue; }

    const { data: tickets } = await res.json();
    for (let j = 0; j < tickets.length; j++) {
      if (tickets[j].status === "error") {
        const err = tickets[j].details?.error;
        if (err === "DeviceNotRegistered" || err === "InvalidCredentials") {
          await supabase.from("push_tokens").delete().eq("token", batch[j].to);
        }
      }
    }
  }

  return new Response("OK", { status: 200 });
});
```

> **Note:** Set `EXPO_ACCESS_TOKEN` as a Supabase secret: `supabase secrets set EXPO_ACCESS_TOKEN=<your-expo-token>`

## Database Table: notifications

```sql
create table notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id),
  title text not null,
  body text not null,
  data jsonb default '{}',
  badge int,
  channel_id text,
  created_at timestamptz default now()
);

alter table notifications enable row level security;
create policy "Users can read own notifications"
  on notifications for select using (auth.uid() = user_id);
```

## Webhook: Trigger on INSERT

**Dashboard:** Database → Webhooks → Create → Table: `notifications`, Event: `INSERT`, Function: `send-push`.

**SQL (pg_net):**

```sql
create extension if not exists pg_net;

create or replace function trigger_push_notification() returns trigger as $$
begin
  perform net.http_post(
    url := current_setting('app.supabase_url') || '/functions/v1/send-push',
    body := json_build_object('record', row_to_json(new))::text,
    headers := '{"Content-Type":"application/json"}'::jsonb
  );
  return new;
end;
$$ language plpgsql;

create trigger on_notification_insert
  after insert on notifications
  for each row execute function trigger_push_notification();
```

## Error Handling

| Expo Error | Action |
|-----------|--------|
| `DeviceNotRegistered` | Delete token from `push_tokens` |
| `InvalidCredentials` | Delete token, verify FCM/APNs keys |
| `MessageTooBig` | Trim body (max ~4096 bytes) |
| `MessageRateExceeded` | Exponential backoff, batch fewer |
| `MismatchSenderId` | Token generated with wrong FCM project |

**Retry (transient errors):**

```ts
async function sendWithRetry(messages: object[], retries = 3) {
  for (let a = 0; a < retries; a++) {
    try {
      const res = await fetch(EXPO_PUSH_URL, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(messages),
      });
      if (res.ok) return await res.json();
      if (res.status === 429) { await new Promise(r => setTimeout(r, 1000 * 2 ** a)); continue; }
      throw new Error(`Push failed: ${res.status}`);
    } catch (e) { if (a === retries - 1) throw e; }
  }
}
```

## Deploy

```bash
supabase functions deploy send-push
```
