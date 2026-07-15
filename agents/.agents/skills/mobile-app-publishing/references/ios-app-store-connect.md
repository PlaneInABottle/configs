# iOS App Store Connect Field and Console Guide

Use current App Store Connect and Apple documentation as the final authority. Labels and navigation
can change.

## Contents

- [Product identity and listing](#product-identity-and-listing)
- [App Privacy](#app-privacy)
- [Age rating](#age-rating)
- [DSA trader status](#dsa-trader-status)
- [Export compliance](#export-compliance)
- [Review information](#review-information)
- [Build and release controls](#build-and-release-controls)
- [Attached-Chrome lessons](#attached-chrome-lessons)
- [Official sources](#official-sources)

## Product identity and listing

- Confirm the bundle ID against the signed configuration. Confirm version and build against the
  artifact, not only a metadata file.
- Choose the primary category from the app's core shipped function.
- Answer content-rights questions from licenses, attribution records, and third-party provenance.
- Keep name, promotional text, description, keywords, screenshots, and previews consistent with the
  tested build. Do not advertise future features.
- Verify support, marketing, and privacy URLs in a logged-out browser.
- Re-check current media dimensions and encoding requirements before upload.
- Claim accessibility support only after testing the exact capability.

## App Privacy

- Inspect source, native modules, SDKs, telemetry, crash reporting, advertising, authentication,
  storage, and real network behavior.
- Include third-party partner behavior. Local-only data is not automatically an Apple collection
  disclosure, but off-device transmission can be.
- Keep the public privacy policy consistent with the answers.
- `Publish` in App Privacy publishes the privacy declaration; it does not release the app binary. It
  is still an external compliance claim.

## Age rating

- Answer every content descriptor and capability from shipped behavior.
- Do not select the Kids category merely because the app is harmless; that category creates broader
  obligations and constrains future versions.
- Apple permits an informed override to a higher rating. Record the product, EULA, or policy reason.
- Never reduce truthful answers to obtain a preferred rating.

## DSA trader status

- The account holder must self-assess whether EU distribution relates to a trade, business, craft, or
  profession.
- Revenue, ads, promotion of services, VAT status, business status, and professional-purpose
  development can affect the answer.
- A hobbyist with no intention to commercialize may be a non-trader, but this is not an automatic
  classification or legal advice. Reassess when circumstances change.

## Export compliance

- Inventory encryption the app uses, accesses, contains, implements, or incorporates.
- Check Apple-platform cryptography and third-party implementations separately. HTTPS does not answer
  whether a bundled storage or cryptography library exists.
- Inspect the final binary and questionnaire before setting `ITSAppUsesNonExemptEncryption` or a
  framework equivalent.
- Do not claim an exemption or exclude a region merely to bypass documentation. Use Apple support or
  qualified export counsel for uncertain classifications.

## Review information

- Use a reachable contact and an international phone number in E.164 form:
  `+<country-code><subscriber-number>`.
- Mark sign-in required only when the reviewer needs credentials. Supply stable demo access when any
  meaningful area is restricted.
- Give a deterministic review path covering core functionality, special gestures, local-only
  behavior, hardware, and limitations.
- Never store a real password in repository documentation or a global skill.

## Build and release controls

- An app-version record and saved metadata are not an uploaded build.
- A processed build must match the version record and bundle ID before selection.
- Choose manual release when approval should not make the app public immediately.
- `Add for Review`, final submission, and public release are separate external mutations.
- Button enablement does not prove missing forms, build testing, agreements, or policy decisions are
  complete.

## Attached-Chrome lessons

- If Apple or its identity provider rejects an automation-launched browser, authenticate in normal
  Chrome with a dedicated profile and localhost CDP port. Do not add stealth flags.
- A user may click in the same headed window. Read the current URL and take a new interactive snapshot
  immediately before every mutation.
- Dynamic saves and modals invalidate refs. Save one logical section, then read back values and errors.
- Save-button disablement is evidence of no pending edits; reload/read-back is stronger persistence
  evidence.
- App Privacy `Publish` and app-version release are different. Always state what was published.
- If a tab stalls, preserve authenticated Chrome, attach with a fresh live-session name, open the same
  URL in a new tab, and close only the verified stale tab if needed.

## Official sources

Re-verified 2026-07-15:

- [Manage app privacy](https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-privacy/)
- [Set an app age rating](https://developer.apple.com/help/app-store-connect/manage-app-information/set-an-app-age-rating/)
- [Manage EU DSA trader requirements](https://developer.apple.com/help/app-store-connect/manage-compliance-information/manage-european-union-digital-services-act-trader-requirements)
- [Overview of export compliance](https://developer.apple.com/help/app-store-connect/manage-app-information/overview-of-export-compliance/)
- [Upload builds](https://developer.apple.com/help/app-store-connect/manage-builds/upload-builds)
- [Overview of publishing on the App Store](https://developer.apple.com/help/app-store-connect/manage-your-apps-availability/overview-of-publishing-your-app-on-the-app-store)
