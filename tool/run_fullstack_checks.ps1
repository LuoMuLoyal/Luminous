param(
  [string]$DeviceId = 'emulator-5554',
  [string]$BaseUrl = 'http://10.0.2.2:3000',
  [string]$Email = 'fullstack-record-lane@example.com',
  [string]$Password = 'RecordLane123',
  [string]$RecordDate = '2026-06-12'
)

$ErrorActionPreference = 'Stop'

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
$workspaceRoot = Resolve-Path (Join-Path $repoRoot '..')
$lucentRoot = Join-Path $workspaceRoot 'Lucent'
$startRuntimeScript = Join-Path $lucentRoot 'scripts\dev\start-test-runtime.ps1'
$healthUrl = 'http://127.0.0.1:3000/api/v1/health'
$healthTimeoutSeconds = 30

Push-Location $repoRoot
try {
  Write-Host '==> Start Lucent test runtime'
  powershell -ExecutionPolicy Bypass -File $startRuntimeScript

  Write-Host '==> Verify Lucent health'
  $deadline = (Get-Date).AddSeconds($healthTimeoutSeconds)
  $healthy = $false
  do {
    try {
      $health = Invoke-WebRequest -Uri $healthUrl -UseBasicParsing -TimeoutSec 5
      if ($health.StatusCode -eq 200) {
        $healthy = $true
        break
      }
    } catch {
      Start-Sleep -Milliseconds 500
    }
  } while ((Get-Date) -lt $deadline)

  if (-not $healthy) {
    throw "Lucent test runtime health check did not reach 200 within ${healthTimeoutSeconds}s."
  }

  $commonArgs = @(
    "-d", $DeviceId,
    "--dart-define=LUCENT_BASE_URL=$BaseUrl",
    "--dart-define=E2E_TEST_EMAIL=$Email",
    "--dart-define=E2E_TEST_PASSWORD=$Password",
    "--dart-define=E2E_RECORD_DATE=$RecordDate"
  )

  $tests = @(
    'integration_test/auth/fullstack_auth_smoke_test.dart',
    'integration_test/record/fullstack_record_lane_test.dart',
    'integration_test/record/fullstack_sleep_lane_test.dart',
    'integration_test/app/fullstack_today_report_lane_test.dart'
  )

  foreach ($testFile in $tests) {
    Write-Host "==> flutter test $testFile"
    flutter test $testFile @commonArgs
  }
} finally {
  Pop-Location
}
