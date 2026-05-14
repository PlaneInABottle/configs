# Working Demo: Full Tab Navigation Flow

This reference documents a fully-tested Maestro flow that successfully:
1. Launches an Expo dev build app on iOS simulator
2. Dismisses all dev overlays (Dev Servers → Continue → Reload)
3. Navigates through all 3 tabs with assertions and screenshots
4. Scrolls content

## Complete Self-Contained Flow

```yaml
appId: com.fitness.app
---
# --- BOOTSTRAP ---
- launchApp:
    clearState: true
    clearKeychain: true
    stopApp: true
- waitForAnimationToEnd

- runFlow:
    when:
      visible: "DEVELOPMENT SERVERS"
    commands:
      - tapOn: "http://localhost:8081"
      - waitForAnimationToEnd

- runFlow:
    when:
      visible: "Continue"
    commands:
      - tapOn: "Continue"
      - waitForAnimationToEnd

- runFlow:
    when:
      visible: "Reload"
    commands:
      - tapOn: "Reload"
      - waitForAnimationToEnd

- waitForAnimationToEnd
- waitForAnimationToEnd

# --- 1. HOME SCREEN ---
- tapOn: "Home, tab, 1 of 3"
- waitForAnimationToEnd
- assertVisible: "Ev"
- assertVisible: "Toplam Antrenman"
- assertVisible: "Bu Hafta"
- assertVisible: "Toplam Hacim"
- takeScreenshot: "01-home"

- swipe:
    direction: UP
- waitForAnimationToEnd
- takeScreenshot: "02-home-scrolled"
- swipe:
    direction: DOWN
- waitForAnimationToEnd

# --- 2. WORKOUT TAB ---
- tapOn: "Workout, tab, 2 of 3"
- waitForAnimationToEnd
- assertVisible: "Rutinler"
- assertVisible: "Add routine"
- takeScreenshot: "03-workout"
- swipe:
    direction: UP
- waitForAnimationToEnd
- swipe:
    direction: DOWN
- waitForAnimationToEnd

# --- 3. PROFILE TAB ---
- tapOn: "Profile, tab, 3 of 3"
- waitForAnimationToEnd
- assertVisible: "Ayarlar"
- assertVisible: "Genel Ayarlar"
- assertVisible: "Bildirimler"
- takeScreenshot: "04-profile"

# --- 4. BACK TO HOME ---
- tapOn: "Home, tab, 1 of 3"
- waitForAnimationToEnd
- assertVisible: "Ev"
- assertVisible: "Toplam Antrenman"
- takeScreenshot: "05-back-home"
```

## Key Patterns

| Pattern | How |
|---------|-----|
| Bootstrap overlays | 3-step: Dev Servers URL → Continue → Reload |
| Tab navigation | Use accessibility labels: "Home, tab, 1 of 3" |
| Safe assertions | Only use ASCII text (avoid Turkish chars) |
| Screenshots after state changes | After every navigation + assertion block |
| Scroll then screenshot | Swipe first, wait, then capture |

## Environment

- Xcode 26.4.1, iOS 26.4 simulator
- Maestro 2.5.1
- Expo SDK 54, React Native 0.81.5
- Device: iPhone 17 (UDID retrieved from `xcrun simctl list devices available`)
