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
  Write-Host "==> [$Path] 0/7 离线 sqlite3 钩子（只在本地 worktree 生效，绝不提交）"
  # `sqlite3` 的 native-asset build hook 默认要从 GitHub 下载预编译 DLL；无网络时
  # flutter test / flutter analyze / luminous_lints CLI / pre-commit 全部失败。
  # `source: system` + `name: winsqlite3` 表示直接链接 Windows 自带的
  # C:\Windows\System32\winsqlite3.dll，不下载任何东西。
  #
  # 必须是 pubspec.yaml 的**顶层 key**（缩进 0），绝不能缩进进 dependencies——
  # 插错位置会吞掉相邻依赖，症状是满屏 uri_does_not_exist（像代码坏了，其实是
  # pubspec 坏了）。也必须放在文件末尾、flutter: 段之后。
  #
  # 风险：`flutter build apk/ios/windows` 的产物会依赖系统 sqlite，不能用于发布，
  # 所以这段只能在 worktree 里**临时存在**。提交前用 `git checkout pubspec.yaml`
  # 还原，提交完再跑一次 pub get。下面的 $Verify 分支会自动还原。
  $pubspec = (Resolve-Path (Join-Path $Path 'pubspec.yaml')).Path
  $raw = [System.IO.File]::ReadAllText($pubspec)
  if ($raw -notmatch '(?m)^hooks:') {
    [System.IO.File]::WriteAllText(
      $pubspec,
      $raw.TrimEnd() + "`n`nhooks:`n  user_defines:`n    sqlite3:`n      source: system`n      name: winsqlite3`n"
    )
    Write-Host "    appended top-level hooks block"
  } else {
    Write-Host "    hooks block already present"
  }

  Write-Host "==> [$Path] 1/7 ARB merge + gen-l10n"
  dart scripts/l10n/arb_tools.dart merge | Out-Null
  flutter gen-l10n | Out-Null

  Write-Host "==> [$Path] 2/7 flutter pub get"
  # 改过 pubspec.yaml 必须重新 pub get，否则 .dart_tool/package_config.json 还是旧的。
  flutter pub get | Select-Object -Last 1

  Write-Host "==> [$Path] 3/7 root build_runner (bootstrap --skip-client)"
  # 直接跑 build_runner，不走 bootstrap.dart：后者会在 sqlite3 native hook 上
  # 偶发失败并中断 build_runner，导致 freezed/drift 产物只生成一半，而 analyze
  # 照样能启动（报几千个 undefined getter），很难定位。
  # build 失败时重试一次：AOT 编译缓存首次构建偶发失败，第二次稳定。
  Write-Host "==> [$Path] 3/7 root build_runner"
  dart run build_runner build 2>&1 | Select-Object -Last 1
  if (-not (Test-Path 'lib/features/review/domain/entities/dashboard.freezed.dart')) {
    Write-Host "    first build incomplete, retrying"
    dart run build_runner build 2>&1 | Select-Object -Last 1
  }
  if (-not (Test-Path 'lib/features/review/domain/entities/dashboard.freezed.dart')) {
    throw "[$Path] build_runner produced no freezed output"
  }

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
