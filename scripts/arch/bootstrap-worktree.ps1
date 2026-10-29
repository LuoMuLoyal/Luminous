# 架构 worktree 引导与验证
#
# 每个 worktree 是独立工作副本：`.dart_tool`、`.packages`、build 产物全部各自一份，
# **不做任何软链接或缓存共享**——软链接会让一个 worktree 的 generator 版本漂移污染
# 另一个，而架构清理批次的验证必须能独立复现。
#
# 用法（PowerShell）：
#   .\scripts\arch\bootstrap-worktree.ps1 -Path D:\...\Luminous-arch-domain
#   .\scripts\arch\bootstrap-worktree.ps1 -Path <path> -Verify
#
# 步骤与 .github/workflows/ci.yml 的顺序保持一致：
#   1. 合并 ARB 分片 + gen-l10n
#   2. 根 pub get
#   3. bootstrap.dart --skip-client（drift + freezed + json + riverpod 生成）
#   4. generated/lucent_api 的 build_runner
#   5. 子包 pub get（pigeon / paddle_ocr 的分析依赖）
#   6. oss_licenses 生成
#   7. flutter analyze
param(
  [Parameter(Mandatory = $true)][string]$Path,
  [switch]$Verify
)

$ErrorActionPreference = 'Stop'
if (-not (Test-Path $Path)) { throw "worktree not found: $Path" }
Push-Location $Path
try {
  Write-Host "==> [$Path] 1/7 ARB merge + gen-l10n"
  dart scripts/l10n/arb_tools.dart merge | Out-Null
  flutter gen-l10n | Out-Null

  Write-Host "==> [$Path] 2/7 flutter pub get"
  flutter pub get | Select-Object -Last 1

  Write-Host "==> [$Path] 3/7 root build_runner (bootstrap --skip-client)"
  # bootstrap 在 sqlite3 的 native hook 上可能失败，但 build_runner 本身会跑完；
  # 失败不阻断，后续步骤会以 analyze 为准复验。
  dart run scripts/contract/bootstrap.dart --skip-client 2>&1 | Select-Object -Last 3

  Write-Host "==> [$Path] 4/7 generated/lucent_api build_runner"
  Push-Location generated/lucent_api
  dart pub get | Out-Null
  dart run build_runner build | Select-Object -Last 1
  Pop-Location

  Write-Host "==> [$Path] 5/7 sub-package pub get"
  foreach ($pkg in @('pkgs/luminous_native_bridge', 'pkgs/paddle_ocr_native-0.1.1')) {
    if (Test-Path $pkg) {
      Push-Location $pkg
      flutter pub get | Out-Null
      Pop-Location
    }
  }

  Write-Host "==> [$Path] 6/7 oss_licenses"
  # -i flutter：dart_pubspec_licenses 3.0.12 硬编码读 $FLUTTER_ROOT/version，
  # Flutter 3.47.1 起该文件已不存在，不忽略 SDK 条目会直接抛异常。
  dart run dart_pubspec_licenses:generate -o lib/oss_licenses.dart -i flutter 2>&1 |
    Select-Object -Last 2

  # 生成物不参与提交：只保留 CRLF/插件注册的机械差异时直接还原。
  git checkout -- linux/flutter/generated_plugin_registrant.h windows/flutter/generated_plugin_registrant.h 2>$null

  if ($Verify) {
    Write-Host "==> [$Path] 7/7 flutter analyze"
    $out = flutter analyze 2>&1
    $out | Select-Object -Last 3
    $errors = ($out | Select-String -Pattern '^\s*error').Count
    if ($errors -gt 0) { throw "[$Path] analyze has $errors error(s)" }
  }
}
finally {
  Pop-Location
}
