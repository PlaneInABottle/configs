# Simulator & Emulator Management

CLI reference for managing iOS simulators and Android emulators for Maestro tests.

## Xcode Simulator CLI (`xcrun simctl`)

### List Devices

```bash
xcrun simctl list devices available             # All simulators
xcrun simctl list devices available | grep "iPhone 15"  # Filter by type
xcrun simctl list devices --json available       # JSON output
```

### Boot & Shutdown

```bash
xcrun simctl boot <UDID>                        # Boot by UDID
xcrun simctl boot <UDID> && open -a Simulator   # Boot with GUI
xcrun simctl shutdown <UDID>                    # Shutdown one
xcrun simctl shutdown all                       # Shutdown all
```

### Install & Launch Apps

```bash
xcrun simctl install <UDID> /path/to/MyApp.app
xcrun simctl launch <UDID> com.example.myapp
xcrun simctl terminate <UDID> com.example.myapp
xcrun simctl uninstall <UDID> com.example.myapp
```

### UDID Management

```bash
# Extract UDID by device name
xcrun simctl list devices available | grep "iPhone 15 Pro" | head -1 | grep -oE '[0-9A-F-]{36}'

# Create / delete simulators
xcrun simctl create "TestPhone" "iPhone 15" "iOS17.2"
xcrun simctl delete <UDID>
```

## Android Emulator CLI

### List AVDs

```bash
emulator -list-avds           # List AVDs
avdmanager list avd           # Detailed info
```

### Start & Stop

```bash
emulator -avd <AVD_NAME>                                    # Foreground
emulator -avd <AVD_NAME> -no-window &                       # Headless
emulator -avd <AVD_NAME> -no-audio -no-window -gpu swiftshader_indirect &

# Wait for full boot
adb wait-for-device
while [ "$(adb shell getprop sys.boot_completed | tr -d '\r')" != "1" ]; do sleep 1; done

adb emu kill                                               # Kill emulator
```

### Install & Launch (adb)

```bash
adb install /path/to/app.apk
adb install -r /path/to/app.apk                            # Replace existing
adb shell am start -n com.example.myapp/.MainActivity      # Launch
adb shell am force-stop com.example.myapp                  # Force stop
adb uninstall com.example.myapp                            # Uninstall
```

### Device Info

```bash
adb devices
adb shell getprop ro.product.model
adb shell getprop ro.build.version.sdk
```

## Parallel Testing

### iOS: Multiple simulators

```bash
xcrun simctl boot <UDID_1> &
xcrun simctl boot <UDID_2> &
wait
xcrun simctl install <UDID_1> MyApp.app
xcrun simctl install <UDID_2> MyApp.app

maestro test --device <UDID_1> --output results/ios-1/ .maestro/ &
maestro test --device <UDID_2> --output results/ios-2/ .maestro/ &
wait
```

### Android: Multiple emulators

```bash
emulator -avd Pixel_6_API_34 -port 5554 &
emulator -avd Pixel_8_API_34 -port 5556 &
adb wait-for-device

adb -s emulator-5554 install app.apk
adb -s emulator-5556 install app.apk

maestro test --device emulator-5554 --output results/android-1/ .maestro/ &
maestro test --device emulator-5556 --output results/android-2/ .maestro/ &
wait
```

## Helper Functions

```bash
# iOS — first available iPhone UDID
get_ios_udid() {
  xcrun simctl list devices available | grep "iPhone" | head -1 | grep -oE '[0-9A-F-]{36}'
}

# Android — first connected device
get_android_device() {
  adb devices | grep -v "List" | grep "device$" | head -1 | awk '{print $1}'
}
```
