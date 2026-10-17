"""从设计系统的实际几何推导每个槽位的字符上限。

不靠感觉定上限，而是算：
  可用文字宽度 = LayoutScaleResolver.designBaselineTextWidth = 320dp
  字号阶      = Forui desktop 基线 10/12/14/16/18/20（xs2/xs/sm/md/lg/xl）
  平均字宽    = ASCII 约 0.5em，CJK 恒为 1.0em（全角）
  → 每行可容纳字符数 = 320 / 字宽

这给出"单行 / 双行"两档的客观容量，槽位上限即从这里取。
"""

BASELINE_WIDTH = 320.0
TYPE_SCALE = {"xs2": 10, "xs": 12, "sm": 14, "md": 16, "lg": 18, "xl": 20}

# 平均字宽系数（拉丁字体的经验值；CJK 固定 1.0em）
AVG_ASCII_EM = 0.5

print(f"{'档位':6}{'px':>4}{'EN单行':>9}{'EN双行':>9}{'CJK单行':>9}{'CJK双行':>9}")
print("-" * 48)
for name, px in TYPE_SCALE.items():
    en_per_char = px * AVG_ASCII_EM
    en1 = int(BASELINE_WIDTH / en_per_char)
    cjk1 = int(BASELINE_WIDTH / px)
    print(f"{name:6}{px:>4}{en1:>9}{en1*2:>9}{cjk1:>9}{cjk1*2:>9}")

print()
print("结论：多数正文用 sm(14px)。该档下")
print(f"  EN 单行 ≈ {int(BASELINE_WIDTH/(14*AVG_ASCII_EM))} 字符，双行 ≈ {int(BASELINE_WIDTH/(14*AVG_ASCII_EM))*2}")
print(f"  CJK 单行 ≈ {int(BASELINE_WIDTH/14)} 字，双行 ≈ {int(BASELINE_WIDTH/14)*2}")
print()
print("视觉宽度口径（CJK 计 2、ASCII 计 1）下：")
print(f"  EN 单行 45 字符 = 45 视觉宽")
print(f"  CJK 单行 22 字  = 44 视觉宽")
print("  → 两者视觉宽度近似相等，故同一套视觉宽上限可同时约束中英文。")

# 规范给的是推荐值，不是目标值。实作阈值在几何容量上再收 20%，理由见
# audit_copy.py 的 STRICT_FACTOR 注释：0.5em 是 ASCII 平均字宽而 W/M/@ 接近
# 0.7em；行内普遍带图标+间距（约 26dp）未计入几何容量；中英混排打破单一字宽假设。
STRICT_FACTOR = 0.8

print()
print(f"实作阈值 = 几何容量 × {STRICT_FACTOR}（规范是推荐值，实作要更严）：")
print(f"  {'行数':6}{'几何容量':>10}{'实作阈值':>10}")
for label, cap in (("单行", 45), ("双行", 90), ("三行", 135), ("四行", 180)):
    print(f"  {label:6}{cap:>10}{int(cap*STRICT_FACTOR):>10}")
print()
print("  按钮/操作 24→19   徽标 14→11   标签 30→24   状态/计数 20→16")
print()
print("超阈值即不合格，无\"略超可放行\"豁免；改写后仍超说明内容不该待在行内槽位。")
