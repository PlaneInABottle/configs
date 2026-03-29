import { createClient } from '@supabase/supabase-js';
import type { Database } from './database.types';

/**
 * Supabase client — singleton. Import from this file everywhere.
 *
 * Required env vars:
 *   EXPO_PUBLIC_SUPABASE_URL      (Expo/React Native)
 *   NEXT_PUBLIC_SUPABASE_URL      (Next.js)
 *   EXPO_PUBLIC_SUPABASE_ANON_KEY
 *   NEXT_PUBLIC_SUPABASE_ANON_KEY
 *
 * The anonymous key is safe to expose client-side. Never put the service role key here.
 */

const supabaseUrl =
  process.env.EXPO_PUBLIC_SUPABASE_URL ?? process.env.NEXT_PUBLIC_SUPABASE_URL;
const supabaseAnonKey =
  process.env.EXPO_PUBLIC_SUPABASE_ANON_KEY ?? process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;

if (!supabaseUrl) {
  throw new Error(
    'Missing Supabase URL. Set EXPO_PUBLIC_SUPABASE_URL or NEXT_PUBLIC_SUPABASE_URL in .env'
  );
}

if (!supabaseAnonKey) {
  throw new Error(
    'Missing Supabase anon key. Set EXPO_PUBLIC_SUPABASE_ANON_KEY or NEXT_PUBLIC_SUPABASE_ANON_KEY in .env'
  );
}

export const supabase = createClient<Database>(supabaseUrl, supabaseAnonKey, {
  auth: {
    autoRefreshToken: true,
    persistSession: true,
    detectSessionInUrl: false,
  },
});
