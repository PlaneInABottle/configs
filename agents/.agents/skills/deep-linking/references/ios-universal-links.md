# iOS Universal Links — Configuration Reference

## AASA File

Host at `https://yourdomain.com/.well-known/apple-app-site-association`. Must be served over HTTPS with `Content-Type: application/json` and no redirect.

### Minimal AASA

```json
{
  "applinks": {
    "apps": [],
    "details": [
      {
        "appID": "TEAMID.com.example.myapp",
        "paths": ["/profile/*", "/settings/*", "/auth/callback"]
      }
    ]
  }
}
```

- `appID` — Apple Developer Team ID + `.` + bundle identifier (e.g. `A1B2C3D4E5.com.example.myapp`)
- `paths` — Array of path patterns. Supports `*` wildcard and `?` single-character wildcard.
- `"NOT /admin/*"` — Prefix with `NOT` to exclude paths.

### Enabling Web Credentials (optional)

```json
{
  "applinks": {
    "apps": [],
    "details": [
      {
        "appID": "TEAMID.com.example.myapp",
        "paths": ["/profile/*"]
      }
    ]
  },
  "webcredentials": {
    "apps": ["TEAMID.com.example.myapp"]
  }
}
```

### Expo Config

In `app.json`:

```json
{
  "expo": {
    "ios": {
      "associatedDomains": [
        "applinks:yourdomain.com",
        "applinks:*.yourdomain.com"
      ]
    }
  }
}
```

Each entry maps to an `<string>` in the `com.apple.developer.associated-domains` entitlement in the generated Xcode project.

## Associated Domains Entitlement

Expo generates this automatically from `associatedDomains` in `app.json`. Each domain produces an entry in the `com.apple.developer.associated-domains` entitlement:

```
applinks:yourdomain.com
applinks:*.yourdomain.com
```

Verify in Xcode:
1. Open `ios/<project>.xcodeproj` in Xcode
2. Select project → target → Signing & Capabilities
3. Associated Domains section should list your domains

## Xcode Project Configuration

After `npx expo prebuild`, the generated Xcode project includes:

- `*.entitlements` file with `com.apple.developer.associated-domains`
- `Info.plist` with `CFBundleURLTypes` (for URL schemes)

**Do not edit these manually** — re-run `npx expo prebuild` if they're out of sync.

## Testing

### Simulator

```bash
# Boot simulator if needed
xcrun simctl boot <device-id>

# Open universal link
xcrun simctl openurl booted "https://yourdomain.com/profile"
```

### Device (USB)

```bash
# List devices
xcrun simctl list devices

# Open on device (requires device paired)
# Use Safari — paste URL in address bar
```

### Verify AASA is Cached

On a real device or simulator, Safari caches the AASA. To force re-fetch:

1. Delete the app
2. Reinstall via Xcode or `expo run:ios`
3. Open Safari → visit the link → app opens

### AASA Validation

```bash
# Fetch and validate the AASA file
curl -s https://yourdomain.com/.well-known/apple-app-site-association | python3 -m json.tool
```

## Common Pitfalls

| Issue | Fix |
|-------|-----|
| AASA not loading | Must be HTTPS, no redirects. Content-Type must be `application/json` or `application/pkcs7-mime` |
| App not opening on link tap | Clear AASA cache: delete app, reinstall. Apple caches AASA aggressively. |
| `paths` not matching | Use `*` for any path under a prefix: `"/profile/*"`. Exact paths must match fully. |
| `appID` wrong | Format is `TEAMID.bundleID`. Find Team ID at developer.apple.com → Membership. |
| Works in simulator, not device | Device caches AASA from first install. Delete app and reinstall on the device. |
| Staging domain not working | Each domain needs its own AASA and its own `applinks:` entry in `associatedDomains`. |
