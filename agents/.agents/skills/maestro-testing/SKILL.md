---
name: maestro-testing
description: "Mobile E2E testing and live device control with Maestro MCP. Use when: implementing mobile features, debugging React Native apps, verifying UI on simulators/emulators, writing E2E test flows, running automated tests, or any mobile UI task."
---

# Maestro Testing

## Overview

Maestro is a mobile E2E testing framework — two ways to use it:

1. **Maestro MCP** — live device control (like a browser for mobile). Use this during feature implementation and debugging to verify UI directly.
2. **YAML flows** — repeatable test scripts. Write these only *after* a feature is validated via MCP, for CI and regression runs.

**Rule: MCP during implementation → YAML flows after validation.** Don't waste time scripting flows for features still in flux.

**Composes with:**
| Skill | Relationship |
|---|---|
| react-native-expo | App under test — Maestro tests the built app |
| ai-native-workflow | Verification patterns — Maestro provides screenshot evidence |
| agent-browser | Complementary — agent-browser handles web, Maestro handles mobile |

## Maestro MCP (Live Device Control)

```bash
maestro mcp  # Starts the MCP server
```

### Available MCP Tools

| Tool | What it does |
|------|--------------|
| `list_devices` | List available simulators/emulators |
| `launch_app` | Launch an app by bundle ID |
| `inspect_view_hierarchy` | Dump current screen's UI tree as CSV |
| `tap_on` | Tap element by text, ID, or regex |
| `input_text` | Type into focused field |
| `take_screenshot` | Capture screen |
| `run_flow` | Execute inline YAML directly |
| `scroll` | Scroll in direction |
| `back` | Navigate back |

## Quick Start

```bash
# 1. Install Maestro CLI
curl -fsSL "https://get.maestro.mobile.dev" | bash
# Note: URL is .mobile.dev NOT .mobile

# 2. Verify
export PATH="$HOME/.maestro/bin:$PATH"
maestro --version

# 3. Write a flow (save as login.yaml)
# appId: com.example.myapp
# ---
# - launchApp
# - assertVisible: "Welcome"

# 4. Run on a booted simulator or emulator
maestro test login.yaml

# 5. Run on a specific device
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

## ⚠️ Expo Dev Client Bootstrap (Critical)

React Native / Expo dev builds show overlay screens before the app renders. Every flow with `launchApp` must handle this 3-step dismiss sequence:

```yaml
# Step 1: Tap Metro URL on "DEVELOPMENT SERVERS" screen
- runFlow:
    when:
      visible: "DEVELOPMENT SERVERS"
    commands:
      - tapOn: "http://localhost:8081"
      - waitForAnimationToEnd

# Step 2: Dismiss Expo "Continue" informational overlay
- runFlow:
    when:
      visible: "Continue"
    commands:
      - tapOn: "Continue"
      - waitForAnimationToEnd

# Step 3: Dismiss React Native dev menu (if still showing)
- runFlow:
    when:
      visible: "Reload"
    commands:
      - tapOn: "Reload"  # NOT "Go home" — that exits the app
      - waitForAnimationToEnd
```

**Why all 3?** The dev server screen (Step 1) connects to Metro. After JS loads, Expo shows an overlay describing the dev menu (Step 2, "Continue" button). Underneath it, the RN dev menu may be visible (Step 3) — tap "Reload" to dismiss it and show the app.

If you don't handle these, the app appears stuck on a blank/overlay screen. After running these 3 steps, the app should show its actual content.

**Wait for the JS bundle to fully render** after Metro connects — the bundle can take 10+ seconds to load. Use `extendedWaitUntil`:

```yaml
- extendedWaitUntil:
    visible: "Some text unique to your app's first screen"
    timeout: 30000
```

### Ready-to-use bootstrap flow

See `assets/flow-templates/expo-bootstrap.yaml` for a complete self-contained flow you can reuse across all flows. Reference it with:

```yaml
appId: com.yourapp
onFlowStart:
  - runFlow: .maestro/shared/expo-bootstrap.yaml
```

## 🔴 Known Gotchas

### 1. Turkish characters cause infinite hang ⏳

Maestro's `assertVisible`, `tapOn`, and `extendedWaitUntil` **hang indefinitely** (not fail, hang) when the search string contains these Turkish characters:
- `ş` `Ş` — ❌ hangs
- `ı` `İ` — ❌ hangs
- `ü` `Ü` — ❌ hangs  
- `ğ` `Ğ` — ❌ hangs
- `ç` `Ç` — ❌ hangs

Characters that DO work: `ö` `Ö` ✅, regular ASCII ✅

**Fix:** Match English/ASCII substrings only:
```yaml
# ❌ HANGS:
- assertVisible: "Hoş Geldiniz"
- tapOn: "Kullanıcı"

# ✅ WORKS (ASCII only):
- assertVisible: "Ozet"               # only if that's the actual text
- assertVisible: "Toplam Antrenman"   # no Turkish special chars
- tapOn: "Add routine"                # English accessibility label
```

### 2. Tab bar navigation with `tabBarShowLabel: false`

When React Navigation has `tabBarShowLabel: false`, tab labels rendered by custom `TabBarIcon` components exist in the view hierarchy but Maestro may not find them via text match.

**Fix:** Use the iOS accessibility label format for tabs:
```yaml
# Tab labels are: "Home, tab, 1 of 3", "Workout, tab, 2 of 3", "Profile, tab, 3 of 3"
- tapOn: "Home, tab, 1 of 3"
- tapOn: "Workout, tab, 2 of 3"
- tapOn: "Profile, tab, 3 of 3"
```

Use `maestro hierarchy` to discover the actual accessibility labels on screen.

### 3. iOS accessibility label concatenation

iOS XCTest concatenates child text nodes into the parent's `accessibilityText`, separated by commas:
```
"✨, Yeni Rutin"    (parent Pressable, two Text children)
```

So `assertVisible: "Yeni Rutin"` may fail. Either match the full string or use a unique part that isn't split by commas.

### 4. Debug with `maestro hierarchy`

When Maestro can't find an element, dump the full UI tree to see actual labels:

```bash
maestro hierarchy | grep -o '"accessibilityText" : "[^"]*"' | grep -v '""'
```

This is essential for debugging — especially with Turkish characters, custom components, and platform-specific formatting.

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
        run: curl -fsSL "https://get.maestro.mobile.dev" | bash
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
        run: curl -fsSL "https://get.maestro.mobile.dev" | bash
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
- **Skipping dev overlay dismissals**: Always handle "DEVELOPMENT SERVERS" → "Continue" → "Reload" in that order.
- **Tapping "Go home" in RN dev menu**: This exits the app to the iOS home screen. Always tap "Reload" instead.
- **Using Turkish characters in selectors**: Characters ş, ı, ü, ğ, ç hang Maestro indefinitely. Use ASCII-only substrings.
- **Using text labels for tab bars when `tabBarShowLabel: false`**: Use iOS accessibility labels like "Workout, tab, 2 of 3" instead.
- **Forgetting to dump hierarchy**: When assertions fail, always run `maestro hierarchy` first to see the actual accessibility labels.

## References

- [Maestro Documentation](https://maestro.mobile.dev)
- [Maestro GitHub](https://github.com/mobile-dev-inc/maestro)
- [Flow YAML Reference](https://maestro.mobile.dev/api-reference/commands)
- `references/maestro-flows.md` — Common flow patterns and reusable subflows
- `references/simulator-management.md` — iOS/Android device CLI reference
- `assets/flow-templates/` — Ready-to-use flow templates
