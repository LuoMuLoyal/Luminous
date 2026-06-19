$ErrorActionPreference = 'Stop'

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
$dailyChecks = Join-Path $repoRoot 'tool/run_daily_checks.ps1'

& $dailyChecks
