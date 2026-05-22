# Run Commands

Instructions for setting up and running the network bandwidth (WiFi/internet) speed check.

## Prerequisites

- Python 3.8 or newer
- An active internet connection (WiFi, Ethernet, etc.)

## Setup

From the project root:

```bash
cd /path/to/network_bandwidth_check
```

Create and activate a virtual environment (recommended):

```bash
python3 -m venv .venv
source .venv/bin/activate   # macOS / Linux
# .venv\Scripts\activate    # Windows (PowerShell)
```

Install dependencies:

```bash
pip install -r requirements.txt
```

## Run the speed test

### Default (human-readable output)

```bash
python3 wifi_speed_check.py
```

Or, if the script is executable:

```bash
chmod +x wifi_speed_check.py   # once
./wifi_speed_check.py
```

### JSON output

```bash
python3 wifi_speed_check.py --json
```

### Use HTTP instead of HTTPS

Useful if HTTPS to Speedtest servers fails on your network:

```bash
python3 wifi_speed_check.py --insecure
```

Combine flags:

```bash
python3 wifi_speed_check.py --json --insecure
```

## CLI options

| Flag | Description |
|------|-------------|
| `--json` | Print results as JSON instead of a formatted summary |
| `--insecure` | Use HTTP instead of HTTPS for the speed test |
| `-h`, `--help` | Show usage and exit |

## What to expect

1. The script finds the best Speedtest.net server.
2. It runs download and upload tests (this can take a minute or two).
3. Results include ping (ms), download/upload (Mbps), server info, and a timestamp.

Example output:

```
Running speed test....
Finding best Speedtest server...
Server: Example ISP (City, US)
Testing download...
Testing upload...

--- Results ---
Ping:      12.34 ms
Download:  150.25 Mbps
Upload:    20.10 Mbps
Time:      2026-05-23 14:30:00
```

## Exit codes

| Code | Meaning |
|------|---------|
| `0` | Success |
| `1` | Speed test failed (network error, server issue, etc.) |
| `130` | Cancelled (Ctrl+C) |

## Troubleshooting

**Missing dependency**

```bash
pip install -r requirements.txt
```

**Permission / module errors**

Use the same Python that has `speedtest-cli` installed:

```bash
python3 -m pip install -r requirements.txt
python3 wifi_speed_check.py
```

**Test interrupted**

Press Ctrl+C once; the script exits with code 130.
