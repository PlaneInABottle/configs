# Maestro Flow Patterns

Common flow patterns and reusable subflow examples.

## Login

```yaml
appId: com.example.myapp
tags: [auth, smoke]
env:
  EMAIL: ${TEST_EMAIL}
  PASSWORD: ${TEST_PASSWORD}
---
- launchApp
- assertVisible: "Welcome"
- tapOn: { id: "email_input" }
- inputText: ${EMAIL}
- tapOn: { id: "password_input" }
- inputText: ${PASSWORD}
- tapOn: { id: "login_button" }
- waitForAnimationToEnd
- assertVisible: "Dashboard"
- takeScreenshot: "login-success"
```

## Navigation

```yaml
appId: com.example.myapp
---
- launchApp
- assertVisible: "Home"
- tapOn: "Search"
- assertVisible: "Search Results"
- tapOn: "Profile"
- assertVisible: "My Profile"
# Back navigation
- back
- assertVisible: "Search Results"
- tapOn: "Home"
- assertVisible: "Home"
```

## Form Fill

```yaml
appId: com.example.myapp
tags: [forms]
---
- launchApp
- tapOn: "Sign Up"
- tapOn: { id: "first_name" }
- inputText: "Jane"
- tapOn: { id: "last_name" }
- inputText: "Doe"
- tapOn: { id: "email" }
- inputText: "jane@example.com"
- tapOn: { id: "phone" }
- inputText: "+15551234567"
- hideKeyboard
- swipe: { direction: UP }
- tapOn: { id: "password" }
- inputText: "SecureP@ss123"
- tapOn: { id: "confirm_password" }
- inputText: "SecureP@ss123"
- hideKeyboard
- tapOn: "Create Account"
- assertVisible: "Welcome, Jane"
```

## List Scroll

```yaml
appId: com.example.myapp
---
- launchApp
- tapOn: "Products"
- scrollUntilVisible:
    element: { text: "Winter Jacket" }
    direction: DOWN
    speed: 40
- tapOn: "Winter Jacket"

# Scroll by index
- scrollUntilVisible:
    element: { index: 10 }
    direction: DOWN
```

## Reusable Subflows

### `subflows/login.yaml`

```yaml
appId: com.example.myapp
env: { EMAIL: "", PASSWORD: "" }
---
- tapOn: { id: "email_input" }
- inputText: ${EMAIL}
- tapOn: { id: "password_input" }
- inputText: ${PASSWORD}
- tapOn: { id: "login_button" }
- waitForAnimationToEnd
```

### Main flow importing subflow

```yaml
appId: com.example.myapp
env: { TEST_EMAIL: ${TEST_EMAIL}, TEST_PASSWORD: ${TEST_PASSWORD} }
---
- launchApp
- runFlow:
    file: subflows/login.yaml
    env: { EMAIL: ${TEST_EMAIL}, PASSWORD: ${TEST_PASSWORD} }
- assertVisible: "Dashboard"
```

### `subflows/dismiss-modals.yaml`

```yaml
appId: com.example.myapp
---
- tapOn: { text: "Not Now", optional: true }
- tapOn: { text: "Allow", optional: true }
- tapOn: { text: "Skip", optional: true }
```

## Conditional Flows

```yaml
# Wait while loading
- repeat:
    whileVisible: "Loading"
    commands:
      - waitForAnimationToEnd
      - assertNotVisible: "Error"
- assertVisible: "Content Loaded"
```

```yaml
# Assert script output
- copyTextFrom: { id: "item_count" }
- evalScript: ${output.count = Number(output.count) || 0}
- assertTrue: ${output.count > 0}
```

```yaml
# Retry until ready
- repeat:
    max: 5
    commands:
      - waitForAnimationToEnd
      - copyTextFrom: { id: "status" }
    whileTrue: ${output.status === "loading"}
- assertVisible: "Data Ready"
```

## Platform-Specific

### iOS

```yaml
appId: com.example.myapp
tags: [ios-only]
---
- launchApp
- tapOn: "Allow"  # iOS system permission dialog
- tapOn: { xpath: "//XCUIElementTypeSwitch[@name='notifications']" }
```

### Android

```yaml
appId: com.example.myapp
tags: [android-only]
---
- launchApp
- tapOn: "ALLOW"  # Android permission dialog
- pressKey: BACK
```

Run by platform:

```bash
maestro test --include-tags ios-only .maestro/
maestro test --include-tags android-only .maestro/
```

## Tips

- Name screenshots descriptively: `takeScreenshot: "after-login"`.
- Use tags: `smoke`, `regression`, `auth`, `ios-only`.
- Keep subflows in a `subflows/` directory.
- Use `optional: true` for dismissable dialogs.
- End critical flows with `takeScreenshot` for CI debugging.
