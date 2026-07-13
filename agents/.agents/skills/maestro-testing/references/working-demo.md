# Working Demo Pattern

## Contents

- [Purpose](#purpose)
- [Discovery](#discovery)
- [Maintained Flow](#maintained-flow)
- [Project-Specific Overlays](#project-specific-overlays)

## Purpose

Use this pattern to turn a live, inspected interaction into a repeatable flow. Replace every placeholder with values observed from the current hierarchy.

## Discovery

1. List available devices.
2. Inspect the current screen.
3. Run a short inline flow that reaches the target state.
4. Re-inspect and verify the result.
5. Save a maintained YAML flow only after selectors are stable.

## Maintained Flow

```yaml
appId: ${MAESTRO_APP_ID}
---
- launchApp
- tapOn:
    id: email_input
- inputText: ${TEST_EMAIL}
- tapOn:
    id: submit_button
- assertVisible: Dashboard
- takeScreenshot: dashboard
```

Use exact hierarchy text or IDs. If visible text is part of a longer accessibility label, use an explicit regular expression that matches the real full string.

## Project-Specific Overlays

Development clients may show launchers, update prompts, or debug menus. Do not add universal dismissal steps. Inspect the current screen and place any required conditional flow in the application repository, where its selector and expected lifecycle can be maintained with that app.
