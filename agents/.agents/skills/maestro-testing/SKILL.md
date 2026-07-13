---
name: maestro-testing
description: Author, run, and debug mobile or web UI automation with Maestro MCP, local YAML flows, or Maestro Cloud. Use for live device inspection, simulator or emulator interaction, repeatable UI flows, flow syntax debugging, screenshots, and mobile end-to-end verification.
---

# Maestro Testing

Use the connected Maestro interface as the authority for tool names and required arguments. Do not translate examples from a different MCP wrapper by memory.

## Live MCP Workflow

1. List devices and select only an ID returned by the tool.
2. Inspect the current screen before choosing selectors.
3. Load the Maestro cheat sheet before unfamiliar commands, conditions, or multi-screen flows.
4. Run one coherent inline YAML flow for exploration; use files or a directory for maintained suites.
5. Re-inspect after navigation or state changes and capture a screenshot when visual evidence matters.

For the currently connected interface, use `list_devices`, `inspect_screen`, `run`, and `take_screenshot`. `run` accepts exactly one of inline YAML, files, or a directory. If another client exposes different names, inspect that client's tool schema first.

## Selector Discipline

- Copy visible text and IDs from the inspected hierarchy; do not infer labels from screenshots.
- Treat text selectors as full-string regular expressions. Use an anchored or explicit regex when matching part of a longer label.
- Prefer stable IDs or accessibility text over coordinates and indexes.
- Re-inspect when a selector fails before changing the flow.
- Avoid locale-specific workarounds unless reproduced on the current Maestro version and platform.

## Flow Guidance

```yaml
appId: com.example.app
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

- Provide a name to commands that require one, including `assertScreenshot` and screenshot commands.
- Use `openLink` for deep links.
- Use bounded waits for asynchronous state instead of fixed sleeps.
- Handle optional development overlays only when inspection proves they are present.
- Do not clear app state or keychain by default; do so only when test isolation requires it.

## Local and Cloud Runs

- Local: list devices, inspect, then run the flow on the selected device.
- Cloud: list valid cloud device pairs, submit the app and flows, then poll the returned run ID until terminal status.
- Pass device model and OS values exactly as returned by the cloud device listing.
- Keep credentials in the configured Maestro login or environment; never print API keys.

## References

- Load [references/maestro-flows.md](references/maestro-flows.md) for maintained YAML patterns.
- Load [references/simulator-management.md](references/simulator-management.md) only when direct simulator or emulator management is required.
- Treat [references/working-demo.md](references/working-demo.md) as an example, not universal startup behavior.
- Use [assets/flow-templates/](assets/flow-templates/) as starting points after replacing app-specific selectors and IDs.
