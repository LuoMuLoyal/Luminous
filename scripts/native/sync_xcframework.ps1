$ErrorActionPreference = "Stop"

$root = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$src = Join-Path $root "native\luminous-native\build\XCFrameworks\release\LuminousNative.xcframework"
$dest = Join-Path $root "pkgs\luminous_native_bridge\ios\Frameworks"

if (-not (Test-Path $src)) {
    throw "Missing $src; run build_kmp_ios_xcframework.ps1 first."
}

New-Item -ItemType Directory -Force -Path $dest | Out-Null
Remove-Item -Recurse -Force (Join-Path $dest "LuminousNative.xcframework") -ErrorAction SilentlyContinue
Copy-Item -Recurse -Force $src $dest
