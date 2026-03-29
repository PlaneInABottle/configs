---
name: react-native-push
description: "Implement push notifications in React Native apps using Expo Push Notification service. Use when: setting up push notification tokens, handling notification taps, configuring notification channels (Android), managing badge counts, sending notifications via Supabase edge functions, or testing push notification delivery. Triggers on 'add push notifications', 'setup expo push', 'send notification', 'notification badge', or any push notification task."
---

# React Native Push

## Overview

Expo Push Notifications for React Native. Composes with `supabase` (edge functions to trigger sends) and `expo-eas-build` (credentials for production builds).

## Quick Start

Install and configure:

```bash
npx expo install expo-notifications expo-device
```

Add the plugin to `app.json`:

```json
{
  "expo": {
    "plugins": [
      [
        "expo-notifications",
        {
          "icon": "./assets/notification-icon.png",
          "color": "#ffffff",
          "sounds": ["./assets/notification-sound.wav"]
        }
      ]
    ]
  }
}
```

See `references/expo-push-setup.md` for full platform configuration.

## Token Registration

Get the Expo push token on app launch and send it to your backend:

```ts
import * as Notifications from "expo-notifications";
import * as Device from "expo-device";
import Constants from "expo-constants";
import { Platform } from "react-native";

async function registerForPushNotificationsAsync(): Promise<string | null> {
  if (!Device.isDevice) {
    console.warn("Push notifications require a physical device");
    return null;
  }

  const { status: existingStatus } = await Notifications.getPermissionsAsync();
  let finalStatus = existingStatus;

  if (existingStatus !== "granted") {
    const { status } = await Notifications.requestPermissionsAsync();
    finalStatus = status;
  }

  if (finalStatus !== "granted") {
    console.warn("Push notification permission denied");
    return null;
  }

  const token = await Notifications.getExpoPushTokenAsync({
    projectId: Constants.expoConfig?.extra?.eas?.projectId,
  });

  // Android: configure channel before getting token
  if (Platform.OS === "android") {
    await Notifications.setNotificationChannelAsync("default", {
      name: "Default",
      importance: Notifications.AndroidImportance.MAX,
    });
  }

  return token.data;
}
```

Send the token to your backend on login or app launch:

```ts
// After getting token
await supabase.from("push_tokens").upsert({
  user_id: user.id,
  token: tokenData,
  platform: Platform.OS,
  updated_at: new Date().toISOString(),
});
```

**Key rules:**
- Always upsert tokens — they can change on reinstall or device change
- Store the platform alongside the token (iOS/Android payloads differ)
- Request permission early, but don't block app startup on it

## Handling Notifications

### Foreground Notifications

Control what happens when a notification arrives while the app is open:

```ts
import * as Notifications from "expo-notifications";

// Must be set at module root — before any component renders
Notifications.setNotificationHandler({
  handleNotification: async () => ({
    shouldShowBanner: true,  // Show banner in foreground
    shouldShowList: true,    // Show in notification list
    shouldPlaySound: true,
    shouldSetBadge: true,
  }),
});
```

### Notification Tap (Response)

Handle when a user taps a notification:

```ts
import { useEffect, useRef } from "react";
import * as Notifications from "expo-notifications";

function useNotificationTap(
  onAction: (data: Record<string, unknown>) => void
) {
  const responseListener = useRef<Notifications.Subscription>();

  useEffect(() => {
    // Tapped while app was already open
    responseListener.current =
      Notifications.addNotificationResponseReceivedListener((response) => {
        const data = response.notification.request.content.data;
        onAction(data as Record<string, unknown>);
      });

    // Tapped from cold start (app was killed)
    Notifications.getLastNotificationResponseAsync().then((response) => {
      if (response) {
        const data = response.notification.request.content.data;
        onAction(data as Record<string, unknown>);
      }
    });

    return () => {
      responseListener.current?.remove();
    };
  }, [onAction]);
}
```

### Listener Lifecycle

| Scenario | API |
|----------|-----|
| Foreground received | `setNotificationHandler` |
| User tapped (app open) | `addNotificationResponseReceivedListener` |
| User tapped (cold start) | `getLastNotificationResponseAsync` |
| Notification received in background | Task manager (optional) |

## Android Channels

Android 8+ requires notification channels. Define channels on app init:

```ts
import * as Notifications from "expo-notifications";

async function setupAndroidChannels() {
  await Notifications.setNotificationChannelAsync("messages", {
    name: "Messages",
    importance: Notifications.AndroidImportance.HIGH,
    sound: "notification-sound.wav",
    vibrationPattern: [0, 250, 250, 250],
    enableVibrate: true,
  });

  await Notifications.setNotificationChannelAsync("promotions", {
    name: "Promotions",
    importance: Notifications.AndroidImportance.LOW,
  });
}
```

When sending via Expo Push API, specify the channel in the payload:

```json
{
  "to": "ExponentPushToken[xxx]",
  "title": "New message",
  "body": "Hello!",
  "channelId": "messages"
}
```

See `references/expo-push-setup.md` for platform details.

## Badge Management

```ts
import * as Notifications from "expo-notifications";

// Set badge count (iOS + some Android launchers)
await Notifications.setBadgeCountAsync(0); // Clear on open

// Read current count
const count = await Notifications.getBadgeCountAsync();
```

Clear the badge when the user opens the relevant screen:

```ts
useEffect(() => {
  Notifications.setBadgeCountAsync(0);
}, []);
```

You can also set badge in the push payload:

```json
{
  "to": "ExponentPushToken[xxx]",
  "badge": 5
}
```

## Sending Notifications

### Expo Push API (Direct)

Send to one or more tokens (max 100 per request):

```ts
const EXPO_PUSH_URL = "https://exp.host/--/api/v2/push/send";

async function sendPushNotification(
  tokens: string[],
  title: string,
  body: string,
  data?: Record<string, unknown>
) {
  const messages = tokens.map((token) => ({
    to: token,
    sound: "default",
    title,
    body,
    data,
  }));

  const response = await fetch(EXPO_PUSH_URL, {
    method: "POST",
    headers: {
      Accept: "application/json",
      "Content-Type": "application/json",
    },
    body: JSON.stringify(messages),
  });

  const result = await response.json();

  // Check for errors per-ticket
  for (const ticket of result.data) {
    if (ticket.status === "error") {
      console.error("Push failed:", ticket.message, ticket.details);
      // Handle invalid tokens: ticket.details?.error === "DeviceNotRegistered"
    }
  }

  return result;
}
```

### Supabase Edge Function (Recommended)

Send pushes from a Supabase edge function triggered by a database event. See `references/supabase-push-trigger.md` for the full pattern.

## Composing with Other Skills

| Need | Load Skill |
|------|-----------|
| Expo app scaffold / routing | `react-native-expo` |
| Backend / database / auth | `supabase` |
| Production builds + credentials | `expo-eas-build` |
| Process management (dev server) | `pm2-runtime-operator` |
| E2E mobile testing | `maestro-testing` |
| API contract testing | `api-contract-testing` |

## Testing

### Local Scheduling

Schedule a local notification to verify handling without a server:

```ts
await Notifications.scheduleNotificationAsync({
  content: {
    title: "Test notification",
    body: "This is a local test",
    data: { screen: "settings" },
  },
  trigger: {
    type: Notifications.SchedulableTriggerInputTypes.TIME_INTERVAL,
    seconds: 5,
  },
});
```

### Expo Push Tool

Use the Expo push notification tool at https://expo.dev/notifications to send a test push to your device token.

### Checklist

- [ ] Token registered and stored in backend
- [ ] Foreground notifications display
- [ ] Notification tap navigates correctly (app open + cold start)
- [ ] Android channels defined and receiving
- [ ] Badge count clears on relevant screen
- [ ] Invalid/expired tokens cleaned up in backend

## Anti-Patterns

| Don't | Do Instead |
|-------|-----------|
| Request permission on every app launch | Check existing permission first, request only once |
| Store tokens only on client | Upsert to backend on login and app launch |
| Send pushes one-by-one | Batch up to 100 tokens per API call |
| Ignore error tickets from Expo API | Check `status === "error"`, remove invalid tokens |
| Use `shouldShowAlert: false` in foreground | Set to `true` unless you have custom in-app UI |
| Skip Android channels | Always define channels — required on Android 8+ |

## References

Load on demand:

- `references/expo-push-setup.md` — Plugin config, platform specifics, EAS credentials
- `references/supabase-push-trigger.md` — Edge function pattern, webhook setup, retry logic
