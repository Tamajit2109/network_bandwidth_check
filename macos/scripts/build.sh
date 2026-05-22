#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
MACOS_DIR="$ROOT/macos"
PROJECT="$MACOS_DIR/NetworkBandwidthCheck.xcodeproj"
DERIVED="${DERIVED_DATA:-$ROOT/build/DerivedData}"
CONFIG="${CONFIG:-Release}"

echo "==> Syncing wifi_speed_check.py into app resources"
RESOURCES="$MACOS_DIR/NetworkBandwidthCheck/Resources"
mkdir -p "$RESOURCES"
cp "$ROOT/wifi_speed_check.py" "$RESOURCES/wifi_speed_check.py"

echo "==> Building Network Bandwidth Check ($CONFIG)"
xcodebuild \
  -project "$PROJECT" \
  -scheme NetworkBandwidthCheck \
  -configuration "$CONFIG" \
  -derivedDataPath "$DERIVED" \
  build

APP="$DERIVED/Build/Products/$CONFIG/NetworkBandwidthCheck.app"
echo ""
echo "Build succeeded:"
echo "  open \"$APP\""
