---
name: visual-regression-testing
description: Capture and compare deterministic web or mobile UI baselines across approved viewport or device matrices, using existing screenshot tooling, controlled data, dynamic-region masking, accessibility-tree evidence, and reviewable failure artifacts. Use for visual regression, screenshot diff, pixel comparison, baseline update, responsive visual validation, or UI change detection.
metadata:
  mode: operator
  risk: medium
  evidence: required
  cleanup: required
---

# Visual Regression Testing

Use the repository's existing screenshot framework whenever possible. Load `agent-browser` for web interaction and `maestro-testing` for mobile capture; this skill owns baseline/diff evidence and update discipline.

## Preflight

- Identify the approved baseline source, target revision, browsers/devices, viewports, pixel density, theme, locale, fonts, timezone, reduced-motion setting, and data fixtures.
- Establish the allowed diff threshold and review owner before comparison.
- Confirm the runtime is healthy and deterministic. Disable animations and stabilize data through project-supported test hooks.

## Discovery

Inspect Playwright/Cypress/Storybook/Chromatic/Percy configuration, screenshot directories, CI artifacts, Maestro flows, existing masks, and baseline update commands. Do not introduce a second visual framework when the project already owns baselines.

## Execute

1. Reproduce the baseline environment exactly and run the smallest existing visual suite.
2. Capture current screenshots using the same flow, viewport/device, font set, theme, and fixture state.
3. Mask only explicitly approved nondeterministic regions such as clocks or generated IDs; do not mask the changed feature.
4. Compare through the existing framework. For a local exact ImageMagick comparison when already installed:

   ```bash
   magick compare -metric AE baseline.png current.png diff.png
   ```

   Treat a non-zero exit caused by pixel differences as a comparison result, not automatically as tool failure.
5. Inspect the diff image and accessibility/DOM hierarchy for structural changes that pixels alone cannot explain.
6. Update baselines only after confirming the observed change is intended and limiting the update to reviewed files.

## Evidence

Record revision, baseline identity, tool/version, page/flow, viewport/device matrix, environment controls, threshold, changed-pixel or framework diff result, baseline/current/diff artifact paths, hierarchy observation, and reviewer decision. Report each matrix cell separately.

## Recovery

- Classify noise as font/rendering, animation/timing, dynamic data, viewport/device mismatch, missing asset, runtime failure, or genuine UI change.
- Make at most two focused stabilization attempts per class while preserving the same intended UI state.
- If environments cannot match, report `UNVERIFIED`; do not raise thresholds until the diff disappears.

## Cleanup

Remove temporary screenshots and test data, restore animation/time/network overrides, close browser/device sessions created for the test, and retain only requested failure artifacts or reviewed baselines.

## Stop Conditions

Stop baseline updates when the expected design is ambiguous, the baseline source is stale or untrusted, environment parity cannot be established, the diff spans unrelated pages, or review approval required by the project is absent.

## Destructive Boundaries

Do not bulk-regenerate baselines, overwrite approved images, mask broad UI regions, or accept higher global thresholds merely to make a run pass. Never update production content to stabilize screenshots.
