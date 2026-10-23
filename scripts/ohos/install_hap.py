#!/usr/bin/env python3
"""把构建好的 HAP 安装到已连接的 HarmonyOS 设备/模拟器，并可选拉起应用。

用法：
    python scripts/ohos/install_hap.py                 # 装最新 HAP
    python scripts/ohos/install_hap.py --launch        # 装完直接拉起
    python scripts/ohos/install_hap.py --logs          # 装完后持续打印 hilog 过滤 LuminousWeb
    python scripts/ohos/install_hap.py --hap path/to/x.hap

前置：DevEco Studio 已安装（可用 --deveco-home 覆盖）；设备已通过 hdc 连接
（模拟器启动后 hdc list targets 应能看到设备）。

注意：未签名 HAP 在真机上通常装不上（需先配 signingConfigs），模拟器一般可跳过签名。
"""

from __future__ import annotations

import argparse
import subprocess
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
OHOS_DIR = REPO_ROOT / "ohos"
HAP_OUT_DIR = OHOS_DIR / "entry" / "build" / "default" / "outputs" / "default"
DEFAULT_DEVECO_HOME = Path(r"E:\DevEco Studio")

# 与 ohos/AppScope/app.json5 的 bundleName 一致
BUNDLE_NAME = "com.devluo.luminous"


def log(msg: str) -> None:
    print(msg, flush=True)


def fail(msg: str) -> "NoReturn":
    print(f"ERROR: {msg}", file=sys.stderr, flush=True)
    raise SystemExit(1)


def hdc_path(deveco_home: Path) -> Path:
    p = deveco_home / "sdk" / "default" / "openharmony" / "toolchains" / "hdc.exe"
    if not p.is_file():
        fail(f"未找到 hdc：{p}")
    return p


def run(cmd: list[str], *, capture: bool = False) -> subprocess.CompletedProcess:
    log(f"$ {' '.join(cmd)}")
    return subprocess.run(cmd, capture_output=capture, text=True)


def list_targets(hdc: str) -> list[str]:
    proc = run([hdc, "list", "targets"], capture=True)
    raw = (proc.stdout or "") + (proc.stderr or "")
    targets = []
    for line in raw.splitlines():
        line = line.strip()
        if not line or line == "[Empty]":
            continue
        # 正常输出形如 "127.0.0.1:5555" 或 "FMR0223C13000649"
        targets.append(line)
    return targets


def pick_hap(explicit: str | None) -> Path:
    if explicit:
        p = Path(explicit)
        if not p.is_file():
            fail(f"指定的 HAP 不存在：{p}")
        return p
    if not HAP_OUT_DIR.is_dir():
        fail(f"未找到产物目录：{HAP_OUT_DIR}（先跑 python scripts/ohos/build_hap.py）")
    haps = sorted(HAP_OUT_DIR.glob("*.hap"), key=lambda x: x.stat().st_mtime, reverse=True)
    if not haps:
        fail(f"产物目录里没有 .hap：{HAP_OUT_DIR}")
    if len(haps) > 1:
        log(f"发现 {len(haps)} 个 HAP，取最新的一个：{haps[0].name}")
    return haps[0]


def main() -> None:
    parser = argparse.ArgumentParser(description="安装 HAP 到鸿蒙设备/模拟器")
    parser.add_argument("--hap", default=None, help="指定 HAP 路径（默认取最新产物）")
    parser.add_argument("--launch", action="store_true", help="安装后拉起应用")
    parser.add_argument("--logs", action="store_true", help="安装后持续打印 LuminousWeb 相关 hilog")
    parser.add_argument(
        "--deveco-home",
        default=str(DEFAULT_DEVECO_HOME),
        help=f"DevEco Studio 安装目录（默认 {DEFAULT_DEVECO_HOME}）",
    )
    args = parser.parse_args()

    hdc = str(hdc_path(Path(args.deveco_home)))

    targets = list_targets(hdc)
    if not targets:
        fail(
            "hdc 没有识别到设备。检查：\n"
            "  1) 模拟器是否已完全开机（开机过程中 hdc 看不到设备）\n"
            "  2) 真机是否开启 USB 调试并已授权\n"
            "  3) 跑一次：hdc list targets"
        )
    log(f"设备：{', '.join(targets)}")

    hap = pick_hap(args.hap)
    log(f"HAP：{hap}  ({hap.stat().st_size / (1024 * 1024):.1f} MB)")

    proc = run([hdc, "install", "-r", str(hap)])
    if proc.returncode != 0:
        fail(
            f"安装失败（exit={proc.returncode}）。常见原因：\n"
            "  - 未签名 HAP 在真机上装不上 → 需在 DevEco 的 Project Structure → "
            "Signing Configs 勾选自动签名，重新构建后再装\n"
            "  - 设备空间不足或包名冲突 → 试 hdc uninstall " + BUNDLE_NAME
        )
    log("安装成功")

    if args.launch or args.logs:
        # Ability 全名 = bundleName/EntryAbility
        run([hdc, "shell", "aa", "start", "-a", "EntryAbility", "-b", BUNDLE_NAME])

    if args.logs:
        log("")
        log("持续打印 hilog（Ctrl+C 停止）。关注 tag=LuminousWeb 的 pageBegin / pageEnd / console / errorReceive")
        try:
            subprocess.run([hdc, "hilog"], text=True)
        except KeyboardInterrupt:
            log("\n已停止")


if __name__ == "__main__":
    main()
