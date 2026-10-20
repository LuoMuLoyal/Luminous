$ErrorActionPreference = "Stop"

$root = Resolve-Path (Join-Path $PSScriptRoot "..\..")
Push-Location (Join-Path $root "native")
try {
    & .\gradlew.bat :luminous-native:assembleLuminousNativeXCFramework
} finally {
    Pop-Location
}
