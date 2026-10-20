#!/usr/bin/env bash
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$here/build_kmp_ios_xcframework.sh"
"$here/sync_xcframework.sh"
