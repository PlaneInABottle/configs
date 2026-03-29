# OTA Updates with expo-updates

## Installation

```bash
npx expo install expo-updates
```

Add to `app.json` / `app.config.js`:

```json
{
  "expo": {
    "updates": {
      "url": "https://u.expo.dev/your-project-id"
    }
  }
}
```

The project ID is your Expo project's ID (find it in `app.json` under `expo.extra.eas.projectId` or at expo.dev).

## Publishing Updates

```bash
# Publish to a specific branch
eas update --branch production --message "Fix: correct login form validation"

# Publish to a branch matching a build profile's channel
eas update --branch preview --message "QA fix: adjust button padding"
```

### Branch vs Channel

| Concept | Description |
|---|---|
| **Channel** | Set in `eas.json` build profile — tells the app which update stream to check |
| **Branch** | The update stream itself — a branch maps to zero or more channels |

A branch maps to a channel. When you set `"channel": "production"` in your build profile, the built app checks the branch mapped to `production` for updates.

```bash
# Map a branch to a channel
eas channel:create production
eas branch:create production
eas channel:edit production --branch production
```

## Runtime Version Strategy

Runtime version determines which updates are compatible with which binaries.

### Strategies

| Strategy | When to Use |
|---|---|
| `"sdkVersion"` | Simple apps, no custom native modules |
| `"appVersion"` | Apps with native modules, need fine-grained control |

Set in `app.json`:

```json
{
  "expo": {
    "runtimeVersion": {
      "policy": "sdkVersion"
    }
  }
}
```

### Rules

- OTA updates only install on devices with a matching `runtimeVersion`
- Changing native modules or `expo-updates` config requires a new binary build
- Changing `runtimeVersion` breaks compatibility with all previous OTA updates on the old version
- Bump `runtimeVersion` only when you ship a new binary build

## Checking for Updates

By default, expo-updates checks for updates on app launch. Configure in `app.json`:

```json
{
  "expo": {
    "updates": {
      "url": "https://u.expo.dev/your-project-id",
      "checkAutomatically": "ON_LOAD"
    }
  }
}
```

Options for `checkAutomatically`:

| Value | Behavior |
|---|---|
| `"ON_LOAD"` | Check every app launch (default) |
| `"ON_ERROR_RECOVERY"` | Check only after a crash recovery |
| `"NEVER"` | Never auto-check; use manual API |

### Manual Update Check

```typescript
import * as Updates from 'expo-updates';

async function checkForUpdate() {
  const result = await Updates.checkForUpdateAsync();
  if (result.isAvailable) {
    await Updates.fetchUpdateAsync();
    Updates.reloadAsync();
  }
}
```

## Rollback Procedures

### Republish Previous Update

```bash
# Find the previous update group ID from the update list
eas update:list --branch production

# Republish that group
eas update --branch production --republish --group <group-id>
```

This re-publishes the exact same JS bundle and assets from the specified update.

### Disable Updates (Emergency)

If a bad update is causing crashes:

```json
{
  "expo": {
    "updates": {
      "enabled": false
    }
  }
}
```

This requires a new binary build. For faster response, republish the last known good update instead.

## Common Issues

- **Update not appearing**: Verify `runtimeVersion` matches between update and binary
- **Assets missing**: Ensure `updates.assetPatternsToBeBundled` in `app.json` includes all asset directories (e.g. `["app/images/**/*.png"]`)
- **Build fails with expo-updates**: Run `npx expo prebuild --clean` to regenerate native projects
