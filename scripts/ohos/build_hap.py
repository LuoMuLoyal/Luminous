#!/usr/bin/env python3
"""构建鸿蒙 HAP：Flutter Web 产物 → ohos rawfile → hvigorw assembleHap

用法（从任意目录执行均可，脚本自己定位仓库根）：

    python scripts/ohos/build_hap.py                # debug
    python scripts/ohos/build_hap.py --release      # release
    python scripts/ohos/build_hap.py --skip-web     # 复用现有 build/web

前置：DevEco Studio 已安装（默认 E:\\DevEco Studio，可用 --deveco-home 覆盖）。
产物：ohos/entry/build/default/outputs/default/entry-default-*.hap

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
WEB_DST = OHOS_DIR / "entry" / "src" / "main" / "resources" / "rawfile" / "web"
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


# ── 2. Flutter Web 产物 ─────────────────────────────────────────────────
def build_web(env: dict[str, str], *, release: bool) -> None:
    step("flutter build web")
    flutter = find_tool(env, "flutter")
    dart_defines = {
        "LUCENT_BASE_URL": os.environ.get("LUCENT_BASE_URL", ""),
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
    if index_html.is_file():
        html = index_html.read_text(encoding="utf-8", errors="replace")
        if '<base href="/"' not in html:
            log('WARN: index.html 的 <base href> 不是 "/"，本地加载时相对路径可能错位')
    else:
        fail("缺少 index.html")

    for name in ("sqlite3.wasm", "drift_worker.js"):
        if not (WEB_SRC / name).is_file():
            fail(f"缺少 {name} —— 它俩是构建期产物、不入库，必须由构建流程现场生成")

    files = [p for p in WEB_SRC.rglob("*") if p.is_file()]
    total_mb = sum(p.stat().st_size for p in files) / (1024 * 1024)
    log(f"Web 产物：{len(files)} 文件 / {total_mb:.1f} MB")


# ── 4. 拷进 rawfile（gitignored）────────────────────────────────────────
def copy_web_to_rawfile() -> None:
    step("拷贝产物到 rawfile/web")
    if WEB_DST.exists():
        shutil.rmtree(WEB_DST)
    WEB_DST.mkdir(parents=True, exist_ok=True)
    shutil.copytree(WEB_SRC, WEB_DST, dirs_exist_ok=True)
    copied = sum(1 for _ in WEB_DST.rglob("*") if _.is_file())
    log(f"已拷贝 {copied} 个文件 → {WEB_DST.relative_to(REPO_ROOT)}")


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

    if not args.skip_web:
        build_web(env, release=args.release)

    validate_web_artifacts()
    copy_web_to_rawfile()
    build_hap(env, release=args.release)
    report()


if __name__ == "__main__":
    main()
