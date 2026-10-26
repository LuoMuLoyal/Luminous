#!/usr/bin/env python3
"""Prepare the two static assets the web build needs but never produces.

`web/sqlite3.wasm` and `web/drift_worker.js` are gitignored build-time
artifacts (`.gitignore`), so a fresh CI checkout has neither:

* `drift_worker.js` is compiled from `web/drift_worker.dart` by the workflow
  step that calls this script's sibling (`dart compile js ...`).
* `sqlite3.wasm` ships as a release asset of `simolus3/sqlite3.dart`, keyed by
  the `sqlite3` package version. Nothing generated it in CI, so
  `deploy-harmonyos.yml`'s "both artifacts must exist" assertion failed while
  `connection_web.dart` would have hit a missing WASM binary at runtime.

Downloading by the version pinned in `pubspec.yaml` (rather than a hardcoded
URL) keeps the binary in lockstep with the Dart package that loads it: a bump
without a matching binary would break the web build at runtime, and this makes
that impossible to forget.

Usage: python3 scripts/web/fetch_sqlite3_wasm.py [--output web/sqlite3.wasm]
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import sys
import urllib.error
import urllib.request
from pathlib import Path

RELEASE_REPO = "simolus3/sqlite3.dart"
ASSET_NAME = "sqlite3.wasm"
PUBSPEC = Path("pubspec.yaml")


def auth_headers() -> dict[str, str]:
    """Headers for the GitHub API, borrowing a token when one is available.

    Unauthenticated release lookups are rate-limited per IP, which CI runners
    share. `GITHUB_TOKEN` is present in every Actions job, so use it when set
    and fall back to anonymous locally.
    """
    headers = {
        "Accept": "application/vnd.github+json",
        "User-Agent": "luminous-ci",
    }
    token = os.environ.get("GITHUB_TOKEN") or os.environ.get("GH_TOKEN")
    if token:
        headers["Authorization"] = f"Bearer {token}"
    return headers


def pinned_version(pubspec: Path) -> str:
    """Read the exact `sqlite3: x.y.z` pin from pubspec.yaml.

    Only an exact pin is accepted: a caret range means CI could download a
    binary that does not match whatever version resolution actually picks.
    """
    text = pubspec.read_text(encoding="utf-8")
    match = re.search(r"^  sqlite3:\s*(\S+)\s*$", text, re.MULTILINE)
    if match is None:
        raise SystemExit(f"could not find a 'sqlite3:' dependency in {pubspec}")

    version = match.group(1).strip("'\"")
    if not re.fullmatch(r"\d+\.\d+\.\d+", version):
        raise SystemExit(
            f"sqlite3 must be pinned to an exact version in {pubspec}, found {version!r}"
        )
    return version


def fetch_asset(version: str) -> tuple[bytes, str | None]:
    """Download the wasm asset for `version`, returning its bytes and digest."""
    url = (
        f"https://api.github.com/repos/{RELEASE_REPO}/releases/tags/sqlite3-{version}"
    )
    request = urllib.request.Request(
        url,
        headers=auth_headers(),
    )
    try:
        with urllib.request.urlopen(request, timeout=60) as response:
            release = json.load(response)
    except urllib.error.HTTPError as error:
        raise SystemExit(
            f"no release sqlite3-{version} in {RELEASE_REPO} (HTTP {error.code})"
        )

    for asset in release.get("assets", []):
        if asset["name"] != ASSET_NAME:
            continue

        download = urllib.request.Request(
            asset["browser_download_url"],
            headers={"User-Agent": "luminous-ci"},
        )
        with urllib.request.urlopen(download, timeout=120) as response:
            data = response.read()

        expected = (asset.get("digest") or "").removeprefix("sha256:")
        actual = hashlib.sha256(data).hexdigest()
        if expected and actual != expected:
            raise SystemExit(
                f"sha256 mismatch for {ASSET_NAME}: expected {expected}, got {actual}"
            )
        return data, expected or actual

    raise SystemExit(f"release sqlite3-{version} has no {ASSET_NAME} asset")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--output",
        type=Path,
        default=Path("web") / ASSET_NAME,
        help="destination path (default: web/sqlite3.wasm)",
    )
    parser.add_argument(
        "--pubspec",
        type=Path,
        default=PUBSPEC,
        help="pubspec.yaml to read the pinned version from",
    )
    args = parser.parse_args()

    version = pinned_version(args.pubspec)
    data, digest = fetch_asset(version)

    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_bytes(data)
    print(f"wrote {args.output} ({len(data)} bytes) from sqlite3 {version}, sha256={digest}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
