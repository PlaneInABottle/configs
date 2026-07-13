---
name: expo-eas-build
description: Configure and operate Expo Application Services builds, updates, credentials, environment variables, submissions, and release profiles. Use when a project uses EAS Build, EAS Update, EAS Submit, or Expo-managed store credentials.
---

# Expo EAS Build

Inspect the installed Expo SDK, `eas.json`, app config, package manager, credentials strategy, and current EAS CLI help before changing release configuration.

## CLI

Prefer a project-scoped or ephemeral current CLI rather than an unpinned global installation:

```bash
npx eas-cli@latest build:configure
npx eas-cli@latest build --profile preview --platform android
```

Pin the CLI in CI when reproducibility matters.

## Profiles

Keep only profiles the project uses. A common starting point is development, preview, and production, but profile names and distribution modes are not mandatory.

```json
{
  "build": {
    "development": { "developmentClient": true, "distribution": "internal" },
    "preview": { "distribution": "internal" },
    "production": { "autoIncrement": true }
  }
}
```

Do not force paid resource classes, signing files, channels, or environment names into a generic template.

## Credentials and Secrets

- Prefer EAS-managed signing credentials unless the project has a documented manual process.
- Never commit keystores, certificates, provisioning profiles, service-account JSON, or credential exports.
- Choose `sensitive` or `secret` visibility for credentials according to current EAS semantics; do not demonstrate API keys as plaintext variables.
- Verify `eas env:create --help` before creating variables because visibility and environment options evolve.
- Keep store submission identities out of reusable committed templates.

## Updates

- Publish only changes compatible with the target runtime version.
- Rebuild for native dependency, native configuration, permission, or runtime changes.
- Verify channel, branch, runtime version, and rollout before publishing.
- Test rollback or republish procedures in a non-production channel first.

## Submission

Build and test a production-like artifact before submission. Confirm the app already exists in the store console, review track or TestFlight destination, and inspect current EAS Submit requirements.

## References

- [references/eas-build-profiles.md](references/eas-build-profiles.md)
- [references/credentials-management.md](references/credentials-management.md)
- [references/ota-updates.md](references/ota-updates.md)
- [assets/eas-configs/eas.json](assets/eas-configs/eas.json)
