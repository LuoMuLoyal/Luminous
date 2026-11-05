#!/usr/bin/env python3
"""构建鸿蒙 HAP：Flutter Web 产物 → ohos rawfile → hvigorw assembleHap

用法（从任意目录执行均可，脚本自己定位仓库根）：

    python scripts/ohos/build_hap.py                # debug
    python scripts/ohos/build_hap.py --release      # release
    python scripts/ohos/build_hap.py --skip-web     # 复用现有 build/web

前置：DevEco Studio 已安装（默认 E:\\DevEco Studio，可用 --deveco-home 覆盖）。

构建前会现场重建两个 gitignore 的 Web 构建期产物（`web/drift_worker.js` 由
`web/drift_worker.dart` 编译、`web/sqlite3.wasm` 从 sqlite3.dart 的 Release 资产
下载，与 `pubspec.yaml` 的 pin 对齐），并按 `deploy-harmonyos.yml` 同款规则裁剪
canvaskit 的 skwasm/wimp 变体与 `.js.symbols`。两条都不是可选步骤：前者决定
drift 能否在 Web 端工作，后者决定包里是否白背 ~18 MB 用不到的渲染器。

产物：ohos/entry/build/default/outputs/default/entry-default-*.hap（未签名，
签名见 docs/howto/build-release-artifacts.md 的 HarmonyOS 一节）

为什么用 Python 而不是 PowerShell：仓库内 scripts/ 下的工具链脚本统一用
Dart/Python，PS1 会引入仅 Windows 可用的语法；本脚本只用标准库，跨平台可读。
"""

from __future__ import annotations

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
from pathlib import Path

# ── 路径 ────────────────────────────────────────────────────────────────
REPO_ROOT = Path(__file__).resolve().parents[2]
OHOS_DIR = REPO_ROOT / "ohos"
WEB_SRC = REPO_ROOT / "build" / "web"
# 注意：产物必须**平铺**进 rawfile 根，不能放 web/ 子目录。
# resource://rawfile 协议不认 <base href>，一律以 rawfile 根为基准解析相对路径，
# 放到子目录会导致 index.html 能加载、而 flutter_bootstrap.js / main.dart.js 全部
# ERR_FILE_NOT_FOUND（2026-10-23 模拟器实测）。
RAWFILE_DIR = OHOS_DIR / "entry" / "src" / "main" / "resources" / "rawfile"
HAP_OUT_DIR = OHOS_DIR / "entry" / "build" / "default" / "outputs" / "default"

DEFAULT_DEVECO_HOME = Path(r"E:\DevEco Studio")


def log(msg: str) -> None:
    print(msg, flush=True)


def step(msg: str) -> None:
    print(f"\n==> {msg}", flush=True)


def fail(msg: str) -> "NoReturn":
    print(f"ERROR: {msg}", file=sys.stderr, flush=True)
    raise SystemExit(1)


# ── 1. 鸿蒙工具链环境 ───────────────────────────────────────────────────
def setup_toolchain(deveco_home: Path) -> dict[str, str]:
    """把 DevEco 的工具链前置到 PATH（FVM 不管这一段）。返回子进程用的 env。"""
    if not deveco_home.is_dir():
        fail(f"未找到 DevEco Studio：{deveco_home}")

    sdk_home = deveco_home / "sdk"
    if not (sdk_home / "default").is_dir():
        fail(f"未找到 OpenHarmony SDK：{sdk_home / 'default'}")

    tool_dirs = [
        deveco_home / "tools" / "node",
        deveco_home / "tools" / "ohpm" / "bin",
        deveco_home / "tools" / "hvigor" / "bin",
        deveco_home / "jbr" / "bin",
    ]
    for d in tool_dirs:
        if not d.is_dir():
            fail(f"工具链目录不存在：{d}")

    env = os.environ.copy()
    env["TOOL_HOME"] = str(deveco_home)
    env["DEVECO_SDK_HOME"] = str(sdk_home)
    env["PATH"] = os.pathsep.join(str(d) for d in tool_dirs) + os.pathsep + env.get("PATH", "")
    # pub 源显式指向官方，避免 .pub-cache 与 pubspec.lock 被镜像地址污染
    env["PUB_HOSTED_URL"] = "https://pub.dev"
    env.pop("FLUTTER_STORAGE_BASE_URL", None)

    log(f"TOOL_HOME       = {env['TOOL_HOME']}")
    log(f"DEVECO_SDK_HOME = {env['DEVECO_SDK_HOME']}")
    return env


def run(cmd: list[str], *, cwd: Path, env: dict[str, str]) -> None:
    log(f"$ {' '.join(cmd)}")
    proc = subprocess.run(cmd, cwd=str(cwd), env=env, shell=False)
    if proc.returncode != 0:
        fail(f"命令失败（exit={proc.returncode}）：{' '.join(cmd)}")


def find_tool(env: dict[str, str], name: str) -> str:
    """在已注入 PATH 的 env 里找可执行文件；Windows 上补 .bat。"""
    found = shutil.which(name, path=env.get("PATH"))
    if found:
        return found
    if os.name == "nt":
        found = shutil.which(f"{name}.bat", path=env.get("PATH"))
        if found:
            return found
    fail(f"在 PATH 里找不到 {name}（DevEco 工具链是否装全？）")


# ── 1.5 Web 构建期产物（gitignore，必须每次现场生成）────────────────────
# 这两步与 deploy-harmonyos.yml 的步骤一一对应，且**必须在 flutter build web 之前**
# 跑：Flutter 会把 web/ 目录整个拷进 build/web，晚于构建就等于没生成。
def generate_web_assets(env: dict[str, str]) -> None:
    step("生成 Web 构建期产物（drift worker / sqlite3.wasm）")

    # drift_worker.js：Web 端 drift 的 worker 线程入口，由 connection_web.dart 加载。
    dart = find_tool(env, "dart")
    run(
        [dart, "compile", "js", "web/drift_worker.dart", "-o", "web/drift_worker.js", "-O4"],
        cwd=REPO_ROOT,
        env=env,
    )

    # sqlite3.wasm：sqlite3.dart 的 Release 资产，按 pubspec.yaml 的 pin 下载并校验
    # sha256。GITHUB_TOKEN / GH_TOKEN 设了就用（Actions 里必有），本地匿名也行。
    run(
        [sys.executable, "scripts/web/fetch_sqlite3_wasm.py"],
        cwd=REPO_ROOT,
        env=env,
    )


def sync_generated_assets_into_build_web() -> None:
    """`--skip-web` 时把刚重建的两个产物同步进已有 build/web。

    跳过 `flutter build web` 意味着 `web/` → `build/web` 的拷贝不会发生，不同步的话
    后面的校验与 rawfile 拷贝仍会拿到上一轮的旧文件。
    """
    if not WEB_SRC.is_dir():
        fail(f"--skip-web 需要已有 Web 产物：{WEB_SRC} 不存在")

    for name in ("drift_worker.js", "sqlite3.wasm"):
        src = REPO_ROOT / "web" / name
        if not src.is_file():
            fail(f"缺少 {src.relative_to(REPO_ROOT)} —— generate_web_assets() 没有产出它")
        shutil.copy2(src, WEB_SRC / name)
    log("已把重建的 drift_worker.js / sqlite3.wasm 同步进 build/web")


def _dir_size(path: Path) -> int:
    return sum(p.stat().st_size for p in path.rglob("*") if p.is_file())


def trim_canvaskit() -> None:
    """裁掉壳内用不到的渲染器变体，与 `deploy-harmonyos.yml` 的上传前裁剪同口径。

    壳内钉死 canvaskit（`web/flutter_bootstrap.js` 的 renderer 与
    `--no-web-resources-cdn`），skwasm/wimp 永远用不到；`.js.symbols` 只是调试符号。
    不裁的话这 ~18 MB 会原样进 rawfile、进 HAP。
    """
    step("裁剪非必需 canvaskit 变体")
    canvaskit = WEB_SRC / "canvaskit"
    if not canvaskit.is_dir():
        log("WARN: build/web 里没有 canvaskit/ —— 跳过裁剪")
        return

    before = _dir_size(canvaskit)

    # 递归删：canvaskit/chromium/、canvaskit/webparagraph/ 这些子目录是不同浏览器
    # 能力档的实际产物，要保留；只有它们的 .js.symbols 调试符号没用了。
    for symbol in sorted(canvaskit.rglob("*.js.symbols")):
        symbol.unlink()
    for pattern in ("skwasm*", "wimp*"):
        for entry in sorted(canvaskit.glob(pattern)):
            if entry.is_dir():
                shutil.rmtree(entry)
            else:
                entry.unlink()

    after = _dir_size(canvaskit)
    log(f"canvaskit {before / 1024 / 1024:.1f} MB → {after / 1024 / 1024:.1f} MB（省 {(before - after) / 1024 / 1024:.1f} MB）")


# ── 2. Flutter Web 产物 ─────────────────────────────────────────────────
def build_web(env: dict[str, str], *, release: bool) -> None:
    step("flutter build web")
    flutter = find_tool(env, "flutter")

    # LUCENT_BASE_URL 在 release 构建里是**必填**的：base_url.dart 的
    # `configured` getter 在 kReleaseMode 且未配置时直接抛
    # StateError('LUCENT_BASE_URL must be configured in release builds.')，
    # 表现为应用卡在启动页 + console 里 ProviderException。
    # 本地联调默认指向宿主机的 Lucent 开发服务器（模拟器经 10.0.2.2 访问）；
    # 出正式包必须显式传真实 API 地址。
    base_url = os.environ.get("LUCENT_BASE_URL", "").strip()
    if not base_url:
        base_url = "http://10.0.2.2:3000"
        log(f"LUCENT_BASE_URL 未设置，使用本地开发默认值 {base_url}")
        log("（出正式包请显式设置 LUCENT_BASE_URL）")

    dart_defines = {
        "LUCENT_BASE_URL": base_url,
        "SENTRY_DSN": os.environ.get("SENTRY_DSN", ""),
        "SUPPORT_EMAIL": os.environ.get("SUPPORT_EMAIL", "support@luminous.app"),
    }
    cmd = [
        flutter, "build", "web",
        "--release",
        # 壳内是本地资源，不能带 GitHub Pages 的 /<repo>/ 前缀
        "--base-href", "/",
        # 否则运行时从 www.gstatic.com 拉 CanvasKit → 壳内白屏（计划 §4.1）
        "--no-web-resources-cdn",
    ]
    # 不加 --wasm：skwasm 在移动浏览器有内容区高度 0 的布局 bug
    for k, v in dart_defines.items():
        cmd += ["--dart-define", f"{k}={v}"]
    run(cmd, cwd=REPO_ROOT, env=env)


# ── 3. 产物自检（对应计划 §8.2 的 CI 断言，本地先拦一次）────────────────
def validate_web_artifacts() -> None:
    step("校验 Web 产物")

    if not WEB_SRC.is_dir():
        fail(f"未找到 Web 产物：{WEB_SRC}（先跑 flutter build web，或去掉 --skip-web）")

    bootstrap = WEB_SRC / "flutter_bootstrap.js"
    if not bootstrap.is_file():
        fail("缺少 flutter_bootstrap.js")

    text = bootstrap.read_text(encoding="utf-8", errors="replace")
    # loader 自身也有 "!e.useLocalCanvasKit" 这种读取方，不能整文件匹配；
    # 只取 _flutter.buildConfig = {...}; 这一段。
    m = re.search(r"_flutter\.buildConfig\s*=\s*(\{.*?\});", text, re.S)
    if not m:
        fail("flutter_bootstrap.js 里找不到 _flutter.buildConfig —— 产物结构异常")
    if not re.search(r'"useLocalCanvasKit"\s*:\s*true', m.group(1)):
        fail(
            'buildConfig 缺少 "useLocalCanvasKit":true —— 壳内会从 www.gstatic.com '
            "拉 CanvasKit 导致白屏。构建时是否漏了 --no-web-resources-cdn？"
        )
    log("useLocalCanvasKit = true（CanvasKit 走本地，不会拉 CDN）")

    index_html = WEB_SRC / "index.html"
    if not index_html.is_file():
        fail("缺少 index.html")
    html = index_html.read_text(encoding="utf-8", errors="replace")
    if '<base href="/"' not in html:
        # 硬失败：base href 不是 "/" 时，壳内（平铺在 rawfile 根）相对路径会错位，
        # 症状是 index.html 能加载而 flutter_bootstrap.js 404。
        # 与 .github/workflows/deploy-harmonyos.yml 的断言口径一致。
        fail(
            'index.html 的 <base href> 不是 "/" —— 壳内相对路径会错位。'
            "构建时是否漏了 --base-href \"/\"？"
        )
    log("base href = /")

    for name in ("sqlite3.wasm", "drift_worker.js"):
        if not (WEB_SRC / name).is_file():
            fail(f"缺少 {name} —— 它俩是构建期产物、不入库，必须由构建流程现场生成")

    files = [p for p in WEB_SRC.rglob("*") if p.is_file()]
    total_mb = sum(p.stat().st_size for p in files) / (1024 * 1024)
    log(f"Web 产物：{len(files)} 文件 / {total_mb:.1f} MB")


# ── 4. 平铺进 rawfile 根（gitignored）──────────────────────────────────
def copy_web_to_rawfile() -> None:
    step("拷贝产物到 rawfile 根")

    # 清掉上一轮产物：rawfile 根下除本脚本生成的之外没有其它东西，
    # 但为保险只删「与 build/web 顶层同名」的条目 + 历史遗留的 web/ 子目录。
    if RAWFILE_DIR.exists():
        legacy_web = RAWFILE_DIR / "web"
        if legacy_web.is_dir():
            shutil.rmtree(legacy_web)
        for entry in WEB_SRC.iterdir():
            target = RAWFILE_DIR / entry.name
            if target.is_dir():
                shutil.rmtree(target)
            elif target.exists():
                target.unlink()
    RAWFILE_DIR.mkdir(parents=True, exist_ok=True)

    shutil.copytree(WEB_SRC, RAWFILE_DIR, dirs_exist_ok=True)
    copied = sum(1 for p in RAWFILE_DIR.rglob("*") if p.is_file())
    log(f"已平铺 {copied} 个文件 → {RAWFILE_DIR.relative_to(REPO_ROOT)}")

    # 回退字体（fonts/）由 fetch_fallback_fonts.py 单独维护，不进 git，
    # 也不随 build/web 覆盖。缺了不会构建失败，但 CJK 文字会显示成方块（口口口），
    # 所以要显式告警并给出具体命令。
    font_dir = RAWFILE_DIR / "fonts"
    if font_dir.is_dir():
        n_font = sum(1 for p in font_dir.rglob("*.woff2") if p.is_file())
        log(f"回退字体：{n_font} 个 woff2（fonts/）")
        if n_font == 0:
            log("WARN: fonts/ 存在但没有 woff2 —— 中文会显示为方块。")
            log("      跑：python scripts/ohos/fetch_fallback_fonts.py --all")
    else:
        log("WARN: 缺少 fonts/ —— 中文会显示为方块（口口口）。")
        log("      跑：python scripts/ohos/fetch_fallback_fonts.py --all")


# ── 5. hvigorw assembleHap ──────────────────────────────────────────────
def build_hap(env: dict[str, str], *, release: bool) -> None:
    step("hvigorw assembleHap")

    if not (OHOS_DIR / "oh_modules").is_dir():
        log("oh_modules 缺失，先跑 ohpm install")
        run([find_tool(env, "ohpm"), "install"], cwd=OHOS_DIR, env=env)

    build_mode = "release" if release else "debug"
    run(
        [
            find_tool(env, "hvigorw"),
            "assembleHap",
            "--mode", "module",
            "-p", "product=default",
            "-p", f"buildMode={build_mode}",
            "--no-daemon",
        ],
        cwd=OHOS_DIR,
        env=env,
    )


# ── 6. 汇报产物 ─────────────────────────────────────────────────────────
def report() -> None:
    if not HAP_OUT_DIR.is_dir():
        log(f"WARN: 未找到产物目录：{HAP_OUT_DIR}")
        return
    haps = sorted(HAP_OUT_DIR.glob("*.hap"))
    if not haps:
        log(f"WARN: 产物目录里没有 .hap：{HAP_OUT_DIR}")
        return
    log("")
    for hap in haps:
        log(f"产物：{hap}  ({hap.stat().st_size / (1024 * 1024):.1f} MB)")


def main() -> None:
    parser = argparse.ArgumentParser(description="构建鸿蒙 HAP")
    parser.add_argument("--release", action="store_true", help="构建 release 模式（默认 debug）")
    parser.add_argument("--skip-web", action="store_true", help="跳过 flutter build web，复用现有 build/web")
    parser.add_argument(
        "--deveco-home",
        default=str(DEFAULT_DEVECO_HOME),
        help=f"DevEco Studio 安装目录（默认 {DEFAULT_DEVECO_HOME}）",
    )
    args = parser.parse_args()

    if not OHOS_DIR.is_dir():
        fail(f"未找到 ohos/ 工程：{OHOS_DIR}")

    env = setup_toolchain(Path(args.deveco_home))

    # 顺序与 deploy-harmonyos.yml 一致：先生成 Web 构建期产物，再 flutter build web。
    generate_web_assets(env)
    if args.skip_web:
        sync_generated_assets_into_build_web()
    else:
        build_web(env, release=args.release)

    validate_web_artifacts()
    trim_canvaskit()
    copy_web_to_rawfile()
    build_hap(env, release=args.release)
    report()


if __name__ == "__main__":
    main()
