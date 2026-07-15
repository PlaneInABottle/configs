# iOS Testing and Release Lifecycle

## Contents

- [Choose the build path](#choose-the-build-path)
- [Pre-build verification](#pre-build-verification)
- [Candidate and device testing](#candidate-and-device-testing)
- [TestFlight](#testflight)
- [Submission](#submission)
- [Release and monitoring](#release-and-monitoring)
- [Recovery](#recovery)
- [Official sources](#official-sources)

## Choose the build path

- Use the project's established Xcode, CI, or cloud-build path. Do not initialize a second release
  system when one already exists.
- For Expo/EAS projects, load `expo-eas-build` and inspect `eas.json`, app config, remote versioning,
  credentials strategy, and current CLI help.
- Prefer managed signing only when it matches project policy. Never rotate or regenerate signing
  assets to solve an unrelated build error.
- Increment the build number for every new uploaded binary; keep the marketing version aligned with
  the App Store version record.

## Pre-build verification

- Require an identified clean revision and preserve unrelated local changes.
- Run repository-native compile/type, lint, unit, dependency, security, and configuration checks.
- Verify bundle ID, app name, icon, splash screen, permissions, privacy manifest inputs, minimum OS,
  supported devices, native modules, runtime version, and environment selection.
- Confirm public support/privacy pages and final store copy before freezing the candidate.

## Candidate and device testing

- Create a production-like preview or archive before the final submission artifact when the build
  system supports it.
- Test install, first launch, upgrade, relaunch, offline behavior, background/foreground transitions,
  permissions, deep links, notifications, persistence, deletion, accessibility, dark/light themes,
  long content, and failure states relevant to the app.
- Test on a physical iPhone for device-only behavior. Test iPad only when supported.
- The iOS Simulator requires macOS. A cloud service can build from Linux, but a simulator build still
  needs a Mac-hosted simulator to run. Use a physical device, cloud Mac, or hosted device service when
  local macOS is unavailable.
- Use Maestro or the project's UI framework for repeatable smoke flows, while retaining manual device
  checks for platform integration.

## TestFlight

- Upload only when beta distribution is authorized and wait for Apple processing.
- Complete beta information and export questions truthfully.
- Start with internal testers where possible; verify current requirements before external testing.
- Record build, group, tester access, install result, sessions, crashes, feedback, and resolved issues.
- Do not treat a processed TestFlight build as approval for App Store release.

## Submission

- Select the exact tested build and reconcile its metadata and declarations.
- Verify review contact, login/demo instructions, notes, attachments, content rights, privacy, age,
  export, price, countries, and release mode.
- Run a final smoke test from the same build before `Add for Review`.
- Add and submit only when explicitly authorized; capture submission status and timestamp without
  exposing account data.
- Monitor App Review messages and answer with focused evidence. Do not change unrelated declarations
  merely to make a rejection disappear.

## Release and monitoring

- Prefer manual release for a first launch when the user wants control after approval.
- Automatic, scheduled, manual, and phased release are materially different; verify the chosen mode.
- After release, verify the live product page, installability in intended regions, correct version,
  privacy/support links, screenshots, crash signals, reviews, and critical app flows.
- Keep a short observation window and explicit thresholds for halting or issuing a fix.

## Recovery

- Before release, withdraw or replace only through supported App Store Connect controls.
- A rejected or invalid binary requires a higher build number; do not overwrite an uploaded build.
- A halted phased release prevents further exposure but does not remove the build from users who
  already received it.
- For a released defect, prepare a focused corrective update. Use an OTA mechanism only when the app
  already has a compatible, verified OTA policy and the change does not require a native rebuild.

## Official sources

Re-verified 2026-07-15:

- [TestFlight overview](https://developer.apple.com/help/app-store-connect/test-a-beta-version/testflight-overview/)
- [Overview of submitting for review](https://developer.apple.com/help/app-store-connect/manage-submissions-to-app-review/overview-of-submitting-for-review)
- [Select an App Store version release option](https://developer.apple.com/help/app-store-connect/manage-your-apps-availability/select-an-app-store-version-release-option)
