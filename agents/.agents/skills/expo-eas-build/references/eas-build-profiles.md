# EAS Build Profiles Reference

## eas.json Structure

```json
{
  "cli": {
    "version": ">= 7.0.0",
    "appVersionSource": "remote"
  },
  "build": {
    "development": { ... },
    "preview": { ... },
    "production": { ... }
  },
  "submit": { ... }
}
```

## Profile Options

| Option | Type | Description |
|---|---|---|
| `distribution` | `"store"` \| `"internal"` | Build distribution method |
| `developmentClient` | `boolean` | Use Expo dev client (enables hot reload) |
| `android.buildType` | `"apk"` \| `"app-bundle"` | Android output format |
| `ios.simulator` | `boolean` | Build for iOS Simulator only |
| `autoIncrement` | `boolean` \| `"version"` | Auto-bump build number |
| `env` | `object` | Environment variables for this profile |
| `cache` | `object` | Build cache configuration |
| `resourceClass` | `string` | Compute resource class |
| `channel` | `string` | Update channel for expo-updates |

## Development Profile

For local development with Expo dev client and internal distribution.

```json
{
  "development": {
    "developmentClient": true,
    "distribution": "internal",
    "ios": {
      "simulator": true,
      "resourceClass": "m-medium"
    },
    "android": {
      "buildType": "apk",
      "resourceClass": "medium"
    },
    "channel": "development"
  }
}
```

- Uses Expo dev client for fast iteration
- iOS builds target Simulator (skip code signing, faster)
- Android outputs APK for easy sideloading
- Internal distribution auto-generates shareable URLs

## Preview Profile

For internal testing with near-production configuration.

```json
{
  "preview": {
    "distribution": "internal",
    "android": {
      "buildType": "apk",
      "resourceClass": "medium"
    },
    "env": {
      "APP_ENV": "staging"
    },
    "channel": "preview",
    "autoIncrement": true
  }
}
```

- Internal distribution but full device builds (not simulator)
- APK format for easy install on Android test devices
- Uses `channel` to connect with OTA update streams
- Good for QA and stakeholder review

## Production Profile

For App Store / Google Play submission.

```json
{
  "production": {
    "autoIncrement": true,
    "android": {
      "buildType": "app-bundle",
      "resourceClass": "large"
    },
    "ios": {
      "resourceClass": "m-large"
    },
    "env": {
      "APP_ENV": "production"
    },
    "channel": "production"
  }
}
```

- AAB format for Android (required by Play Store)
- `autoIncrement` bumps build number on each run
- Larger resource class for faster production builds
- Channel maps to production OTA updates

## Resource Classes

| Class | Platform | Specs |
|---|---|---|
| `medium` | Android | Default, sufficient for most builds |
| `large` | Android | More CPU/RAM, faster for large projects |
| `m-medium` | iOS | Default macOS runner |
| `m-large` | iOS | Faster macOS runner |

## Caching

Caching speeds up subsequent builds by preserving dependencies. Default behavior caches `node_modules` and native build artifacts. Configure with `"cache": { "paths": ["node_modules/**", "ios/Pods/**"] }`.

## Per-Profile Environment Variables

Variables set in `env` are available during the build process. Example: `"env": { "API_URL": "https://api.example.com" }`. Use EAS Variables (`eas env:create`) for sensitive values — never put secrets in `eas.json`.
