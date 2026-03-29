# EAS Credentials Management

## Auto-Managed Credentials (Recommended)

EAS can generate and manage all signing credentials automatically.

```bash
# First build triggers auto-credential flow
eas build --profile production --platform ios

# Or explicitly manage credentials
eas credentials
```

**How it works:**
1. EAS generates a distribution certificate (iOS) or keystore (Android)
2. Credentials are stored encrypted on EAS servers
3. Subsequent builds reuse stored credentials automatically
4. Team members with access can build without sharing files manually

## iOS Credentials

### Requirements

- Apple Developer Program membership ($99/year)
- Apple ID with 2FA enabled
- App-specific password (for submission)

### Provisioning Profiles

EAS auto-generates:
- **Distribution certificate** — signs the app binary
- **Provisioning profile** — links certificate + App ID + devices

```bash
# View managed iOS credentials
eas credentials --platform ios

# Push local credentials to EAS
eas credentials --platform ios --push

# Remove and regenerate credentials
eas credentials --platform ios --clear
```

### Manual iOS Setup

If auto-management fails or you need enterprise signing:

1. Create an App ID in Apple Developer portal
2. Create a distribution certificate (.p12)
3. Create a provisioning profile (.mobileprovision)
4. Upload via `eas credentials --platform ios --push`

## Android Credentials

### Keystore

EAS auto-generates a keystore on first Android build.

```bash
# View managed Android credentials
eas credentials --platform android

# Use an existing keystore
eas credentials --platform android --push
```

**Important:** Google Play signs apps with Play App Signing. The upload key (keystore) is only used to upload — Google re-signs with its own key.

### Google Play Service Account

Required for automated submission to Google Play.

1. Go to Google Play Console → Setup → API access
2. Link a Google Cloud project
3. Create a service account with **Release Manager** role
4. Download the JSON key file
5. Store securely:

```bash
# Store as EAS environment variable
eas env:create --name GOOGLE_SERVICE_ACCOUNT_KEY --value "$(cat service-account.json | base64)" --environment production --visibility sensitive
```

Reference in `eas.json` submit profile:

```json
{
  "submit": {
    "production": {
      "android": {
        "serviceAccountKeyPath": "./google-service-account.json",
        "track": "internal"
      }
    }
  }
}
```

## Sharing Credentials Across a Team

### EAS-Managed Sharing

All team members with Expo project access automatically use the same credentials — no file exchange needed.

```bash
# Team member logs in and builds
eas login
eas build --profile production --platform ios
```

EAS pulls the stored credentials transparently.

### Manual Sharing (Not Recommended)

If you must share credentials outside EAS:

- **iOS**: Export .p12 certificate + provisioning profile
- **Android**: Share keystore file + passwords securely (never commit to git)

## Credential Rotation

### iOS

Certificates expire annually. EAS detects expiration and prompts regeneration:

```bash
eas credentials --platform ios
# Select "Remove certificate and generate new one"
```

### Android

Keystores don't expire, but rotate if compromised:

```bash
# Generate new keystore
eas credentials --platform android
# Select "Remove keystore and generate new one"
```

**Warning:** Rotating an Android keystore changes your upload key. You must update the key in Google Play Console to match.
