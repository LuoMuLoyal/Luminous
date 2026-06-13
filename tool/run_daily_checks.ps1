$ErrorActionPreference = 'Stop'

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')

Push-Location $repoRoot
try {
  Write-Host '==> flutter pub get'
  flutter pub get

  Write-Host '==> flutter gen-l10n'
  flutter gen-l10n

  Write-Host '==> flutter analyze'
  flutter analyze

  Write-Host '==> flutter test'
  flutter test
} finally {
  Pop-Location
}
