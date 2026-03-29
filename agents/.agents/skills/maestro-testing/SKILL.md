---
name: maestro-testing
description: "Run end-to-end mobile tests with Maestro framework. Use when: writing mobile E2E test flows, testing React Native apps on simulators/emulators, capturing screenshots for verification, managing Xcode simulators or Android emulators, running automated mobile tests, or setting up mobile CI testing. Triggers on 'test mobile app', 'e2e test', 'maestro flow', 'run simulator test', 'screenshot test', or any mobile testing task."
---

# Maestro Testing

## Overview

Maestro is a mobile E2E testing framework that uses declarative YAML flow files to automate iOS and Android apps. It requires no SDK integration — just install the CLI and point it at your app. Works with iOS (Xcode simulators) and Android (emulators).

**Composes with:**
| Skill | Relationship |
|---|---|
| react-native-expo | App under test — Maestro tests the built app |
| ai-native-workflow | Verification patterns — Maestro provides screenshot evidence |
| agent-browser | Complementary — agent-browser handles web, Maestro handles mobile |

## Quick Start

```bash
# 1. Install Maestro CLI
curl -Ls "https://get.maestro.mobile" | bash

# 2. Write a flow (save as login.yaml)
# appId: com.example.myapp
# ---
# - launchApp
# - assertVisible: "Welcome"

# 3. Run on a booted simulator or emulator
maestro test login.yaml

# 4. Run on a specific device
maestro test --device <UDID> login.yaml
```

See `scripts/setup-maestro.sh` for automated environment checks.

## Flow File Syntax

Every flow is a YAML file. The first section (before `---`) sets metadata; the rest defines commands.

### Commands

| Command | Description | Example |
|---|---|---|
| `launchApp` | Launch or relaunch the app | `- launchApp` |
| `tapOn` | Tap an element by selector | `- tapOn: "Login"` |
| `longPressOn` | Long-press an element | `- longPressOn: "Item"` |
| `inputText` | Type text into a focused field | `- inputText: "user@example.com"` |
| `eraseText` | Delete characters from input | `- eraseText: 20` |
| `assertVisible` | Assert element is visible | `- assertVisible: "Dashboard"` |
| `assertNotVisible` | Assert element is absent | `- assertNotVisible: "Error"` |
| `swipe` | Swipe in a direction | `- swipe: { direction: DOWN }` |
| `scrollUntilVisible` | Scroll until target appears | `- scrollUntilVisible: { element: "Footer" }` |
| `waitForAnimationToEnd` | Wait for animations | `- waitForAnimationToEnd` |
| `extendedWaitUntil` | Wait for element with timeout | `- extendedWaitUntil: { visible: "Dashboard", timeout: 10000 }` |
| `takeScreenshot` | Capture screenshot | `- takeScreenshot: "login-done"` |
| `assertScreenshot` | Visual regression check | `- assertScreenshot: "login-screen"` (supports `thresholdPercentage`, `cropOn`) |
| `stopApp` | Kill the app | `- stopApp` |
| `evalScript` | Run inline JavaScript | `- evalScript: ${output.var = "x"}` |
| `runFlow` | Import a subflow file | `- runFlow: { file: subflows/setup.yaml, env: { KEY: val } }` |
| `copyTextFrom` | Copy text from element | `- copyTextFrom: { id: "email" }` |
| `pasteText` | Paste clipboard into focused field | `- pasteText` |
| `hideKeyboard` | Dismiss keyboard | `- hideKeyboard` |
| `openLink` | Open a deep link | `- openLink: "myapp://settings"` |
| `repeat` | Repeat until condition met | `- repeat: { commands: [...], whileVisible: "Loading" }` (supports `whileVisible`, `whileTrue`, `max`) |
| `back` | Navigate back (Android only; use `swipe` direction or `tapOn` back button on iOS) | `- back` |
| `assertTrue` | Assert JS expression is truthy | `- assertTrue: ${output.count > 0}` |
| `travel` | Simulate GPS coordinates | `- travel: { latitude: 37.77, longitude: -122.42 }` |

## Flow Structure

```yaml
appId: com.example.myapp
tags:
  - smoke
  - login
env:
  EMAIL: ${EMAIL}       # Shell env var injection
  PASSWORD: ${PASSWORD}
---
- launchApp
- assertVisible: "Welcome"
- tapOn: "Login"
```

**Key rules:**
- `appId` is required — identifies the target app.
- `---` separates metadata from commands.
- `tags` enable selective test runs: `maestro test --include-tags smoke .`
- `env` maps shell variables into the flow.
- Subflows can be imported with `runFlow` and accept `env` overrides.

## Selector Strategies

| Strategy | Syntax | Example |
|---|---|---|
| **Text** (default) | Plain string | `- tapOn: "Submit"` |
| **ID** | `id:` key | `- tapOn: { id: "login_button" }` |
| **Index** | `index:` key | `- tapOn: { index: 0 }` |
| **XPath** | `xpath:` key | `- tapOn: { xpath: "//XCUIElementTypeButton[@name='Go']" }` |
| **Point** | `point:` key | `- tapOn: { point: "50%,50%" }` |
| **Optional** | `optional: true` | `- tapOn: { text: "Skip", optional: true }` |

The `optional` flag prevents test failure if the element is not found — useful for dismissable dialogs.

## Xcode Simulator Management

```bash
# List available simulators
xcrun simctl list devices available

# Boot a simulator
xcrun simctl boot <UDID>

# Install app on simulator
xcrun simctl install <UDID> /path/to/MyApp.app

# Launch app
xcrun simctl launch <UDID> com.example.myapp

# Shutdown
xcrun simctl shutdown <UDID>

# Open Simulator.app GUI
open -a Simulator
```

See `references/simulator-management.md` for full CLI reference.

## Android Emulator Management

```bash
# List available AVDs
emulator -list-avds

# Start emulator (headless)
emulator -avd <AVD_NAME> -no-window &

# Install APK
adb install /path/to/app.apk

# Launch app
adb shell am start -n com.example.myapp/.MainActivity

# Kill emulator
adb emu kill
```

See `references/simulator-management.md` for full CLI reference.

## Screenshot Verification

```yaml
- takeScreenshot: "home-screen"
# Maestro saves to ~/.maestro/tests/<timestamp>/screenshots/
```

For CI comparison workflows:
1. Capture baseline screenshots on a known-good build.
2. Run tests on new build.
3. Compare using image-diff tools (e.g., `pixelmatch`, `resemblejs`).

```bash
# Capture to custom path
maestro test --output screenshots/ flow.yaml
```

## Composing with Other Skills

| Scenario | Skills to Load |
|---|---|
| Testing a React Native app | `maestro-testing` + `react-native-expo` |
| CI pipeline for mobile tests | `maestro-testing` + `cicd-pipeline` |
| Screenshot-based verification | `maestro-testing` + `ai-native-workflow` |
| Hybrid web + mobile testing | `maestro-testing` + `agent-browser` |

## CI Integration

### GitHub Actions Example

```yaml
name: Mobile E2E Tests
on: [push, pull_request]

jobs:
  ios:
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v4
      - name: Set up Xcode
        uses: maxim-lobanov/setup-xcode@v1
        with:
          xcode-version: latest-stable
      - name: Install Maestro
        run: curl -Ls "https://get.maestro.mobile" | bash
      - name: Boot Simulator
        run: |
          UDID=$(xcrun simctl list devices available | grep "iPhone 15" | head -1 | grep -oE '[0-9A-F-]{36}')
          xcrun simctl boot "$UDID" || true
          echo "DEVICE_UDID=$UDID" >> $GITHUB_ENV
      - name: Build App
        run: xcodebuild -scheme MyApp -destination "id=$DEVICE_UDID" build
      - name: Run Maestro Tests
        run: |
          export PATH="$HOME/.maestro/bin:$PATH"
          maestro test --device "$DEVICE_UDID" .maestro/

  android:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Set up JDK
        uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: 17
      - name: Install Maestro
        run: curl -Ls "https://get.maestro.mobile" | bash
      - name: Run Android Tests
        uses: reactivecircus/android-emulator-runner@v2
        with:
          api-level: 34
          arch: x86_64
          script: |
            export PATH="$HOME/.maestro/bin:$PATH"
            adb install app/build/outputs/apk/debug/app-debug.apk
            maestro test .maestro/
```

## Anti-Patterns

- **Hard-coding waits**: Use `waitForAnimationToEnd` or `assertVisible` instead of `waitFor: 5000`.
- **Flaky selectors**: Prefer `id` or `text` over `xpath` or `index` — they break when UI changes.
- **One mega-flow**: Split into small focused flows and compose with `runFlow`.
- **Testing without app built**: Always build/install the app before running `maestro test`.
- **Ignoring optional flag**: Use `optional: true` for dismissable modals, rate prompts, permission dialogs.
- **No screenshots**: Add `takeScreenshot` at key points for CI debugging when tests fail.
- **Platform assumptions**: Use platform-specific subflows when iOS and Android differ.

## References

- [Maestro Documentation](https://maestro.mobile.dev)
- [Maestro GitHub](https://github.com/mobile-dev-inc/maestro)
- [Flow YAML Reference](https://maestro.mobile.dev/api-reference/commands)
- `references/maestro-flows.md` — Common flow patterns and reusable subflows
- `references/simulator-management.md` — iOS/Android device CLI reference
- `assets/flow-templates/` — Ready-to-use flow templates
