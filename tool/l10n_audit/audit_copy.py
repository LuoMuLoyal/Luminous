"""Luminous 文案长度审计（几何口径版）。

槽位上限不靠感觉，来自设计系统的真实几何（见 derive_limits.py）：
  可用文字宽度 = LayoutScaleResolver.designBaselineTextWidth = 320dp
  正文档 sm = 14px，ASCII 均宽 0.5em，CJK 1.0em
  → 单行 EN≈45 / CJK≈22 字；双行 EN≈90 / CJK≈44 字
统一用"视觉宽度"（CJK/全角计 2，ASCII 计 1）表达，中英文共用一套数字。

规范依据（一手来源，逐条可复核）：
1. Apple HIG / Lists and tables：列表行文案须简短以利扫读、避免换行与截断；
   内容多时"只列标题，详情放到下一层"。
2. Apple HIG / Writing：设置项只描述"打开后做什么"；错误信息说明"怎么修"；
   空状态必须给明确下一步。
3. NN/g / The 3 C's of Informational Microcopy：microcopy 定义即少于 3 句，
   concision 的目的是不被截断。
4. Apple Style Guide / Microsoft Writing Style Guide：简洁、动词开头、删冗余修饰。

槽位判定：按 key 后缀，仅采信确实指示 UI 槽位的后缀。业务名词后缀
（SpecialGroup / Water / Sleep 等）说明不了槽位，不判长度，单列待人工复审。
"""

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
while not (ROOT / "pubspec.yaml").exists():
    ROOT = ROOT.parent
ARB_DIR = ROOT / "lib" / "l10n"

ONE_LINE = 45
TWO_LINE = 90
THREE_LINE = 135

# 规范给的是推荐值，实作要更严。在几何容量之上再留 20% 余量，理由：
#   1. 0.5em 是 ASCII 平均字宽，W/M/@ 等宽字形接近 0.7em，按平均算会低估；
#   2. 行内普遍带前置图标 + 间距（约 26dp），几何容量未扣这部分；
#   3. 中英混排（如 "AI 分析"）打破单一字宽假设。
# 余量后仍放不下，说明内容不该待在行内槽位——按 HIG 下沉到详情页或分组 footer，
# 而不是申请豁免。
STRICT_FACTOR = 0.8

# 严格阈值 = 几何容量 × STRICT_FACTOR（向下取整）。
# 规范推荐值 → 本项目实作值：
#   单行 45 → 36    双行 90 → 72    三行 135 → 108    免责 180 → 144
#   按钮 24 → 19    徽标 14 → 11    标签 30 → 24      状态 20 → 16
#   单位  8 →  6    计数 20 → 16    范围 24 → 19
S_ONE = int(ONE_LINE * STRICT_FACTOR)
S_TWO = int(TWO_LINE * STRICT_FACTOR)
S_THREE = int(THREE_LINE * STRICT_FACTOR)

SLOTS = {
    "Action": (19, "单行", "按钮/操作：HIG 要求动词开头且简短；截断即失败"),
    "Button": (19, "单行", "按钮：同 Action"),
    "Confirm": (19, "单行", "确认按钮"),
    "Cancel": (19, "单行", "取消按钮"),
    "Retry": (19, "单行", "重试按钮"),
    "All": (19, "单行", "全选类操作"),
    "More": (19, "单行", "更多类操作"),
    "Back": (19, "单行", "返回"),
    "Close": (19, "单行", "关闭"),
    "Remove": (19, "单行", "移除"),
    "Delete": (19, "单行", "删除"),
    "Save": (19, "单行", "保存"),
    "Edit": (19, "单行", "编辑"),
    "Search": (19, "单行", "搜索"),
    "Copy": (19, "单行", "复制"),
    "Share": (19, "单行", "分享"),
    "Export": (19, "单行", "导出"),
    "Import": (19, "单行", "导入"),
    "Login": (19, "单行", "登录"),
    "Logout": (19, "单行", "登出"),
    "Skip": (19, "单行", "跳过"),
    "Next": (19, "单行", "下一步"),
    "Continue": (19, "单行", "继续"),
    "Submit": (19, "单行", "提交"),
    "Title": (S_ONE, "单行", "列表行标题：HIG succinct，保证单行"),
    "Section": (S_ONE, "单行", "区块标题"),
    "Header": (S_ONE, "单行", "区块头"),
    "Empty": (S_TWO, "双行", "空态标题"),
    "State": (S_ONE, "单行", "状态标题"),
    "Badge": (11, "单行", "徽标：极短，否则挤压 Row"),
    "Label": (24, "单行", "字段/控件标签：需与内容同行"),
    "Status": (16, "单行", "状态词：单行状态位"),
    "Unit": (6, "单行", "单位：只能是符号"),
    "Count": (16, "单行", "计数短句"),
    "Name": (S_ONE, "单行", "名称类"),
    "Value": (S_ONE, "单行", "取值类"),
    "Group": (S_ONE, "单行", "分组标签"),
    "Range": (19, "单行", "范围标签"),
    "Subtitle": (S_TWO, "双行", "列表行副标题：超双行应下沉详情页或改分组 footer"),
    "Hint": (S_TWO, "双行", "输入提示/占位：可含一个示例，不应成段"),
    "Placeholder": (S_TWO, "双行", "占位符：同 Hint"),
    "Prompt": (S_TWO, "双行", "引导语"),
    "Tooltip": (S_TWO, "双行", "Tooltip：悬停短句"),
    "Toast": (S_TWO, "双行", "Toast：1.8s 内需读完，超双行即无效"),
    "Description": (S_THREE, "三行", "空态/区块说明：<=2 句且给下一步"),
    "Desc": (S_THREE, "三行", "说明：<=2 句"),
    "Body": (S_THREE, "三行", "正文：<=2 句"),
    "Message": (S_THREE, "三行", "消息体：<=2 句"),
    "Detail": (S_THREE, "三行", "详情：<=2 句"),
    "Note": (S_THREE, "三行", "注解：<=2 句"),
    "Info": (S_THREE, "三行", "信息说明：<=2 句"),
    "Summary": (S_THREE, "三行", "摘要：<=2 句"),
    "Notice": (S_THREE, "三行", "告知：<=2 句"),
    "Warning": (S_THREE, "三行", "警示：<=2 句"),
    "Rule": (S_THREE, "三行", "规则说明"),
    "Disclaimer": (int(180 * STRICT_FACTOR), "四行", "免责声明：法务文本，允许更长"),
    "Text": (int(180 * STRICT_FACTOR), "四行", "自由文本：按 Disclaimer 上限"),
    "Error": (S_THREE, "三行", "错误：说明如何修复，简洁优先"),
    "Failed": (S_THREE, "三行", "失败说明"),
    "Unavailable": (S_THREE, "三行", "不可用说明"),
    "Missing": (S_THREE, "三行", "缺失说明"),
    "Unsupported": (S_THREE, "三行", "不支持说明"),
    "Timeout": (S_THREE, "三行", "超时说明"),
    "Rejected": (S_THREE, "三行", "拒绝说明"),
    "Invalid": (S_THREE, "三行", "无效输入：须给出正确格式"),
    "Interrupted": (S_THREE, "三行", "中断说明"),
    "Gap": (S_THREE, "三行", "缺口说明"),
}

SENTENCE_LIMITED = {
    "Description", "Desc", "Body", "Message", "Detail", "Note", "Info",
    "Summary", "Notice", "Warning", "Error", "Failed", "Unavailable",
    "Missing", "Unsupported", "Timeout", "Rejected", "Invalid",
    "Interrupted", "Gap", "Disclaimer", "Text", "Rule", "Empty", "Hint",
    "Prompt", "Subtitle",
}

# 「错误信息是否说清怎么修」不做自动判定：动作常常落在旁边的按钮上
# （如 `healthSyncResultFailed` = "Sync failed" + 重试按钮），静态看文本必然误报。
# 这一项改为计划文档里的人工复核清单。

# 缩写点号不应被当作句末：e.g. / i.e. / etc. / vs. / approx.
ABBREV = re.compile(r"\b(e\.g|i\.e|etc|vs|approx|no|fig|ver)\.", re.I)

EXEMPT = {"appTitle"}


def vw(s: str) -> int:
    return sum(2 if ("\u2e80" <= c <= "\u9fff" or "\uff00" <= c <= "\uffef") else 1
               for c in s)


PLURAL = re.compile(r"\b(plural|select|selectordinal)\s*,")


def strip_icu(s) -> str:
    """取 ICU 消息里最长的一段自然语言，用于量长度。

    - 有 plural/select 块：取最长分支（用户实际要读的那句）。
    - 只有占位符（如 `{count}`）：占位符运行时渲染成数字，量长度时替换为 1 位，
      否则 `还有 {count} 条…` 会被误算成 5 个字符宽。
    """
    if not isinstance(s, str):
        return ""
    if PLURAL.search(s):
        b = re.findall(r"\{([^{}]*)\}", s)
        if b:
            cand = max(b, key=lambda x: vw(re.sub(r"\{[^{}]*\}", "5", x)))
            return re.sub(r"\{[^{}]*\}", "5", cand)
    return re.sub(r"\{[^{}]*\}", "5", s)


def sentences(s: str) -> int:
    """统计句数。先把缩写点号（e.g. / i.e. / etc.）替换掉，避免误判成句末。"""
    s = ABBREV.sub(lambda m: m.group(0)[:-1] + "\x00", s)
    return len([p for p in re.split(r"[.!?。！？]+", s) if p.strip()])


def main() -> int:
    data = {}
    for lg in ("en", "zh"):
        raw = json.loads((ARB_DIR / f"app_{lg}.arb").read_text(encoding="utf-8"))
        data[lg] = {k: v for k, v in raw.items() if not k.startswith("@")}

    keys = sorted(set(data["en"]) & set(data["zh"]))
    rows, unreviewed = [], []

    for k in keys:
        if k in EXEMPT:
            continue
        m = re.search(r"([A-Z][a-z]+)$", k)
        suf = m.group(1) if m else None
        if suf not in SLOTS:
            unreviewed.append(k)
            continue
        limit, lines, why = SLOTS[suf]
        en_t, zh_t = strip_icu(data["en"][k]), strip_icu(data["zh"][k])
        en_w, zh_w = vw(en_t), vw(zh_t)
        probs = []
        if en_w > limit:
            probs.append(f"en {en_w}>{limit}")
        if zh_w > limit:
            probs.append(f"zh {zh_w}>{limit}")
        if suf in SENTENCE_LIMITED:
            if sentences(en_t) > 2:
                probs.append(f"en {sentences(en_t)}句>2")
            if sentences(zh_t) > 2:
                probs.append(f"zh {sentences(zh_t)}句>2")
        rows.append({
            "key": k, "slot": suf, "lines": lines,
            "en": en_t, "zh": zh_t, "en_w": en_w, "zh_w": zh_w,
            "limit": limit, "problems": probs, "rationale": why,
            "overage": max(en_w - limit, zh_w - limit),
        })

    violations = sorted([r for r in rows if r["problems"]],
                        key=lambda r: -r["overage"])
    by_slot = {}
    for r in violations:
        by_slot.setdefault(r["slot"], []).append(r)
    totals = {}
    for r in rows:
        totals[r["slot"]] = totals.get(r["slot"], 0) + 1

    result = {
        "total_keys": len(keys),
        "audited": len(rows),
        "unreviewed": len(unreviewed),
        "violations": len(violations),
        "violations_by_slot": {s: len(v) for s, v in
                               sorted(by_slot.items(), key=lambda x: -len(x[1]))},
        "slot_totals": totals,
        "geometry": {"baseline_width": 320, "one_line": ONE_LINE,
                     "two_line": TWO_LINE, "three_line": THREE_LINE},
        "rows": violations,
        "unreviewed_keys": unreviewed,
    }
    (ROOT / "tool/l10n_audit/out.json").write_text(
        json.dumps(result, ensure_ascii=False, indent=1), encoding="utf-8")

    print(f"总 key      : {len(keys)}")
    print(f"已判槽位    : {len(rows)}")
    print(f"未判槽位    : {len(unreviewed)}  (业务名词后缀，不判长度)")
    print(f"超限        : {len(violations)}")
    print()
    print("超限分布:")
    for s, n in result["violations_by_slot"].items():
        tot = totals.get(s, 0)
        print(f"  {s:12} {n:4}/{tot:<4} {n*100//max(tot,1):3}%")
    print()
    print("最严重 30:")
    for r in violations[:30]:
        print(f"  [{r['slot']:11}] {r['key']:48} {' '.join(r['problems'])}")
    print()
    print(f"wrote {ROOT / 'tool/l10n_audit/out.json'}")
    # 不合格一律按错误处理：有超限即非零退出，可直接用于门禁/脚本。
    if violations:
        print(f"\nFAIL: {len(violations)} 条文案超槽位阈值")
        return 1
    print("\nOK: 全部文案在槽位阈值内")
    return 0


if __name__ == "__main__":
    sys.exit(main())
