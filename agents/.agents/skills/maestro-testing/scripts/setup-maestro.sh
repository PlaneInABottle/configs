#!/usr/bin/env bash
set -euo pipefail

# setup-maestro.sh — Check and install Maestro CLI, verify mobile dev tools.

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

info()  { echo -e "${GREEN}[INFO]${NC} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; }

# --- Maestro CLI ---
check_maestro() {
  if command -v maestro &>/dev/null; then
    info "Maestro is installed: $(maestro --version 2>/dev/null || echo 'version unknown')"
  else
    warn "Maestro not found. Installing..."
    curl -Ls "https://get.maestro.mobile" | bash
    # Add to PATH for current session
    export PATH="$HOME/.maestro/bin:$PATH"
    if command -v maestro &>/dev/null; then
      info "Maestro installed successfully: $(maestro --version 2>/dev/null)"
    else
      error "Maestro installation failed. Try manually: https://maestro.mobile.dev/getting-started/installing-maestro"
      exit 1
    fi
  fi
}

# --- Xcode (iOS) ---
check_xcode() {
  if command -v xcodebuild &>/dev/null; then
    info "Xcode is installed: $(xcodebuild -version 2>/dev/null | head -1)"
  else
    warn "Xcode not found. iOS testing will not be available."
    warn "Install Xcode from the App Store: https://apps.apple.com/app/xcode/id497799835"
    return
  fi

  echo ""
  info "Available iOS simulators:"
  xcrun simctl list devices available | grep -E "iPhone|iPad" | head -10
  echo ""

  # Check for booted simulators
  local booted
  booted=$(xcrun simctl list devices available | grep "Booted" || true)
  if [ -n "$booted" ]; then
    info "Booted simulators:"
    echo "$booted"
  else
    warn "No simulators currently booted. Boot one with:"
    echo "  xcrun simctl boot <UDID>"
  fi
}

# --- Android SDK ---
check_android() {
  if command -v adb &>/dev/null; then
    info "Android SDK (adb) is installed: $(adb --version 2>/dev/null | head -1)"
  else
    warn "Android SDK not found. Android testing will not be available."
    warn "Install Android Studio: https://developer.android.com/studio"
    return
  fi

  echo ""
  if command -v emulator &>/dev/null; then
    info "Available Android AVDs:"
    emulator -list-avds || warn "No AVDs found. Create one in Android Studio."
  fi
  echo ""

  # Check connected devices
  local devices
  devices=$(adb devices 2>/dev/null | grep -v "List" | grep "device$" || true)
  if [ -n "$devices" ]; then
    info "Connected Android devices/emulators:"
    echo "$devices"
  else
    warn "No Android devices or emulators connected."
  fi
}

# --- Main ---
main() {
  echo "========================================="
  echo "  Maestro Testing Environment Check"
  echo "========================================="
  echo ""

  check_maestro
  echo ""

  echo "--- iOS ---"
  check_xcode
  echo ""

  echo "--- Android ---"
  check_android
  echo ""

  echo "========================================="
  info "Environment check complete."
  echo "========================================="
}

main "$@"
