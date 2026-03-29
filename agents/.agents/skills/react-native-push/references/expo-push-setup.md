# Expo Push Setup Reference

## app.json Plugin Config

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
    ],
    "notification": {
      "icon": "./assets/notification-icon.png",
      "color": "#ffffff"
    }
  }
}
```

- `icon` — monochrome PNG used as the Android notification icon (96x96 recommended)
- `color` — accent color for Android notification bar
- `sounds` — custom sound files (`.wav`), referenced by filename in push payloads

## Android

### Permissions

The `expo-notifications` plugin auto-adds these to `AndroidManifest.xml`:

- `POST_NOTIFICATIONS` (Android 13+)
- `RECEIVE_BOOT_COMPLETED` (for scheduled notifications)
- `VIBRATE`

No manual permission setup needed in managed Expo.

### Notification Channels

Android 8+ (API 26) requires channels. Define them at app init:

```ts
await Notifications.setNotificationChannelAsync("default", {
  name: "Default",
  importance: Notifications.AndroidImportance.MAX,
  vibrationPattern: [0, 250, 250, 250],
  enableVibrate: true,
  sound: "default",
});
```

- Channels are created once; calling again with the same ID updates the channel
- If you use custom sounds, reference the filename without path: `"sound": "notification-sound.wav"`
- Set `channelId` in push payloads to route to a specific channel

### Android-Specific Payload Fields

```json
{
  "to": "ExponentPushToken[xxx]",
  "title": "Alert",
  "body": "Something happened",
  "channelId": "alerts",
  "priority": "high",
  "sound": "default"
}
```

## iOS

### Entitlements

In managed Expo, `expo-notifications` handles the required entitlements. For bare/development builds via EAS:

1. Enable **Push Notifications** capability in Apple Developer portal
2. Ensure the provisioning profile includes the push entitlement

### APNs Credentials

Production pushes require an APNs authentication key:

1. Go to Apple Developer → Keys → create a new key with **Apple Push Notifications service (APNs)** enabled
2. Download the `.p8` file
3. Upload via `eas credentials` → iOS → Push Notifications → upload APNs key

Required fields: Key ID, Team ID, Bundle ID, Auth Key file.

### iOS-Specific Payload Fields

```json
{
  "to": "ExponentPushToken[xxx]",
  "title": "Alert",
  "body": "Something happened",
  "sound": "default",
  "badge": 1,
  "subtitle": "Optional subtitle",
  "categoryId": "message_actions"
}
```

## EAS Credential Requirements

| Platform | What You Need |
|----------|--------------|
| iOS (dev) | Development provisioning profile (auto-managed by EAS) |
| iOS (prod) | APNs auth key (.p8) uploaded to Expo |
| Android (all) | FCM server key uploaded to Expo |

### Uploading FCM Key

1. Create a Firebase project at https://console.firebase.google.com
2. Add your Android app (use the package name from `app.json`)
3. Go to Project Settings → Cloud Messaging → generate a Server Key
4. Upload via `eas credentials` → Android → FCM → paste server key

### Uploading APNs Key

```bash
eas credentials
# Select iOS → Production → Push Notifications → Upload APNs Auth Key
```

Or upload via Expo dashboard: https://expo.dev → Project → Credentials → iOS.
