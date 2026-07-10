#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage:
  $(basename "$0") <x> <y>         Move once to (x, y)
  $(basename "$0") --continuous    Jitter the mouse continuously (Ctrl-C to stop)
  $(basename "$0") --circle        Move the mouse in a circle (Ctrl-C to stop)
  $(basename "$0") --figure8       Move the mouse in a figure-8 (Ctrl-C to stop)

Environment variables:
  RADIUS      Circle/figure-8 radius in pixels (default: 1/4 of smaller screen dimension)
  SPEED       Angular step per frame in radians (default: 0.05)
  STEP        Random jitter max step in pixels (default: 30)
  INTERVAL_MS Milliseconds between frames (default: 10 for patterns, 500 for jitter)
EOF
  exit 1
}

MODE=""
case "${1:-}" in
  --continuous) MODE="random" ;;
  --circle)     MODE="circle" ;;
  --figure8)    MODE="figure8" ;;
  "") usage ;;
  *)
    if [ "$#" -eq 2 ]; then
      MODE="single"
    else
      usage
    fi
    ;;
esac

if [ "$MODE" = "single" ]; then
  X="$1"
  Y="$2"
  if ! [[ "$X" =~ ^-?[0-9]+$ ]] || ! [[ "$Y" =~ ^-?[0-9]+$ ]]; then
    echo "Error: coordinates must be integers." >&2
    usage
  fi
  swift -e "import CoreGraphics; CGWarpMouseCursorPosition(CGPoint(x: ${X}, y: ${Y}))"
  exit 0
fi

PATTERN="$MODE"
if [ "$PATTERN" = "random" ]; then
  RADIUS_ARG="${STEP:-30}"
  SPEED_ARG="0"
  INTERVAL_MS="${INTERVAL_MS:-500}"
else
  RADIUS_ARG="${RADIUS:-auto}"
  SPEED_ARG="${SPEED:-0.05}"
  INTERVAL_MS="${INTERVAL_MS:-10}"
fi

TMP_SWIFT=$(mktemp /tmp/move-mouse.XXXXXX).swift
trap 'rm -f "$TMP_SWIFT"' EXIT

cat > "$TMP_SWIFT" <<'SWIFT'
import CoreGraphics
import Foundation

let pattern = CommandLine.arguments[1]
let radiusArg = CommandLine.arguments[2]
let speed = Double(CommandLine.arguments[3]) ?? 0.05
let intervalUs = (Int(CommandLine.arguments[4]) ?? 10) * 1000

let display = CGMainDisplayID()
let bounds = CGDisplayBounds(display)
let cx = bounds.midX
let cy = bounds.midY

let radius: CGFloat
if radiusArg == "auto" {
    radius = min(bounds.width, bounds.height) / 4
} else if let r = Double(radiusArg) {
    radius = CGFloat(r)
} else {
    radius = min(bounds.width, bounds.height) / 4
}

var theta: Double = 0

while true {
    var point: CGPoint

    switch pattern {
    case "circle":
        point = CGPoint(
            x: cx + radius * cos(theta),
            y: cy + radius * sin(theta)
        )
    case "figure8":
        point = CGPoint(
            x: cx + radius * sin(theta),
            y: cy + radius * sin(2 * theta)
        )
    default:
        var loc = CGEvent(source: nil)?.location ?? CGPoint(x: cx, y: cy)
        let step = Int(radius)
        loc.x += CGFloat(Int.random(in: -step...step))
        loc.y += CGFloat(Int.random(in: -step...step))
        loc.x = max(bounds.minX, min(bounds.maxX - 1, loc.x))
        loc.y = max(bounds.minY, min(bounds.maxY - 1, loc.y))
        point = loc
    }

    // Post a real mouse-moved event so the HID idle timer resets.
    // CGWarpMouseCursorPosition only teleports the pointer and does NOT
    // generate an input event, so apps like Microsoft Teams still mark
    // you as Away. Requires Input Monitoring permission for the terminal.
    if let event = CGEvent(
        mouseEventSource: nil,
        mouseType: .mouseMoved,
        mouseCursorPosition: point,
        mouseButton: .left
    ) {
        event.post(tap: .cghidEventTap)
    }
    theta += speed
    usleep(useconds_t(intervalUs))
}
SWIFT

swift "$TMP_SWIFT" "$PATTERN" "$RADIUS_ARG" "$SPEED_ARG" "$INTERVAL_MS"
