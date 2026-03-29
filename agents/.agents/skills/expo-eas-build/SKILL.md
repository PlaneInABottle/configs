---
name: expo-eas-build
description: "Build, deploy, and submit React Native apps using Expo Application Services (EAS). Use when: configuring EAS Build profiles, managing iOS/Android credentials, setting up OTA updates, preparing app store metadata, submitting to TestFlight/Google Play, or automating mobile release pipelines. Triggers on 'build app', 'eas build', 'submit to app store', 'OTA update', 'release mobile app', 'configure credentials', or any Expo build/deploy task."
---

# Expo EAS Build

EAS Build is Expo's cloud build service for React Native apps. It handles iOS and Android builds, credential management, app store submissions, and OTA (over-the-air) updates. Composes with `cicd-pipeline` for CI integration and `react-native-expo` as the project foundation.

## Quick Start

```bash
# Install EAS CLI
npm install -g eas-cli

# Log in to your Expo account
eas login

# Initialize EAS in your project
eas build:configure

# Run a production build
eas build --profile production --platform all
```

## Build Profiles

EAS Build uses `eas.json` to define build profiles. See `references/eas-build-profiles.md` for full options.

### Three Standard Profiles

| Profile | Purpose | Distribution |
|---|---|---|
| `development` | Dev client with hot reload | Internal (ad-hoc / emulator) |
| `preview` | Internal testing builds | Internal (APK / ad-hoc) |
| `production` | App store submission builds | Store |

```json
{
  "build": {
    "development": {
      "developmentClient": true,
      "distribution": "internal"
    },
    "preview": {
      "distribution": "internal"
    },
    "production": {
      "autoIncrement": true
    }
  }
}
```

## Credentials

EAS can auto-manage credentials or use manual configuration. See `references/credentials-management.md`.

- **iOS**: Apple Developer account, provisioning profiles, distribution certificates
- **Android**: Keystore, Google Play service account JSON
- **Sharing**: `eas credentials` lets teams sync credentials via EAS servers

```bash
# Interactive credential management
eas credentials

# Push local credentials to EAS
eas credentials --platform ios --push
```

## OTA Updates

Use `expo-updates` to push JavaScript-only updates without app store review. See `references/ota-updates.md`.

```bash
# Publish an OTA update
eas update --branch production --message "Fix login bug"

# Roll back to previous update
eas update:republish --group <previous-update-group-id>
```

### Runtime Version Strategy

Each binary build gets a `runtimeVersion`. OTA updates only reach devices with a matching runtime version. Use `"appVersion"` (default) for most apps or `"fingerprint"` for SDK 52+ projects with native modules. See `references/ota-updates.md`.

## App Store Metadata

### EAS Submit Configuration

Add `submit` profiles to `eas.json`:

```json
{
  "submit": {
    "production": {
      "ios": {
        "appleId": "you@example.com",
        "ascAppId": "1234567890",
        "appleTeamId": "ABCDE12345"
      },
      "android": {
        "serviceAccountKeyPath": "./google-service-account.json",
        "track": "internal"
      }
    }
  }
}
```

### iOS Submission

```bash
# Submit to TestFlight / App Store Connect
eas submit --platform ios --profile production
```

Requires: Apple ID, App Store Connect App ID, Apple Team ID. First submission may need manual App Store Connect setup (screenshots, descriptions, privacy policy).

### Android Submission

```bash
# Submit to Google Play Console
eas submit --platform android --profile production
```

Requires: Google Play service account JSON with release manager permissions. App must already exist in Google Play Console.

## Environment Variables

### Build-Time Variables

Set in `eas.json` per profile or via EAS Secrets:

```bash
# Store a variable used during builds
eas env:create --name API_KEY --value "sk-xxx" --environment production --visibility plaintext

# List all variables
eas env:list --environment production
```

### Common Environment Variables

| Variable | Purpose |
|---|---|
| `EXPO_APPLE_ID` | Apple ID for submissions |
| `EXPO_APPLE_PASSWORD` | App-specific password |
| `EXPO_APPLE_TEAM_ID` | Apple Developer Team ID |
| `GOOGLE_SERVICE_ACCOUNT_KEY` | Base64-encoded service account JSON |

## Composing With Other Skills

| Skill | Relationship |
|---|---|
| `cicd-pipeline` | Trigger EAS builds in GitHub Actions / GitLab CI |
| `react-native-expo` | Project foundation — EAS builds Expo/RN projects |
| `agent-browser` | Verify submitted builds via TestFlight / Play Console |

## Anti-Patterns

- **Don't commit keystores or certificates** — use `eas env:create` or EAS auto-credentials
- **Don't hardcode signing credentials** in `eas.json` — reference secrets or use auto-managed credentials
- **Don't use OTA updates for native changes** — OTA only covers JS/asset changes; bump `runtimeVersion` and rebuild for native module changes
- **Don't skip the preview profile** — always test with a production-like build before submitting to stores
- **Don't reuse `runtimeVersion` across incompatible binaries** — OTA updates will fail or install broken code
- **Don't ignore build logs** — EAS logs contain exact failure reasons; always check them before retrying

## References

- `references/eas-build-profiles.md` — Build profile configuration options
- `references/credentials-management.md` — Credential setup and team sharing
- `references/ota-updates.md` — OTA update publishing and rollback
- `assets/eas-configs/eas.json` — Standard 3-profile starter config
