#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
MACOS_DIR="$ROOT/macos"
BUILD_DIR="$ROOT/build"
APP="$BUILD_DIR/NetworkBandwidthCheck.app"
ICONSET="$BUILD_DIR/AppIcon.iconset"
ASSET_ICONSET="$MACOS_DIR/NetworkBandwidthCheck/Assets.xcassets/AppIcon.appiconset"
SDK="$(xcrun --show-sdk-path)"

echo "==> Generating speedometer app icon"
rm -rf "$ICONSET"
swift "$MACOS_DIR/scripts/generate_app_icon.swift" "$ICONSET"
cp "$ICONSET"/*.png "$ASSET_ICONSET/"

echo "==> Building AppIcon.icns"
iconutil -c icns "$ICONSET" -o "$BUILD_DIR/AppIcon.icns"

echo "==> Syncing Python script"
mkdir -p "$MACOS_DIR/NetworkBandwidthCheck/Resources"
cp "$ROOT/wifi_speed_check.py" "$MACOS_DIR/NetworkBandwidthCheck/Resources/wifi_speed_check.py"

echo "==> Compiling app"
mkdir -p "$BUILD_DIR"
swiftc \
  -sdk "$SDK" \
  -target arm64-apple-macosx14.0 \
  -O \
  -o "$BUILD_DIR/NetworkBandwidthCheck" \
  "$MACOS_DIR/Shared/SpeedTestResult.swift" \
  "$MACOS_DIR/NetworkBandwidthCheck/SpeedTestRunner.swift" \
  "$MACOS_DIR/NetworkBandwidthCheck/SpeedTestViewModel.swift" \
  "$MACOS_DIR/NetworkBandwidthCheck/ContentView.swift" \
  "$MACOS_DIR/NetworkBandwidthCheck/NetworkBandwidthCheckApp.swift" \
  -framework SwiftUI \
  -framework AppKit \
  -framework WidgetKit \
  -framework Combine

echo "==> Packaging .app bundle"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$BUILD_DIR/NetworkBandwidthCheck" "$APP/Contents/MacOS/"
cp "$ROOT/wifi_speed_check.py" "$APP/Contents/Resources/"
cp "$BUILD_DIR/AppIcon.icns" "$APP/Contents/Resources/"

cat > "$APP/Contents/Info.plist" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleExecutable</key>
	<string>NetworkBandwidthCheck</string>
	<key>CFBundleIconFile</key>
	<string>AppIcon</string>
	<key>CFBundleIdentifier</key>
	<string>com.networkbandwidthcheck.app</string>
	<key>CFBundleName</key>
	<string>Network Bandwidth Check</string>
	<key>CFBundlePackageType</key>
	<string>APPL</string>
	<key>CFBundleShortVersionString</key>
	<string>1.0</string>
	<key>CFBundleVersion</key>
	<string>1</string>
	<key>LSMinimumSystemVersion</key>
	<string>14.0</string>
	<key>NSHighResolutionCapable</key>
	<true/>
</dict>
</plist>
EOF

echo ""
echo "Done: $APP"
echo "  open \"$APP\""
