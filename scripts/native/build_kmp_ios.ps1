$ErrorActionPreference = "Stop"

& (Join-Path $PSScriptRoot "build_kmp_ios_xcframework.ps1")
& (Join-Path $PSScriptRoot "sync_xcframework.ps1")
