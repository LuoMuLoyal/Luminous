<#
.SYNOPSIS
  Pre-downloads pre-compiled SQLite binaries for the sqlite3 Dart package's
  native assets build hook.

.DESCRIPTION
  The `sqlite3` package (v3.x) uses Dart hooks to download pre-compiled SQLite
  libraries from GitHub during `flutter analyze` / `flutter build`. On Windows,
  Dart's HttpClient cannot reliably access GitHub due to TLS certificate
  issues (dartbug.com/52266), causing "信号灯超时时间已到" / HandshakeException
  errors.

  This script uses PowerShell's `Invoke-WebRequest` (which uses the Windows
  certificate store) to pre-populate the hooks cache directory. After running
  this script, `flutter analyze` and `flutter build` will find the cached
  binary and skip the download.

  Run this script after `flutter clean` or whenever the cache is missing.

.PARAMETER Target
  Optional: comma-separated list of targets to download.
  Defaults to "windows-x64" (the host platform).
  Other options: "android-arm","android-arm64","android-x64","android-ia32"

.EXAMPLE
  ./tool/fetch_sqlite3_binary.ps1
  Downloads the Windows x64 SQLite DLL only.

.EXAMPLE
  ./tool/fetch_sqlite3_binary.ps1 -Target "windows-x64,android-arm64"
  Downloads both Windows x64 and Android arm64 binaries.
#>

param(
  [string]$Target = "windows-x64"
)

$ErrorActionPreference = "Stop"

# --- Locate the hooks cache directory ---
$repoRoot = Resolve-Path "$PSScriptRoot/.."
$cacheBase = Join-Path $repoRoot ".dart_tool/hooks_runner/shared/sqlite3/build"

if (-not (Test-Path $cacheBase)) {
  Write-Host "Creating hooks cache base: $cacheBase"
  New-Item -ItemType Directory -Path $cacheBase -Force | Out-Null
}

# --- Binary registry for sqlite3 v3.3.4 ---
# Each entry: source filename on GitHub, SHA256 hash, local file name, cache dir name
$binaries = @{
  "windows-x64" = @{
    Url      = "https://github.com/simolus3/sqlite3.dart/releases/download/sqlite3-3.3.4/sqlite3.x64.windows.dll"
    Sha256   = "563a01a5fbb929844df1a9f6a84f73f7a53b9b183ebda8cb8399d69567adff09"
    LocalName = "sqlite3.dll"
  }
  "windows-arm64" = @{
    Url      = "https://github.com/simolus3/sqlite3.dart/releases/download/sqlite3-3.3.4/sqlite3.arm64.windows.dll"
    Sha256   = "f49da845461af38d528a987bb3c9c52bf52ec22ce9baa6be311a72a23b322f35"
    LocalName = "sqlite3.dll"
  }
  "windows-ia32" = @{
    Url      = "https://github.com/simolus3/sqlite3.dart/releases/download/sqlite3-3.3.4/sqlite3.ia32.windows.dll"
    Sha256   = "e0311ddfa4544fb448af5552bca941d201b694ccd3963bf240c18dda4145ae7d"
    LocalName = "sqlite3.dll"
  }
  "android-arm" = @{
    Url      = "https://github.com/simolus3/sqlite3.dart/releases/download/sqlite3-3.3.4/libsqlite3.arm.android.so"
    Sha256   = "807999cfe7e0ccf811e7c820d6b11d31c6bb2388c6659fbc6829cd18dae4f61e"
    LocalName = "libsqlite3.so"
  }
  "android-arm64" = @{
    Url      = "https://github.com/simolus3/sqlite3.dart/releases/download/sqlite3-3.3.4/libsqlite3.arm64.android.so"
    Sha256   = "9c4b75c2f7798d9aa6306811b3b412d1a0e54bd41f2304780daa4748b27a971e"
    LocalName = "libsqlite3.so"
  }
  "android-x64" = @{
    Url      = "https://github.com/simolus3/sqlite3.dart/releases/download/sqlite3-3.3.4/libsqlite3.x64.android.so"
    Sha256   = "52c7183d99b1d85df5d09d9cf11613213f92121756df2562e7319fbe6b2a00b3"
    LocalName = "libsqlite3.so"
  }
  "android-ia32" = @{
    Url      = "https://github.com/simolus3/sqlite3.dart/releases/download/sqlite3-3.3.4/libsqlite3.ia32.android.so"
    Sha256   = "b1bc318478a0be5be2d7b6c94a6b1408c8f78a05f70811dc4902be620d22b207"
    LocalName = "libsqlite3.so"
  }
}

# --- Download each requested target ---
$targets = $Target -split "," | ForEach-Object { $_.Trim() }
$allOk = $true

foreach ($t in $targets) {
  if (-not $binaries.ContainsKey($t)) {
    Write-Host "[SKIP] Unknown target: $t" -ForegroundColor Yellow
    Write-Host "  Available: $($binaries.Keys -join ', ')"
    continue
  }

  $info = $binaries[$t]
  $hashPrefix = $info.Sha256.Substring(0, 8)
  $cacheDir = Join-Path $cacheBase "download-$hashPrefix"
  $destFile = Join-Path $cacheDir $info.LocalName

  # Check if already cached and valid
  if (Test-Path $destFile) {
    $existingHash = (Get-FileHash $destFile -Algorithm SHA256).Hash.ToLower()
    if ($existingHash -eq $info.Sha256) {
      Write-Host "[OK] $t already cached ($hashPrefix)" -ForegroundColor Green
      continue
    }
    Write-Host "[STALE] $t cache exists but hash mismatch, re-downloading..." -ForegroundColor Yellow
  }

  # Clean up any stale .tmp file
  $tmpFile = "$destFile.tmp"
  Remove-Item $tmpFile -Force -ErrorAction SilentlyContinue

  # Create cache directory
  if (-not (Test-Path $cacheDir)) {
    New-Item -ItemType Directory -Path $cacheDir -Force | Out-Null
  }

  # Download using PowerShell's Invoke-WebRequest (uses Windows certificate store)
  Write-Host "[DOWNLOAD] $t from $($info.Url)"
  try {
    Invoke-WebRequest -Uri $info.Url -OutFile $destFile -UseBasicParsing
  } catch {
    Write-Host "[FAIL] $t download failed: $_" -ForegroundColor Red
    $allOk = $false
    continue
  }

  # Verify hash
  $actualHash = (Get-FileHash $destFile -Algorithm SHA256).Hash.ToLower()
  if ($actualHash -eq $info.Sha256) {
    Write-Host "[OK] $t downloaded and verified ($hashPrefix)" -ForegroundColor Green
  } else {
    Write-Host "[FAIL] $t hash mismatch!" -ForegroundColor Red
    Write-Host "  Expected: $($info.Sha256)"
    Write-Host "  Actual:   $actualHash"
    Remove-Item $destFile -Force -ErrorAction SilentlyContinue
    $allOk = $false
  }
}

if ($allOk) {
  Write-Host ""
  Write-Host "All requested binaries cached successfully." -ForegroundColor Green
  Write-Host "You can now run 'flutter analyze' or 'flutter build' without download errors."
} else {
  Write-Host ""
  Write-Host "Some downloads failed. Check your network connection and try again." -ForegroundColor Red
  exit 1
}
