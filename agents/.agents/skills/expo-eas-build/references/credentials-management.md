# EAS Credentials Management

## Contents

- [Default Strategy](#default-strategy)
- [iOS](#ios)
- [Android](#android)
- [Submission Credentials](#submission-credentials)
- [Rotation](#rotation)

## Default Strategy

Prefer EAS-managed build credentials unless the project has a documented reason to manage files itself.

```bash
npx eas-cli@latest credentials
```

Use the interactive command and current `--help` output. Do not rely on historical `--push` or `--clear` flags without confirming they exist in the installed CLI.

## iOS

EAS can manage distribution certificates and provisioning profiles through the Apple Developer account. Before changing them:

1. Confirm the bundle identifier and Apple team.
2. Inspect which profile and certificate active builds use.
3. Coordinate revocation because certificates may sign multiple applications.
4. Never commit `.p12`, `.mobileprovision`, passwords, or exports.

## Android

Keep the upload keystore backed up and access-controlled. Google Play App Signing and the local upload key have different roles; do not rotate either without checking the store configuration and recovery process.

Never commit keystores, aliases, or passwords. Use the current EAS credential workflow or a reviewed `credentials.json` excluded from version control.

## Submission Credentials

Prefer short-lived or managed authentication where supported. If Google Play requires a service-account JSON file, store it in the CI or EAS secret system and materialize it only for the submission step. Do not base64-encode and print it in shell commands.

Keep Apple account identifiers and store app IDs in environment configuration when the project needs them; keep passwords and private keys in secret storage.

## Rotation

1. Identify every build or app using the credential.
2. Create and validate the replacement before revoking the old credential.
3. Run a non-production build or submission.
4. Revoke only after the replacement is confirmed.
5. Update the team's recovery documentation without recording secret values.
