#!/usr/bin/env bash
# test-deep-link.sh — Test deep links on iOS simulator or Android emulator
# Usage: bash test-deep-link.sh <url>
# Example: bash test-deep-link.sh "myapp://profile"

set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $0 <url>"
  echo "Example: $0 \"myapp://profile\""
  exit 1
fi

URL="$1"

# Detect iOS simulator
if command -v xcrun &>/dev/null; then
  BOOTED_SIM=$(xcrun simctl list devices booted 2>/dev/null | grep -o '[0-9A-F-]\{36\}' | head -1)
  if [ -n "$BOOTED_SIM" ]; then
    echo "[iOS] Opening deep link on booted simulator: $URL"
    xcrun simctl openurl booted "$URL"
    exit 0
  fi
fi

# Detect Android emulator via adb
if command -v adb &>/dev/null; then
  ADB_DEVICES=$(adb devices 2>/dev/null | grep -c "emulator-" || true)
  if [ "$ADB_DEVICES" -gt 0 ]; then
    echo "[Android] Opening deep link on emulator: $URL"
    adb shell am start -a android.intent.action.VIEW -d "$URL"
    exit 0
  fi
fi

echo "Error: No iOS simulator or Android emulator detected."
echo ""
echo "Start a simulator first:"
echo "  iOS:     xcrun simctl boot <device-id> && open -a Simulator"
echo "  Android: emulator -avd <avd-name>"
exit 1
