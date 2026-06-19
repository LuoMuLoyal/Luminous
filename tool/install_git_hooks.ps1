$ErrorActionPreference = 'Stop'

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
$gitDir = Join-Path $repoRoot '.git'
$hooksPath = '.githooks'

if (-not (Test-Path $gitDir)) {
  throw "Git repository not found at $repoRoot"
}

git -C $repoRoot config core.hooksPath $hooksPath

Write-Host "Configured core.hooksPath to $hooksPath"
Write-Host 'Git hooks are now shared from .githooks/'
