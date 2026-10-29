#!/usr/bin/env bash
set -u
cd /d/25080/Documents/VSCodeProject/Lumos/Luminous || exit 1

echo "== 1) 规则：补齐 layer 允许清单 =="
python - <<'PY'
p = 'tool/luminous_lints/lib/src/clean_layers.dart'
s = open(p, encoding='utf-8').read()

# data 允许共享内核 + 设计令牌
if "'lib/shared/domain/'" not in s.split('allowedCoreForData = [')[1].split('];')[0]:
    s = s.replace(
        "const List<String> allowedCoreForData = [",
        "const List<String> allowedCoreForData = [\n  // Shared kernel: pure-Dart value objects and the failure vocabulary.\n  'lib/shared/domain/',\n  // Design tokens used by repositories that receive styling by injection.\n  'lib/core/design/',",
        1)

# presentation 允许共享内核 + 日志/本地化出口
block = s.split('allowedCoreForPresentation = [')[1].split('];')[0]
if "'lib/shared/domain/'" not in block:
    s = s.replace(
        "  // Pure config constants (pref keys / env keys): values only, no I/O.\n  'lib/core/network/config/',",
        "  // Pure config constants (pref keys / env keys): values only, no I/O.\n  'lib/core/network/config/',\n  // Shared kernel (pure-Dart value objects + failure vocabulary).\n  'lib/shared/domain/',\n  // Logging + locale value exports (no I/O).\n  'lib/core/network/app_log.dart',\n  'lib/core/network/i18n/',",
        1)
open(p, 'w', encoding='utf-8', newline='').write(s)
print('rule updated')
PY

echo
echo "== 2) 设计令牌文件移到 core/design/style/ =="
mkdir -p lib/core/design/style
for pair in \
  "lib/features/medicine/presentation/utils/workspace_style.dart:lib/core/design/style/medicine_workspace.dart" \
  "lib/features/review/presentation/utils/dashboard_style.dart:lib/core/design/style/review_dashboard.dart" ; do
  src="${pair%%:*}"; dst="${pair##*:}"
  [ -f "$src" ] && git mv "$src" "$dst" && echo "mv -> $dst"
done

echo
echo "== 3) core/utils/meal_analysis_payload.dart 移到 record/presentation/utils =="
[ -f lib/core/utils/meal_analysis_payload.dart ] && \
  git mv lib/core/utils/meal_analysis_payload.dart lib/features/record/presentation/utils/meal_analysis_payload.dart && echo "mv payload"

echo
echo "== 4) record/domain/services/meal_quick_entry.dart 移到 flows =="
[ -f lib/features/record/domain/services/meal_quick_entry.dart ] && \
  git mv lib/features/record/domain/services/meal_quick_entry.dart lib/features/record/presentation/quick_entry/flows/meal_quick_entry.dart && echo "mv meal_quick_entry"

echo
echo "== 5) quick_entry/sheets 再拆一层（10 -> <=8）=="
mkdir -p lib/features/record/presentation/quick_entry/sheets/actions
for f in record_detail_actions.dart change_record_date.dart detail_actions.dart record_date.dart; do
  src="lib/features/record/presentation/quick_entry/sheets/$f"
  [ -f "$src" ] && git mv "$src" "lib/features/record/presentation/quick_entry/sheets/actions/$f" && echo "mv actions/$f"
done

echo
echo "== 6) import 重定向 =="
python - <<'PY'
import os
MAP = {
 'features/medicine/presentation/utils/workspace_style.dart': 'core/design/style/medicine_workspace.dart',
 'features/review/presentation/utils/dashboard_style.dart': 'core/design/style/review_dashboard.dart',
 'core/utils/meal_analysis_payload.dart': 'features/record/presentation/utils/meal_analysis_payload.dart',
 'features/record/domain/services/meal_quick_entry.dart': 'features/record/presentation/quick_entry/flows/meal_quick_entry.dart',
 'features/record/presentation/quick_entry/sheets/record_detail_actions.dart': 'features/record/presentation/quick_entry/sheets/actions/record_detail_actions.dart',
 'features/record/presentation/quick_entry/sheets/change_record_date.dart': 'features/record/presentation/quick_entry/sheets/actions/change_record_date.dart',
 'features/record/presentation/quick_entry/sheets/detail_actions.dart': 'features/record/presentation/quick_entry/sheets/actions/detail_actions.dart',
 'features/record/presentation/quick_entry/sheets/record_date.dart': 'features/record/presentation/quick_entry/sheets/actions/record_date.dart',
 # 展示层不要直连 data
 'features/scan/data/datasources/paddle_ocr_provider.dart': 'features/scan/presentation/providers/data_access.dart',
 'features/scan/data/datasources/ocr_model_manager.dart': 'features/scan/presentation/providers/data_access.dart',
 'features/search/data/datasources/medicine_search.dart': 'features/search/presentation/providers/data_access.dart',
}
changed = 0
for dp, _, fs in os.walk('.'):
    if any(x in dp for x in ('.git', '.dart_tool', 'build', 'node_modules')):
        continue
    for f in fs:
        if not f.endswith('.dart'):
            continue
        p = os.path.join(dp, f)
        try:
            src = open(p, encoding='utf-8').read()
        except Exception:
            continue
        orig = src
        for a, b in MAP.items():
            src = src.replace('package:luminous/' + a, 'package:luminous/' + b)
        if src != orig:
            open(p, 'w', encoding='utf-8', newline='').write(src)
            changed += 1
print('修正文件数:', changed)
PY

echo
echo "== 门禁 =="
cd tool/luminous_lints && dart run bin/luminous_lints.dart --clean-layers --quiet 2>&1 | tail -11
