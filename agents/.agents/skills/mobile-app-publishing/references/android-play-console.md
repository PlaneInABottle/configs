# Android Google Play Console Field and Console Guide

Use current Play Console and Google Play policy as the final authority. The dashboard shows different
forms depending on app behavior and account status.

## Contents

- [Store listing](#store-listing)
- [Privacy, ads, and access](#privacy-ads-and-access)
- [Data safety](#data-safety)
- [Content rating and target audience](#content-rating-and-target-audience)
- [Health apps and other declarations](#health-apps-and-other-declarations)
- [Testing and production gates](#testing-and-production-gates)
- [Attached-Chrome lessons](#attached-chrome-lessons)
- [Official sources](#official-sources)

## Store listing

- Keep title, short/full descriptions, category, tags, icon, feature graphic, screenshots, and video
  consistent with the tested artifact.
- Do not show future features or results the app cannot deliver.
- Verify public contact and privacy URLs while logged out and without geographic restrictions.
- Re-check current asset dimensions, text limits, and preview rules before upload.
- Treat price, countries, and app/game type as material product decisions.

## Privacy, ads, and access

- Ensure the policy matches actual access, collection, use, sharing, retention, deletion, and security
  behavior, including third-party SDKs and sensitive health or fitness data.
- Include ads delivered by SDKs, not only ads written by the app team.
- If all reviewer-visible features work without login, declare unrestricted access. Otherwise provide
  deterministic instructions and stable demo access.
- If account creation exists, test deletion and verify Google's current account-deletion fields.
- Never place credentials in repository docs or a global skill.

## Data safety

- Inventory permissions, SDKs, native modules, APIs, background work, analytics, crash reporting,
  ads, authentication, cloud sync, and support tools.
- Determine whether data leaves the device, why it is used, whether it is shared, whether collection
  is optional, how it is protected in transit, and whether users can request deletion.
- Include third-party behavior. No custom backend does not prove that no data is collected.
- Keep the privacy policy and shipped behavior consistent with every answer.

## Content rating and target audience

- Answer from actual content and interactions, including communication, user-generated content, web
  access, violence, substances, sexuality, gambling, contests, and location sharing.
- Do not lower truthful answers to obtain a preferred rating.
- Choose intended age groups from product intent and design, not only from absence of dangerous
  content. Child age groups can invoke Families obligations and SDK restrictions.
- Reconcile the audience selection, rating, store language, screenshots, and design.

## Health apps and other declarations

- Complete the Health apps form when the dashboard requires it, including a no-health declaration
  for apps without health functionality.
- Exercise routine and workout recording belongs under `Activity and Fitness` in Google's current
  taxonomy.
- Distinguish wellness/fitness from diagnosis, treatment, or regulated medical claims.
- Answer government, financial, news, advertising-ID, sensitive-permission, and account-specific
  forms only from actual behavior and evidence.

## Testing and production gates

- Internal, closed, open, and production tracks are distinct external states.
- Google currently requires newly created personal developer accounts to run a closed test with at
  least 12 opted-in testers for 14 continuous days before applying for production access. Verify that
  this rule applies to the account and confirm the live dashboard counter.
- An invitation list does not prove opt-in or continuous duration.
- Artifact upload, track release, production-access application, `Send for review`, managed
  publication, and public rollout are separate mutations.

## Attached-Chrome lessons

- Google identity may reject automation-launched Chromium as insecure. Authenticate in normal Chrome
  with a dedicated profile and localhost CDP port; do not use stealth flags.
- A human may click in the shared headed window. Read URL and snapshot immediately before mutation.
- App content cards rerender after saves and invalidate refs. Verify the card's completed/actioned
  state and read back material answers.
- `Save`, declaration submission, `Send for review`, release creation, and rollout have different
  consequences. Read the surrounding heading before clicking.
- A dashboard can show setup complete while production remains blocked by testing or account review.

## Official sources

Re-verified 2026-07-15:

- [Prepare your app for review](https://support.google.com/googleplay/android-developer/answer/9859455?hl=en)
- [Provide Data safety information](https://support.google.com/googleplay/android-developer/answer/10787469?hl=en)
- [Provide the Health apps declaration](https://support.google.com/googleplay/android-developer/answer/14738291?hl=en)
- [Health Content and Services policy](https://support.google.com/googleplay/android-developer/answer/16679511?hl=en)
- [Testing requirements for new personal accounts](https://support.google.com/googleplay/android-developer/answer/14151465?hl=en)
- [Publish your app](https://support.google.com/googleplay/android-developer/answer/9859751?hl=en)
