# 构建鸿蒙 HAP：Flutter Web 产物 → ohos rawfile → hvigorw assembleHap
#
# 用法（PowerShell，从仓库根目录执行）：
#   .\scripts\ohos\build-hap.ps1                 # debug
#   .\scripts\ohos\build-hap.ps1 -Release        # release
#   .\scripts\ohos\build-hap.ps1 -SkipWebBuild   # 复用现有 build/web
#
# 前置：DevEco Studio 已安装（默认 E:\DevEco Studio，可用 -DevEcoHome 覆盖）。
# 产物：ohos/entry/build/default/outputs/default/entry-default-*.hap

[CmdletBinding()]
param(
    [switch]$Release,
    [switch]$SkipWebBuild,
    [string]$DevEcoHome = 'E:\DevEco Studio'
)

$ErrorActionPreference = 'Stop'

# ── 定位仓库根（本脚本在 <root>/scripts/ohos/ 下）────────────────────
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
Set-Location $repoRoot

$ohosDir = Join-Path $repoRoot 'ohos'
$webDst = Join-Path $ohosDir 'entry\src\main\resources\rawfile\web'
$webSrc = Join-Path $repoRoot 'build\web'

if (-not (Test-Path $ohosDir)) { throw "未找到 ohos/ 工程：$ohosDir" }

# ── 1. 鸿蒙工具链环境（FVM 不管这一段，见计划 §1.1）─────────────────
if (-not (Test-Path $DevEcoHome)) { throw "未找到 DevEco Studio：$DevEcoHome" }
$sdkHome = Join-Path $DevEcoHome 'sdk'
if (-not (Test-Path (Join-Path $sdkHome 'default'))) { throw "未找到 OpenHarmony SDK：$sdkHome\default" }

$env:TOOL_HOME = $DevEcoHome
$env:DEVECO_SDK_HOME = $sdkHome
$toolPaths = @(
    (Join-Path $DevEcoHome 'tools\node'),
    (Join-Path $DevEcoHome 'tools\ohpm\bin'),
    (Join-Path $DevEcoHome 'tools\hvigor\bin'),
    (Join-Path $DevEcoHome 'jbr\bin')
)
foreach ($p in $toolPaths) {
    if (-not (Test-Path $p)) { throw "工具链目录不存在：$p" }
}
$env:PATH = ($toolPaths -join ';') + ';' + $env:PATH

# pub 源显式指向官方，避免 .pub-cache 与 lock 被镜像地址污染
$env:PUB_HOSTED_URL = 'https://pub.dev'

Write-Host "TOOL_HOME       = $env:TOOL_HOME"
Write-Host "DEVECO_SDK_HOME = $env:DEVECO_SDK_HOME"

# ── 2. Flutter Web 产物 ──────────────────────────────────────────────
if (-not $SkipWebBuild) {
    Write-Host ''
    Write-Host '==> flutter build web' -ForegroundColor Cyan
    # --base-href "/"          壳内是本地资源，不能带 GitHub Pages 的 /<repo>/ 前缀
    # --web-resources-cdn=false 否则运行时从 www.gstatic.com 拉 CanvasKit → 壳内白屏（§4.1）
    # 不加 --wasm              skwasm 在移动浏览器有布局 bug（deploy-web.yml:83-87）
    flutter build web --release `
        --base-href "/" `
        --no-web-resources-cdn `
        --dart-define=LUCENT_BASE_URL="$env:LUCENT_BASE_URL" `
        --dart-define=SENTRY_DSN="$env:SENTRY_DSN" `
        --dart-define=SUPPORT_EMAIL="$($env:SUPPORT_EMAIL ?? 'support@luminous.app')"
}

if (-not (Test-Path $webSrc)) {
    throw "未找到 Web 产物：$webSrc（先跑 flutter build web，或去掉 -SkipWebBuild）"
}

# ── 3. 产物自检（对应计划 §8.2 的 CI 断言，本地先拦一次）─────────────
Write-Host ''
Write-Host '==> 校验 Web 产物' -ForegroundColor Cyan

$bootstrap = Join-Path $webSrc 'flutter_bootstrap.js'
if (-not (Test-Path $bootstrap)) { throw "缺少 flutter_bootstrap.js" }
$bootstrapText = Get-Content $bootstrap -Raw

# 注意：loader 自身也会出现 "!e.useLocalCanvasKit" 这种读取方，不能整文件匹配。
# 只取 _flutter.buildConfig = {...}; 这一段，确认里面确实有 "useLocalCanvasKit":true。
$bcMatch = [regex]::Match($bootstrapText, '_flutter\.buildConfig\s*=\s*(\{.*?\});', 'Singleline')
if (-not $bcMatch.Success) {
    throw "flutter_bootstrap.js 里找不到 _flutter.buildConfig —— 产物结构异常"
}
if ($bcMatch.Groups[1].Value -notmatch '"useLocalCanvasKit"\s*:\s*true') {
    throw "buildConfig 缺少 `"useLocalCanvasKit`":true —— 壳内会从 www.gstatic.com 拉 CanvasKit 导致白屏。构建时是否漏了 --no-web-resources-cdn？"
}
Write-Host 'useLocalCanvasKit = true（CanvasKit 走本地，不会拉 CDN）'

$indexHtml = Join-Path $webSrc 'index.html'
$htmlText = Get-Content $indexHtml -Raw
if ($htmlText -notmatch '<base href="/"') {
    Write-Warning 'index.html 的 <base href> 不是 "/"，本地加载时相对路径可能错位'
}

foreach ($f in 'sqlite3.wasm', 'drift_worker.js') {
    if (-not (Test-Path (Join-Path $webSrc $f))) {
        throw "缺少 $f —— 它俩是构建期产物、不入库，必须由 CI/本地流程现场生成"
    }
}

$stat = (Get-ChildItem $webSrc -Recurse -File | Measure-Object Length -Sum)
Write-Host ("Web 产物：{0} 文件 / {1:N1} MB" -f $stat.Count, ($stat.Sum / 1MB))

# ── 4. 拷进 rawfile（gitignored）────────────────────────────────────
Write-Host ''
Write-Host '==> 拷贝产物到 rawfile/web' -ForegroundColor Cyan
if (Test-Path $webDst) { Remove-Item $webDst -Recurse -Force }
New-Item -ItemType Directory -Force -Path $webDst | Out-Null
robocopy $webSrc $webDst /E /NFL /NDL /NJH /NJS | Out-Null
if ($LASTEXITCODE -ge 8) { throw "robocopy 失败，exit=$LASTEXITCODE" }

# ── 5. hvigorw assembleHap ──────────────────────────────────────────
Write-Host ''
Write-Host '==> hvigorw assembleHap' -ForegroundColor Cyan
Push-Location $ohosDir
try {
    $mode = if ($Release) { 'release' } else { 'debug' }
    # 首次需要 ohpm install（oh_modules 不存在时）
    if (-not (Test-Path (Join-Path $ohosDir 'oh_modules'))) {
        Write-Host 'oh_modules 缺失，先跑 ohpm install'
        ohpm install
        if ($LASTEXITCODE -ne 0) { throw "ohpm install 失败，exit=$LASTEXITCODE" }
    }
    hvigorw assembleHap --mode module -p product=default -p buildMode=$mode --no-daemon
    if ($LASTEXITCODE -ne 0) { throw "hvigorw assembleHap 失败，exit=$LASTEXITCODE" }
} finally {
    Pop-Location
}

# ── 6. 汇报产物位置 ─────────────────────────────────────────────────
$outDir = Join-Path $ohosDir 'entry\build\default\outputs\default'
Write-Host ''
if (Test-Path $outDir) {
    Get-ChildItem $outDir -Filter *.hap | ForEach-Object {
        Write-Host ("产物：{0}  ({1:N1} MB)" -f $_.FullName, ($_.Length / 1MB)) -ForegroundColor Green
    }
} else {
    Write-Warning "未找到产物目录：$outDir"
}
