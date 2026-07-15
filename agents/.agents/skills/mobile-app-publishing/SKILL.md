---
name: mobile-app-publishing
description: Prepare, test, submit, publish, monitor, and recover iOS App Store and Android Google Play releases. Use for mobile release readiness, signing and versioning, store metadata and compliance forms, App Privacy or Data safety, App Store Connect or Play Console, TestFlight or Play testing tracks, production-access gates, review submission, managed or manual publication, rollout, and post-release verification across native, CI, or Expo/EAS projects.
metadata:
  mode: operator
  risk: high
  evidence: required
  cleanup: required
---

# Mobile App Publishing

Operate the complete mobile publishing lifecycle while keeping preparation, build creation, beta
distribution, store review, and public release as separate authorization boundaries.

Compose existing skills instead of duplicating them:

- Load `agent-browser` for interactive App Store Connect or Play Console work.
- Load `release-operator` for an actual submission, rollout, release, halt, or rollback.
- Load `expo-eas-build` when the repository uses Expo/EAS; otherwise follow the verified Xcode,
  Gradle, or CI runbook.
- Load `maestro-testing` when repeatable mobile UI flows add useful acceptance evidence.

## Reference Router

- For iOS forms and policy declarations, read
  [`references/ios-app-store-connect.md`](references/ios-app-store-connect.md).
- Before an iOS build, TestFlight distribution, App Review submission, release, or recovery, read
  [`references/ios-testing-and-release.md`](references/ios-testing-and-release.md).
- For Android listings and App content declarations, read
  [`references/android-play-console.md`](references/android-play-console.md).
- Before an Android build, testing-track release, production review, rollout, or recovery, read
  [`references/android-testing-and-release.md`](references/android-testing-and-release.md).
- For a cross-platform release, read all four and reconcile shared product claims with platform-specific
  behavior rather than copying answers blindly.

## Preflight

- Read project instructions, app configuration, release checklist, branch state, build profiles, CI,
  previous release evidence, and current store-console state.
- Record the exact authorized boundary per platform: inspect, edit metadata, publish declarations,
  create/upload an artifact, distribute a beta, invite testers, add/send for review, apply for
  production access, publish, roll out, halt, or withdraw.
- Confirm account roles, agreements, app records, identifiers, version policy, signing ownership,
  target tracks, countries, price, release mode, success criteria, and recovery path.
- Verify fast-moving Apple and Google requirements against current official documentation before
  legal, privacy, encryption, age/audience, technical, tester, or rollout decisions.
- Never print or commit credentials, certificates, profiles, keystores, upload keys, service-account
  files, browser state, tester lists, personal contact details, or account identifiers.

## Discovery

Create one evidence packet with platform-specific differences:

- product name, bundle/package identifiers, marketing versions, build/version codes, entitlements,
  permissions, native modules, SDK levels, and supported devices;
- repository revision, lockfile, tests, dependencies, vulnerabilities, native configuration, CI, and
  canonical build commands;
- login, accounts, ads, purchases, subscriptions, hardware, health/medical behavior, target users,
  data storage/transfer/deletion, SDK behavior, network destinations, and encryption;
- listing copy, screenshots, media rights, support/privacy URLs, countries, price, reviewer access,
  beta groups, production gates, monitoring, and recovery ownership.

Treat unknown facts as blockers or owner questions, not as permission to choose the least restrictive
store answer.

## Execute

1. Make the intended release revision reproducible: reconcile branches as authorized, versions,
   changelog, lockfile, identifiers, configuration, and assets.
2. Run repository-native compile/type, lint, unit, dependency, security, and platform-configuration
   checks before spending build resources.
3. Complete and verify each platform's listing and compliance forms from the evidence packet.
4. When artifact creation is authorized, use the established signing/build path. Build a
   production-like candidate before the final store artifact when supported.
5. Install and test on representative physical devices plus useful simulators, emulators, or hosted
   devices. Verify upgrade, persistence, offline/background behavior, permissions, deletion, and core
   product flows.
6. Use TestFlight and Play testing tracks as applicable. Record real install, crash, session,
   feedback, opt-in, and duration evidence.
7. Select only tested processed artifacts and reconcile their behavior with every listing,
   screenshot, privacy, audience, health, encryption, and reviewer-access claim.
8. Submit for review only when explicitly authorized. Monitor reviewer messages and resolve the
   smallest contradicted behavior or claim.
9. Publish or roll out only when explicitly authorized. Verify the public listing, installability,
   version, countries, support/privacy pages, crash signals, reviews, and critical flows.

## Evidence

Report per platform: revision, version/build, artifact provider and identifier/digest, signing
strategy without secrets, verification commands, device/OS matrix, beta/test-track state, completed
declarations, reviewer access, countries/price, submission and review status, publishing mode,
rollout state, public availability, and crash/ANR observations. State clearly what was not built,
submitted, or released.

## Recovery

- Classify failures as repository, dependency, signing, build, upload/processing, device test,
  declaration, reviewer access, policy review, publication, or runtime regression.
- Make at most two focused reversible attempts before escalating an unexplained failure.
- Do not rotate signing assets, rewrite truthful declarations, or rebuild from a different revision
  merely to clear a console error.
- Before publication, replace or withdraw only through supported store workflows and explicit
  authorization.
- After publication, halt eligible rollouts or availability only when authorized; users who already
  installed a build generally require a corrective update.

## Cleanup

- Remove temporary exported credentials, browser state, sensitive screenshots, and local artifacts
  not retained by project policy.
- Preserve immutable build, test, store-review, rollout, reviewer-message, and recovery evidence in
  the approved system.
- Close only agent-owned browser sessions or verified stale tabs; do not terminate a human's
  authenticated Chrome profile unless asked.

## Stop Conditions

Stop before the next boundary when authorization, account role, signed revision, build path, signing
ownership, declaration evidence, device testing, reviewer access, tester eligibility, production
access, release strategy, monitoring, or recovery ownership is missing. Escalate legal
self-assessments to the account holder or qualified counsel when evidence is insufficient.

## Destructive Boundaries

Never create or rotate signing material, upload an artifact, invite testers, publish a declaration,
accept an agreement, change price/countries, submit for review, apply for production access, publish,
roll out, halt, withdraw, or unpublish unless the user authorized that exact mutation. An enabled
button, completed dashboard, or successful build does not expand authorization.
