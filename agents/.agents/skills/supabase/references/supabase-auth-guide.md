# Supabase Auth Guide

## Email / Password

```typescript
// Sign up — sends confirmation email if enabled in dashboard
const { data, error } = await supabase.auth.signUp({
  email: 'user@example.com',
  password: 'secureP@ss123',
  options: {
    data: { full_name: 'Jane Doe' }, // stored in user.user_metadata
  },
});

// Sign in
const { data, error } = await supabase.auth.signInWithPassword({
  email: 'user@example.com',
  password: 'secureP@ss123',
});

// Sign out (global revokes all refresh tokens)
await supabase.auth.signOut({ scope: 'local' }); // local | global
```

## OAuth Providers

### Google

```typescript
const { data, error } = await supabase.auth.signInWithOAuth({
  provider: 'google',
  options: {
    redirectTo: 'myapp://auth/callback', // deep link on mobile
    queryParams: { access_type: 'offline', prompt: 'consent' },
  },
});
```

**Dashboard setup:** Authentication → Providers → Google → Enable. Add OAuth Client ID and secret from Google Cloud Console. Set redirect URL to `https://<project>.supabase.co/auth/v1/callback`.

### Apple (iOS)

```typescript
const { data, error } = await supabase.auth.signInWithOAuth({
  provider: 'apple',
  options: {
    redirectTo: 'myapp://auth/callback',
  },
});
```

**Dashboard setup:** Requires Apple Developer account. Configure App ID, Services ID, and private key. Set redirect URL `https://<project>.supabase.co/auth/v1/callback`.

### Mobile Redirect URLs

For OAuth and magic link on native, register a custom URL scheme in `app.json`:

```json
{
  "expo": {
    "scheme": "myapp"
  }
}
```

Handle the incoming URL with `expo-linking`:

```typescript
import * as Linking from 'expo-linking';
import { useEffect } from 'react';

export function useAuthRedirectListener() {
  useEffect(() => {
    const sub = Linking.addEventListener('url', async ({ url }) => {
      const { params } = Linking.parse(url);
      if (params?.access_token) {
        await supabase.auth.setSession({
          access_token: params.access_token as string,
          refresh_token: params.refresh_token as string,
        });
      }
    });
    return () => sub.remove();
  }, []);
}
```

## Magic Link (Passwordless)

```typescript
// Send magic link
const { error } = await supabase.auth.signInWithOtp({
  email: 'user@example.com',
  options: {
    emailRedirectTo: 'myapp://auth/callback',
  },
});

// User clicks link → arrives at redirect URL with token
// Use setSession above to complete the flow
```

## Password Reset

```typescript
// Step 1: Send reset email
const { error } = await supabase.auth.resetPasswordForEmail('user@example.com', {
  redirectTo: 'myapp://auth/reset-password',
});

// Step 2: User opens link, arrives at redirect URL
// Step 3: Update password
const { error } = await supabase.auth.updateUser({
  password: 'newSecureP@ss456',
});
```

## Session Management

```typescript
// Get current session
const { data: { session } } = await supabase.auth.getSession();
const accessToken = session?.access_token;
const refreshToken = session?.refresh_token;

// Get current user
const { data: { user } } = await supabase.auth.getUser();

// Manual refresh (rarely needed — auto-refresh is on by default)
const { data, error } = await supabase.auth.refreshSession();

// Listen for auth events
const { data: { subscription } } = supabase.auth.onAuthStateChange(
  (event, session) => {
    switch (event) {
      case 'INITIAL_SESSION':
        break;
      case 'SIGNED_IN':
        break;
      case 'SIGNED_OUT':
        break;
      case 'TOKEN_REFRESHED':
        break;
      case 'USER_UPDATED':
        break;
    }
  }
);

// Cleanup listener
subscription.unsubscribe();
```

## Custom Storage Adapter (React Native)

Use `expo-secure-store` instead of the default `localStorage`:

```typescript
import * as SecureStore from 'expo-secure-store';
import { createClient } from '@supabase/supabase-js';

const supabase = createClient(url, anonKey, {
  auth: {
    storage: {
      getItem: (key) => SecureStore.getItemAsync(key),
      setItem: (key, value) => SecureStore.setItemAsync(key, value),
      removeItem: (key) => SecureStore.deleteItemAsync(key),
    },
    autoRefreshToken: true,
    persistSession: true,
    detectSessionInUrl: false,
  },
});
```

## Adding to `AccessToken` for API Calls

```typescript
const { data: { session } } = await supabase.auth.getSession();
const token = session?.access_token;

// Use in fetch/axios headers
fetch('https://api.example.com/protected', {
  headers: { Authorization: `Bearer ${token}` },
});
```
