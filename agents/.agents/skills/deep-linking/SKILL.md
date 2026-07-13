---
name: deep-linking
description: Configure and verify deep links in Expo or React Native applications, including custom URL schemes, iOS Universal Links, Android App Links, Expo Router routes, and OAuth callback handling. Use when external URLs must open app screens or authentication must return from a browser.
---

# Deep Linking

Inspect the installed router, app configuration, bundle identifiers, Android package, and authentication flow before editing links. Keep custom schemes for development or controlled callbacks and prefer verified HTTPS links for user-facing production links.

## Custom Schemes

For Expo, define the scheme in `app.json` or `app.config.*` and rebuild the native app after configuration changes.

```json
{
  "expo": {
    "scheme": "myapp",
    "ios": { "bundleIdentifier": "com.example.myapp" },
    "android": { "package": "com.example.myapp" }
  }
}
```

Custom schemes are not globally unique. Do not treat possession of a custom-scheme callback as proof of identity.

## Verified HTTPS Links

- iOS: host a valid AASA file and configure `applinks:` associated domains.
- Android: host `assetlinks.json`, include every release signing fingerprint that should open the app, and configure verified intent filters.
- Serve association files over HTTPS with the documented content type and redirect behavior.
- Test on a build containing the required entitlements and intent filters.

Load [references/ios-universal-links.md](references/ios-universal-links.md) or [references/android-app-links.md](references/android-app-links.md) for platform details, then verify current OS and Expo requirements.

## Expo Router

Expo Router maps files under `app/` to deep-link paths. Preserve existing route groups and use current Expo Router APIs for rewriting third-party URLs. Do not add a separate React Navigation linking object unless the project architecture requires it.

## OAuth PKCE

Use one coherent flow:

1. Build and allowlist the redirect URI.
2. Start OAuth with PKCE through the provider SDK.
3. Open the provider URL in a secure browser session.
4. Receive the callback route or browser-session result.
5. Extract the authorization `code`, validate expected state when the SDK exposes it, and exchange the code once.
6. Remove sensitive callback parameters from navigation state and route to the authenticated screen.

Do not combine fragment access-token examples with `exchangeCodeForSession`. Handle both cold-start callbacks and callbacks received while the app is running, using the router or linking subscription already established by the project.

## Verification

```bash
xcrun simctl openurl booted "myapp://profile"
adb shell am start -a android.intent.action.VIEW -d "myapp://profile"
```

For Maestro, launch the app normally and use `openLink` for the deep link. Inspect the hierarchy before and after opening it.

Use [scripts/test-deep-link.sh](scripts/test-deep-link.sh) for a booted local simulator or emulator. It opens only the URL supplied; it does not prove Universal Link or App Link domain verification.

## Security

- Allowlist redirect URIs exactly.
- Never log callback URLs containing codes or tokens.
- Validate destination parameters before routing.
- Keep privileged actions behind an authenticated authorization check even when reached through a deep link.
