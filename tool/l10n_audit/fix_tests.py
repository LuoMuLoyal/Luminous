"""把测试里断言旧文案的字面量换成新文案（计划第八节的剩余事项）。

只替换测试文件里出现的旧串；新串从分片读取，避免手抄出错。
"""
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = "cfa29801"  # 改写前的提交


def at(ref: str, path: str) -> dict:
    r = subprocess.run(["git", "show", f"{ref}:{path}"], capture_output=True,
                       text=True, encoding="utf-8")
    return json.loads(r.stdout) if r.stdout.strip() else {}


def main() -> int:
    tests = sorted(Path("test").rglob("*.dart"))
    blob = {p: p.read_text(encoding="utf-8") for p in tests}

    # 收集 旧串 -> 新串。git show 需要仓库相对路径（不带盘符）。
    pairs: dict[str, str] = {}
    for frag in sorted(Path("lib/l10n/src").glob("*.arb")):
        old = at(BASE, frag.as_posix())
        new = json.loads(frag.read_text(encoding="utf-8"))
        for k, o in old.items():
            if k.startswith("@") or not isinstance(o, str):
                continue
            n = new.get(k)
            if n is None or n == o or not isinstance(n, str):
                continue
            # 带 ICU 的整串不做字面替换（分支文本替换易错），单独报告
            if "{" in o or "{" in n:
                continue
            pairs.setdefault(o, n)

    print(f"待替换旧串 {len(pairs)} 条")

    changed = 0
    for p, txt in blob.items():
        orig = txt
        for o, n in pairs.items():
            if o in txt:
                txt = txt.replace(o, n)
        if txt != orig:
            p.write_text(txt, encoding="utf-8")
            changed += 1
            print(f"  updated {p}")

    print(f"\n更新 {changed} 个测试文件")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
