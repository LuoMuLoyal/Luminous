#!/usr/bin/env bash
# 处理合并引入的违规：
#   1) 删空的 data/providers 目录
#   2) 规则放开展示层可依赖的 app/composition 与 core/network/config
#   3) core 里三个反向依赖 feature 的文件迁回所属 feature
#   4) 三个超限目录拆分
set -eu
cd /d/25080/Documents/VSCodeProject/Lumos/Luminous || exit 1

echo "== 1) 删除空的 data/providers 目录 =="
for d in lib/features/*/data/providers; do
  [ -d "$d" ] || continue
  if [ -z "$(ls -A "$d")" ]; then rmdir "$d" && echo "rmdir $d"; fi
done

echo
echo "== 2) 规则：展示层允许 app/composition 与 core/network/config =="
python - <<'PY'
p = 'tool/luminous_lints/lib/src/clean_layers.dart'
src = open(p, encoding='utf-8').read()
anchor = "  // App-level router seam shared by feature route tables.\n  'lib/app/router',"
add = anchor + """
  // Composition root: presentation reads its data through the app-level
  // assembly rather than reaching into any feature's data layer.
  'lib/app/composition/',
  // Pure config constants (pref keys / env keys): values only, no I/O.
  'lib/core/network/config/',"""
if "'lib/app/composition/'" not in src:
    src = src.replace(anchor, add, 1)
    open(p, 'w', encoding='utf-8', newline='').write(src)
    print('rule updated')
else:
    print('rule already updated')
PY

echo
echo "== 3) core 反向依赖 feature 的三个文件迁回 feature =="
mkdir -p lib/features/medicine/domain/services lib/features/medicine/presentation/utils \
         lib/features/record/presentation/utils
[ -f lib/core/storage/reminder_schedule.dart ] && git mv lib/core/storage/reminder_schedule.dart lib/features/medicine/domain/services/reminder_schedule.dart && echo "mv reminder_schedule"
[ -f lib/core/utils/reminder_format.dart ] && git mv lib/core/utils/reminder_format.dart lib/features/medicine/presentation/utils/reminder_format.dart && echo "mv reminder_format"
[ -f lib/core/utils/meal_analysis_view_data.dart ] && git mv lib/core/utils/meal_analysis_view_data.dart lib/features/record/presentation/utils/meal_analysis_view_data.dart && echo "mv meal_analysis_view_data"

echo
echo "== 4) 拆分超限目录 =="
# 4a) app/composition 扁平文件并入对应子目录
declare -A GROUPS=(
  [medicine]="medicine_style medicine_workspace"
  [review]="review_dashboard review_style"
  [record]="record record_water_target"
  [today]="today today_suggestion"
  [mine]="mine"
  [notification]="notification"
  [health_context]="health_context"
  [legal]="legal"
)
for g in "${!GROUPS[@]}"; do
  mkdir -p "lib/app/composition/$g"
  for f in ${GROUPS[$g]}; do
    src="lib/app/composition/$f.dart"
    [ -f "$src" ] || continue
    dst="lib/app/composition/$g/$f.dart"
    if [ -f "$dst" ]; then
      echo "同名已存在，删除扁平副本: $src"
      git rm -q "$src"
    else
      git mv "$src" "$dst" && echo "mv $src -> $dst"
    fi
  done
done

# 4b) record/presentation/quick_entry 拆 flows/ 与 sheets/
mkdir -p lib/features/record/presentation/quick_entry/flows lib/features/record/presentation/quick_entry/sheets
for f in meal_flow.dart medication.dart mood_flow.dart symptom_flow.dart meal.dart sleep.dart; do
  [ -f "lib/features/record/presentation/quick_entry/$f" ] && git mv "lib/features/record/presentation/quick_entry/$f" "lib/features/record/presentation/quick_entry/flows/$f" && echo "mv flows/$f"
done
for f in dispatcher.dart executor.dart execution_context.dart tap_decision.dart nlp_sheet.dart record_date.dart detail_actions.dart quick_entry_providers.dart; do
  [ -f "lib/features/record/presentation/quick_entry/$f" ] && git mv "lib/features/record/presentation/quick_entry/$f" "lib/features/record/presentation/quick_entry/sheets/$f" && echo "mv sheets/$f"
done

echo
echo "== 5) 全仓修正失效 import（按 basename 唯一匹配）=="
python - <<'PY'
import os, re
index = {}
for dp, _, fs in os.walk('lib'):
    for f in fs:
        if f.endswith('.dart'):
            index.setdefault(f, []).append(os.path.join(dp, f).replace('\\', '/'))
pat = re.compile(r"package:luminous/([A-Za-z0-9_/]+\.dart)")
map_providers = {
 'features/auth/data/providers/auth.dart': 'app/composition/auth/auth.dart',
 'features/auth/data/providers/sessions.dart': 'app/composition/auth/sessions.dart',
 'features/health_context/data/providers/health_context.dart': 'app/composition/health_context/health_context.dart',
 'features/health_data/data/providers/health_sync.dart': 'app/composition/health_data/health_sync.dart',
 'features/health_event/data/providers/health_event.dart': 'app/composition/health_event/health_event.dart',
 'features/medicine/data/providers/workspace.dart': 'app/composition/medicine/workspace.dart',
 'features/mine/data/providers/mine.dart': 'app/composition/mine/mine.dart',
 'features/notification/data/providers/unread_count.dart': 'app/composition/notification/unread_count.dart',
 'features/record/data/providers/record_access.dart': 'app/composition/record/record_access.dart',
 'features/record/data/providers/water_target.dart': 'app/composition/record/water_target.dart',
 'features/review/data/providers/review.dart': 'app/composition/review/review.dart',
 'features/settings/data/providers/cache_cleanup.dart': 'app/composition/settings/cache_cleanup.dart',
 'features/settings/data/providers/data_storage.dart': 'app/composition/settings/data_storage.dart',
 'features/settings/data/providers/notification_permission.dart': 'app/composition/settings/notification_permission.dart',
 'features/settings/data/providers/notification_preferences.dart': 'app/composition/settings/notification_preferences.dart',
 'features/settings/data/providers/profile.dart': 'app/composition/settings/profile.dart',
 'features/support/data/providers/resources.dart': 'app/composition/support/resources.dart',
 'features/today/data/providers/suggestion.dart': 'app/composition/today/suggestion.dart',
 'features/today/data/providers/today_suggestion.dart': 'app/composition/today/today_suggestion.dart',
 'core/storage/reminder_schedule.dart': 'features/medicine/domain/services/reminder_schedule.dart',
 'core/utils/reminder_format.dart': 'features/medicine/presentation/utils/reminder_format.dart',
 'core/utils/meal_analysis_view_data.dart': 'features/record/presentation/utils/meal_analysis_view_data.dart',
}
changed, unresolved = 0, set()
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
        def repl(m):
            rel = m.group(1)
            if rel in map_providers:
                return 'package:luminous/' + map_providers[rel]
            if os.path.exists(os.path.join('lib', rel)):
                return m.group(0)
            base = os.path.basename(rel)
            cands = index.get(base, [])
            if len(cands) == 1:
                return 'package:luminous/' + cands[0][len('lib/'):]
            if len(cands) > 1:
                unresolved.add(rel)
            return m.group(0)
        src = pat.sub(repl, src)
        if src != orig:
            open(p, 'w', encoding='utf-8', newline='').write(src)
            changed += 1
print('修正文件数:', changed)
if unresolved:
    print('多候选未解析:')
    for u in sorted(unresolved):
        print(' ', u)
PY
