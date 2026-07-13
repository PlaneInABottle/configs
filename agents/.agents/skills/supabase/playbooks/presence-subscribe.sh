#!/usr/bin/env bash
# Run from a project that already depends on @supabase/supabase-js.
set -euo pipefail

: "${SUPABASE_URL:?Set SUPABASE_URL}"
: "${SUPABASE_ANON_KEY:?Set SUPABASE_ANON_KEY or publishable key}"
: "${SUPABASE_ACCESS_TOKEN:?Set an authenticated disposable user access token}"

CHANNEL="${CHANNEL:-verification-presence}"
export CHANNEL

node --input-type=module <<'NODE'
import { createClient } from '@supabase/supabase-js';

const timeoutMs = 10_000;
const client = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_ANON_KEY, {
  accessToken: async () => process.env.SUPABASE_ACCESS_TOKEN,
  auth: { persistSession: false, autoRefreshToken: false },
});
const channel = client.channel(process.env.CHANNEL, {
  config: { presence: { key: `verification-${Date.now()}` } },
});

try {
  const result = await new Promise((resolve, reject) => {
    const timer = setTimeout(() => reject(new Error('Presence verification timed out')), timeoutMs);
    channel
      .on('presence', { event: 'sync' }, () => {
        const state = channel.presenceState();
        if (Object.keys(state).length > 0) {
          clearTimeout(timer);
          resolve(state);
        }
      })
      .subscribe(async (status) => {
        if (status === 'SUBSCRIBED') {
          await channel.track({ checked_at: new Date().toISOString() });
        } else if (status === 'CHANNEL_ERROR' || status === 'TIMED_OUT') {
          clearTimeout(timer);
          reject(new Error(`Subscription failed: ${status}`));
        }
      });
  });

  console.log(`Presence verification passed with ${Object.keys(result).length} key(s)`);
} finally {
  await client.removeChannel(channel);
}
NODE
