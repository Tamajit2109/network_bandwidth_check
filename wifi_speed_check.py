#!/usr/bin/env python3
"""Measure internet speed over your current connection (e.g. WiFi)."""

from __future__ import annotations

import argparse
import json
import sys
import time


def bits_to_mbps(bits_per_second: float) -> float:
    return bits_per_second / 1_000_000


def run_speedtest(secure: bool = True) -> dict:
    print("Running speed test....")
    try:
        import speedtest
    except ImportError as exc:
        raise SystemExit(
            "Missing dependency. Install with:\n"
            "  pip install -r requirements.txt"
        ) from exc

    print("Finding best Speedtest server...")
    tester = speedtest.Speedtest(secure=secure)
    tester.get_best_server()
    server = tester.results.server

    print(f"Server: {server['sponsor']} ({server['name']}, {server['country']})")
    print(f"Testing download...")
    download_bps = tester.download()

    print("Testing upload...")
    upload_bps = tester.upload()

    return {
        "ping_ms": round(tester.results.ping, 2),
        "download_mbps": round(bits_to_mbps(download_bps), 2),
        "upload_mbps": round(bits_to_mbps(upload_bps), 2),
        "server": {
            "id": server["id"],
            "name": server["name"],
            "sponsor": server["sponsor"],
            "country": server["country"],
        },
        "timestamp": time.strftime("%Y-%m-%d %H:%M:%S"),
    }


def print_results(results: dict) -> None:
    print("\n--- Results ---")
    print(f"Ping:      {results['ping_ms']} ms")
    print(f"Download:  {results['download_mbps']} Mbps")
    print(f"Upload:    {results['upload_mbps']} Mbps")
    print(f"Time:      {results['timestamp']}")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Check WiFi/internet speed using Speedtest.net",
    )
    parser.add_argument(
        "--json",
        action="store_true",
        help="Print results as JSON",
    )
    parser.add_argument(
        "--insecure",
        action="store_true",
        help="Use HTTP instead of HTTPS for the speed test",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()

    try:
        results = run_speedtest(secure=not args.insecure)
    except KeyboardInterrupt:
        print("\nCancelled.", file=sys.stderr)
        return 130
    except Exception as exc:
        print(f"Speed test failed: {exc}", file=sys.stderr)
        return 1

    if args.json:
        print(json.dumps(results, indent=2))
    else:
        print_results(results)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
