# Android Testing and Release Lifecycle

## Contents

- [Choose the build and signing path](#choose-the-build-and-signing-path)
- [Pre-build verification](#pre-build-verification)
- [Candidate and device testing](#candidate-and-device-testing)
- [Testing tracks](#testing-tracks)
- [Production review and publishing](#production-review-and-publishing)
- [Release monitoring](#release-monitoring)
- [Recovery](#recovery)
- [Official sources](#official-sources)

## Choose the build and signing path

- Use the project's established Gradle, CI, or cloud-build path. Do not initialize a parallel release
  system without a migration decision.
- For Expo/EAS projects, load `expo-eas-build` and inspect `eas.json`, app config, remote versioning,
  credentials strategy, and current CLI help.
- Determine whether Play App Signing is configured and who owns the upload key before the first
  release. Never regenerate a key to solve an unrelated build error.
- Use an Android App Bundle for Play distribution and increment `versionCode` for every upload.

## Pre-build verification

- Require an identified clean revision and preserve unrelated local changes.
- Run repository-native compile/type, lint, unit, dependency, security, manifest, and configuration
  checks.
- Verify package name, version name/code, app label, icon, splash screen, permissions, target/min SDK,
  native libraries, ABI support, signing configuration, and environment selection.
- Re-check current target API, native-library compatibility, and Play technical requirements from
  official sources before building.

## Candidate and device testing

- Create a production-like preview before the final AAB when supported.
- Test install, first launch, upgrade, relaunch, offline behavior, backgrounding, permissions, deep
  links, notifications, persistence, deletion, accessibility, dark/light themes, long content, and
  app-specific failures.
- Test on physical devices plus representative emulators or hosted devices. Include low-resource and
  current Android versions when relevant.
- Use Maestro or the project's UI framework for repeatable smoke flows, but retain manual checks for
  platform integration.
- Inspect Play pre-launch, crash, and ANR reports after an authorized test release.

## Testing tracks

- Start with internal testing for fast trusted-team distribution when appropriate.
- Use closed testing for controlled external validation and for account production-access gates.
- Verify tester eligibility, opt-in URL, active enrollment, continuous duration, feedback, installs,
  crashes, and resolved issues from Play Console.
- Do not assume that uploading an AAB makes it available; release creation, review, and track rollout
  are separate states.

## Production review and publishing

- Reconcile the tested AAB with listing copy, screenshots, Data safety, permissions, audience,
  content rating, health declaration, countries, and release notes.
- Decide standard versus managed publishing before sending changes for review. Managed publishing can
  hold most approved changes until an authorized publication action.
- For a first production release, staged rollout may not be available; verify current console options.
- Create the production release, send changes for review, and roll out only when each action is
  explicitly authorized.

## Release monitoring

- Verify the live listing, intended countries, installability, current version, policy/support links,
  crash/ANR rate, reviews, and core flows.
- Use a staged rollout for eligible updates when the project has monitoring thresholds and an owner
  for percentage increases.
- Record rollout percentage, countries, observation window, and halt criteria.

## Recovery

- A rejected or invalid artifact requires a higher version code; do not overwrite an uploaded AAB.
- Halt an eligible staged rollout when authorized guardrails fail. Users who already received the
  build stay on it.
- Ship a corrective release with a higher version code. Do not attempt a downgrade.
- Unpublishing prevents new availability but does not remove existing installs or necessarily delete
  the app record.
- Use an OTA mechanism only when an existing, verified compatibility and rollback policy permits it.

## Official sources

Re-verified 2026-07-15:

- [Create and set up an app and App Bundle](https://support.google.com/googleplay/android-developer/answer/9859152?hl=en)
- [Set up an internal, closed, or open test](https://support.google.com/googleplay/android-developer/answer/9845334?hl=en)
- [Control review and publication with managed publishing](https://support.google.com/googleplay/android-developer/answer/9859654?hl=en-EN)
- [Release updates with staged rollouts](https://support.google.com/googleplay/android-developer/answer/6346149?hl=en)
