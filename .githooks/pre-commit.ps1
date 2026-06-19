$ErrorActionPreference = 'Stop'

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')

Push-Location $repoRoot
try {
  Write-Host '==> flutter gen-l10n'
  flutter gen-l10n

  Write-Host '==> dart format --output=none --set-exit-if-changed .'
  dart format --output=none --set-exit-if-changed .

  Write-Host '==> flutter analyze'
  flutter analyze
} finally {
  Pop-Location
}
