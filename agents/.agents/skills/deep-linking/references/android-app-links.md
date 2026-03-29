# Android App Links — Configuration Reference

## assetlinks.json

Host at `https://yourdomain.com/.well-known/assetlinks.json`. Must be served over HTTPS with `Content-Type: application/json`.

### Minimal assetlinks.json

```json
[
  {
    "relation": [
      "delegate_permission/common.handle_all_urls"
    ],
    "target": {
      "namespace": "android_app",
      "package_name": "com.example.myapp",
      "sha256_cert_fingerprints": [
        "AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99"
      ]
    }
  }
]
```

- `package_name` — Must match `android.package` in `app.json`
- `sha256_cert_fingerprints` — One per signing key (debug + production have different fingerprints)

### Getting Your SHA-256 Fingerprint

**Debug (local):**
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android | grep "SHA256"
```

**Production (Play Store):**
```bash
keytool -list -v -keystore your-release.keystore -alias your-alias | grep "SHA256"
```

**EAS Build:**
EAS generates a separate keystore. Download credentials:
```bash
eas credentials --platform android
```

### Multiple Fingerprints

Include both debug and release fingerprints if you want app links to work in development:

```json
"sha256_cert_fingerprints": [
  "DEBUG_SHA256_HERE",
  "RELEASE_SHA256_HERE"
]
```

## Intent Filters

Expo generates intent filters from `app.json`. For app links:

```json
{
  "expo": {
    "android": {
      "intentFilters": [
        {
          "action": "VIEW",
          "autoVerify": true,
          "data": [
            {
              "scheme": "https",
              "host": "yourdomain.com",
              "pathPrefix": "/"
            }
          ],
          "category": ["BROWSABLE", "DEFAULT"]
        }
      ]
    }
  }
}
```

After `npx expo prebuild`, this produces in `AndroidManifest.xml`:

```xml
<intent-filter android:autoVerify="true">
  <action android:name="android.intent.action.VIEW" />
  <category android:name="android.intent.category.DEFAULT" />
  <category android:name="android.intent.category.BROWSABLE" />
  <data android:scheme="https" android:host="yourdomain.com" android:pathPrefix="/" />
</intent-filter>
```

The `autoVerify="true"` attribute tells Android to verify the `assetlinks.json` and treat these as app links (not just generic intents).

## Testing

### Emulator / Device (ADB)

```bash
# Open a URL — Android decides (app or browser)
adb shell am start -a android.intent.action.VIEW -d "https://yourdomain.com/profile"

# Force open in app (bypasses verification)
adb shell am start -a android.intent.action.VIEW -d "https://yourdomain.com/profile" com.example.myapp
```

### Verify App Link Status

```bash
# List all app link domains and their verification state
adb shell dumpsys package d | grep -A 5 "yourdomain.com"
```

Look for `verified=true` — this confirms Android found and verified your `assetlinks.json`.

### Digital Asset Links API

Test with curl:

```bash
curl -s "https://digitalassetlinks.googleapis.com/v1/statements:list?source.web.site=https://yourdomain.com&relation=delegate_permission/common.handle_all_urls" | python3 -m json.tool
```

Expected response when configured correctly:

```json
{
  "maxAge": "0s",
  "linkedContent": [{
    "source": { "web": { "site": "https://yourdomain.com" } },
    "target": { "androidApp": { "packageName": "com.example.myapp" } },
    "relation": ["delegate_permission/common.handle_all_urls"]
  }]
}
```

## Common Pitfalls

| Issue | Fix |
|-------|-----|
| App links not auto-opening | Check `autoVerify="true"` is in the intent filter. Verify `assetlinks.json` is accessible at `/.well-known/assetlinks.json`. |
| `assetlinks.json` 404 | Must be exactly at `https://yourdomain.com/.well-known/assetlinks.json`. No redirects. |
| Wrong fingerprint | Debug and release keystrokes have different SHA-256. Include both in `assetlinks.json` during development. |
| Verification failed | Use the Digital Asset Links API to verify the response matches. Check for trailing slashes or path mismatches. |
| Works on emulator, not device | Device may have cached old state. Uninstall the app and reinstall. Clear Google Play Services cache. |
| `pathPrefix` too broad | Use specific prefixes: `"/app/"` instead of `"/"` to avoid capturing unrelated pages on the same domain. |
