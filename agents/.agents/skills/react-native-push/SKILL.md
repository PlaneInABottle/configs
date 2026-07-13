---
name: react-native-push
description: Implement and verify push or local notifications in Expo and React Native applications. Use for notification permissions, Expo or native device tokens, Android channels, foreground presentation, tap routing, badge state, server delivery, tickets, receipts, and token cleanup.
---

# React Native Push Notifications

Inspect the installed Expo SDK, build type, notification provider, app configuration, and backend before adding code. Remote push requires a development or production build and a physical device; local notification support varies by platform and SDK.

## Registration

1. Check that the app is running on a supported device and build.
2. On Android, create the notification channel before requesting a push token.
3. Read existing permission status and request permission at a user-appropriate moment.
4. Resolve the EAS project ID from current Expo configuration.
5. Request the Expo push token and upsert it with user, device, platform, and last-seen metadata.
6. Listen for token changes where the installed SDK supports it.

```ts
if (Platform.OS === 'android') {
  await Notifications.setNotificationChannelAsync('default', {
    name: 'Default',
    importance: Notifications.AndroidImportance.HIGH,
  });
}

const projectId = Constants.easConfig?.projectId
  ?? Constants.expoConfig?.extra?.eas?.projectId;
if (!projectId) throw new Error('EAS project ID is not configured');

const token = await Notifications.getExpoPushTokenAsync({ projectId });
```

## Receiving and Taps

- Set the foreground notification handler at module initialization.
- Subscribe to notification responses while the app runs.
- Read the last notification response for cold start, process it idempotently, and clear it with the current Expo API so it is not handled twice.
- Validate notification data before navigating; do not trust arbitrary route strings from a payload.
- Remove subscriptions during cleanup.

## Sending

- Send from trusted backend code, never directly from an untrusted client.
- Batch within current Expo service limits.
- Inspect immediate push tickets, then fetch push receipts later.
- Remove or disable tokens only from authoritative errors such as `DeviceNotRegistered` reported by the current API.
- Implement bounded retries for transient failures and avoid retrying malformed requests.
- Enable Expo push access-token security when the project requires it.

## Local Verification

Use the installed SDK's documented trigger shape rather than copying version-specific enum names. Schedule one local notification, verify foreground presentation, tap routing, cold start, Android channel, and badge behavior on the target platforms.

## References

- Load [references/expo-push-setup.md](references/expo-push-setup.md) for platform configuration, then verify it against the installed SDK.
- Load [references/supabase-push-trigger.md](references/supabase-push-trigger.md) only when Supabase is the selected backend.
- Use `maestro-testing` for UI routing checks, but deliver real remote pushes through the provider rather than simulating them as UI taps.
