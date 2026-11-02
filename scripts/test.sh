#!/bin/bash
# Usage: scripts/test.sh unit|ui|smoke|matrix|tsan|server|all
set -euo pipefail
ROOT=$(git rev-parse --show-toplevel)
run() { # destination, extra args
  local dest="$1"; shift
  xcodebuild test -project "$ROOT/PacBag/PacBag.xcodeproj" -scheme PacBag \
    -destination "$dest" -derivedDataPath "$ROOT/build/test" \
    -collect-test-diagnostics never -parallel-testing-enabled NO "$@"
}
IPHONE27='platform=iOS Simulator,OS=27.0,name=iPhone 18 Pro'
IPHONE26='platform=iOS Simulator,OS=26.5,name=iPhone 17'
IPHONE18='platform=iOS Simulator,OS=18.5,name=PacBag 18.5'
IPHONEDUO='platform=iOS Simulator,OS=27.1,name=iPhone Duo'
IPAD27='platform=iOS Simulator,OS=27.0,name=iPad Pro 13-inch (M5)'
ensure18() { xcrun simctl list devices | grep -q 'PacBag 18.5' || xcrun simctl create 'PacBag 18.5' \
  com.apple.CoreSimulator.SimDeviceType.iPhone-16 com.apple.CoreSimulator.SimRuntime.iOS-18-5; }
case "${1:-unit}" in
  unit)   run "$IPHONE27" -only-testing:PacBagTests ;;
  ui)     run "$IPHONE27" -only-testing:PacBagUITests -skip-testing:PacBagUITests/ScreenshotTests ;;
  smoke)  run "$IPHONE27" -only-testing:PacBagUITests/SmokeTests ;;
  matrix) ensure18; for d in "$IPHONE18" "$IPHONE26" "$IPHONE27" "$IPHONEDUO" "$IPAD27"; do run "$d" -only-testing:PacBagTests -only-testing:PacBagUITests/SmokeTests; done ;;
  tsan)   run "$IPHONE27" -enableThreadSanitizer YES -only-testing:PacBagTests ;;
  server) (cd "$ROOT/backend" && npm test) ;;
  all)    "$0" unit; "$0" ui; "$0" server ;;
esac
