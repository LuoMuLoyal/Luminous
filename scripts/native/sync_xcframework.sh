#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
src="$root/native/luminous-native/build/XCFrameworks/release/LuminousNative.xcframework"
dest="$root/pkgs/luminous_native_bridge/ios/Frameworks"

if [[ ! -d "$src" ]]; then
  echo "Missing $src; run build_kmp_ios_xcframework.sh first." >&2
  exit 1
fi

mkdir -p "$dest"
rm -rf "$dest/LuminousNative.xcframework"
cp -R "$src" "$dest/"
