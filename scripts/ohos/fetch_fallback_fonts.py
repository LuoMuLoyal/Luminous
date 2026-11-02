"""下载 Flutter Web 的 Noto Sans SC 回退字体切片到 ohos rawfile。

Flutter Web 的中文字形不在构建产物里，运行时按需从 fonts.gstatic.com 拉；
鸿蒙壳（以及国内网络）访问不到，表现为文字全是方块。
本脚本把 notosanssc 的切片下到 rawfile/fonts/，配合 Index.ets 的
onInterceptRequest 把 fonts.gstatic.com 的请求重定向到本地文件。

用法：
    python scripts/ohos/fetch_fallback_fonts.py            # 默认 --family notosanssc
    python scripts/ohos/fetch_fallback_fonts.py --dry-run  # 只统计体积
"""

from __future__ import annotations

import argparse
import re
import sys
import urllib.request
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
RAWFILE_DIR = REPO_ROOT / "ohos" / "entry" / "src" / "main" / "resources" / "rawfile"
FONT_DST = RAWFILE_DIR / "fonts"

# 引擎里回退字体清单的权威来源（随 Flutter 版本变化）
FALLBACK_DATA = Path(
    r"D:\flutter\bin\cache\flutter_web_sdk\lib\ui\src\engine\font_fallback_data.dart"
)
BASE_URL = "https://fonts.gstatic.com/s/"


def log(msg: str) -> None:
    print(msg, flush=True)


def all_paths() -> list[str]:
    """全部回退字体切片（不限家族）。"""
    if not FALLBACK_DATA.is_file():
        sys.exit(f"找不到 Flutter 回退字体清单：{FALLBACK_DATA}\n（先跑一次 flutter build web 生成 flutter_web_sdk）")
    return re.findall(r"'([a-z0-9]+/v\d+/[^']+\.woff2)'", FALLBACK_DATA.read_text(encoding="utf-8"))


def slices_for(family: str) -> list[str]:
    if not FALLBACK_DATA.is_file():
        sys.exit(f"找不到 Flutter 回退字体清单：{FALLBACK_DATA}\n（先跑一次 flutter build web 生成 flutter_web_sdk）")
    t = FALLBACK_DATA.read_text(encoding="utf-8")
    paths = re.findall(r"'([a-z0-9]+/v\d+/[^']+\.woff2)'", t)
    got = [p for p in paths if p.startswith(family + "/")]
    if not got:
        sys.exit(f"清单里没有字体家族 {family}")
    return got


# 壳内实测会请求到的 CJK 家族：模拟器/系统语言决定用哪一个（zh-CN 实测走 notosanstc），
# 四个都下，避免换设备/换语言又出现方块。
CJK_FAMILIES = ["notosanssc", "notosanstc", "notosanshk", "notosansjp", "notosanskr", "notosans"]


def main() -> None:
    ap = argparse.ArgumentParser(description="下载 Flutter Web 回退字体切片")
    ap.add_argument("--family", default=None, help="只下某个字体家族目录名（如 notosanssc）")
    ap.add_argument("--all", action="store_true", help=f"下载壳内需要的全部 CJK 家族：{', '.join(CJK_FAMILIES)}")
    ap.add_argument("--dry-run", action="store_true", help="只统计数量与体积，不下载")
    args = ap.parse_args()

    if args.all:
        rels = [p for p in all_paths() if p.split("/")[0] in CJK_FAMILIES]
        label = f"全部 CJK 家族（{len(CJK_FAMILIES)} 个）"
    else:
        family = args.family or "notosanssc"
        rels = slices_for(family)
        label = family
    log(f"{label}：{len(rels)} 个切片")

    if args.dry_run:
        total = 0
        for i, rel in enumerate(rels[:10], 1):
            url = BASE_URL + rel
            with urllib.request.urlopen(url, timeout=30) as r:
                n = len(r.read())
            total += n
            log(f"  [{i}] {rel.split('/')[-1]}  {n / 1024:.0f} KB")
        avg = total / min(10, len(rels))
        log(f"前 {min(10, len(rels))} 个平均 {avg / 1024:.0f} KB → 估算总计 ≈ {avg * len(rels) / 1024 / 1024:.1f} MB")
        return

    FONT_DST.mkdir(parents=True, exist_ok=True)
    total = 0
    for i, rel in enumerate(rels, 1):
        dst = FONT_DST / rel
        dst.parent.mkdir(parents=True, exist_ok=True)
        if dst.is_file() and dst.stat().st_size > 0:
            total += dst.stat().st_size
            continue
        url = BASE_URL + rel
        with urllib.request.urlopen(url, timeout=60) as r:
            data = r.read()
        dst.write_bytes(data)
        total += len(data)
        if i % 20 == 0 or i == len(rels):
            log(f"  已下 {i}/{len(rels)}  累计 {total / 1024 / 1024:.1f} MB")

    log(f"完成：{len(rels)} 个切片，共 {total / 1024 / 1024:.1f} MB → {FONT_DST.relative_to(REPO_ROOT)}")


if __name__ == "__main__":
    main()
