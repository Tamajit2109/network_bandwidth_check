# Network Bandwidth Check — macOS App & Widget

Native macOS desktop app with a **menu bar panel** and a **desktop widget** that shows your latest speed test results.

## Requirements

- macOS 14 (Sonoma) or later
- Xcode 15+ (Command Line Tools are not enough — you need the full Xcode app)
- Python 3 with `speedtest-cli` installed:

```bash
pip install -r ../requirements.txt
```

## Build & run

### Option A — Xcode (recommended)

1. Open `macos/NetworkBandwidthCheck.xcodeproj` in Xcode.
2. Select your **Signing Team** for both targets (app + widget) under Signing & Capabilities.
3. Press **Run** (⌘R).

### Option B — Command line

```bash
chmod +x macos/scripts/build.sh
./macos/scripts/build.sh
open build/DerivedData/Build/Products/Release/NetworkBandwidthCheck.app
```

## Using the app

1. Launch **Network Bandwidth Check**.
2. Click **Run Speed Test** (takes about 1–2 minutes).
3. Results are saved and pushed to the widget automatically.

### Menu bar

Click the **Wi‑Fi icon** in the menu bar for a compact panel: last results and a quick **Run Speed Test** button.

### Desktop widget

1. Right-click the desktop → **Edit Widgets**.
2. Search for **Bandwidth** or **Network Bandwidth**.
3. Drag the widget onto your desktop or Notification Center.

Widgets show the **last completed** test. Run a new test from the app (or menu bar) to refresh the widget.

## App Group

The app and widget share data via App Group `group.network.bandwidthcheck`. Both targets must use the same team signing in Xcode for this to work on your Mac.

## Troubleshooting

| Issue | Fix |
|--------|-----|
| Python not found | Install Python 3 (`brew install python`) |
| Missing `speedtest` | `pip install -r requirements.txt` |
| Widget shows “Open the app…” | Run one speed test from the app first |
| Code signing errors | Set a Development Team in Xcode for app + widget targets |
