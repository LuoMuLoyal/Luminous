"""按 feature 分组，列出所有超过单行容量的条目，供人工逐条审读。

单行容量 45 视觉宽（=320dp / 14px / ASCII 0.5em），CJK 计 2。
只做筛选，不做判定——判定由人读原文得出。
"""

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
while not (ROOT / "pubspec.yaml").exists():
    ROOT = ROOT.parent


def vw(s):
    return sum(2 if ("\u2e80" <= c <= "\u9fff" or "\uff00" <= c <= "\uffef") else 1
               for c in s)


PLURAL = re.compile(r"\b(plural|select|selectordinal)\s*,")


def strip_icu(s):
    """取 ICU 消息里最长的一段自然语言，用于量长度。

    两种情形必须分开处理：
    - 有 plural/select 块：取其中最长分支（用户实际要读的那句）。
    - 只有占位符（如 `{count}`）：占位符运行时渲染成很短的数字，量长度时应剔除，
      否则 `还有 {count} 条…` 会被误算成只有 5 个字符宽。
    """
    if not isinstance(s, str):
        return ""
    if PLURAL.search(s):
        b = re.findall(r"\{([^{}]*)\}", s)
        if b:
            return re.sub(r"\{[^{}]*\}", "5", max(b, key=lambda x: len(re.sub(r"\{[^{}]*\}", "5", x))))
    return re.sub(r"\{[^{}]*\}", "5", s)


en = json.loads((ROOT / "lib/l10n/app_en.arb").read_text(encoding="utf-8"))
zh = json.loads((ROOT / "lib/l10n/app_zh.arb").read_text(encoding="utf-8"))
keys = [k for k in en if not k.startswith("@")]

# feature = 第一个驼峰段
groups = {}
for k in keys:
    m = re.match(r"([a-z]+)", k)
    feat = m.group(1) if m else "other"
    e, z = strip_icu(en[k]), strip_icu(zh[k])
    ew, zw = vw(e), vw(z)
    if ew <= 45 and zw <= 45:
        continue
    groups.setdefault(feat, []).append((max(ew, zw), k, e, z, ew, zw))

feat = sys.argv[1] if len(sys.argv) > 1 else None
lo = int(sys.argv[2]) if len(sys.argv) > 2 else 0
hi = int(sys.argv[3]) if len(sys.argv) > 3 else 10 ** 9

order = [feat] if feat else sorted(groups, key=lambda f: -len(groups[f]))
for f in order:
    items = sorted(groups.get(f, []), reverse=True)[lo:hi]
    if not items:
        continue
    print(f"\n{'='*100}\n## {f}  ({len(groups.get(f, []))} 条超单行)\n{'='*100}")
    for _, k, e, z, ew, zw in items:
        print(f"\n{k}   [EN {ew} / ZH {zw}]")
        print(f"  EN: {e}")
        print(f"  ZH: {z}")
