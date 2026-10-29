#!/usr/bin/env bash
set -u
WT=/d/25080/Documents/VSCodeProject/Lumos/Luminous
cd "$WT" || exit 1

echo "== 1) 修正 app/composition 扁平路径引用 =="
python - <<'PY'
import os
PAIRS = [
 ('app/composition/medicine_style.dart','app/composition/medicine/medicine_style.dart'),
 ('app/composition/medicine_workspace.dart','app/composition/medicine/medicine_workspace.dart'),
 ('app/composition/review_dashboard.dart','app/composition/review/review_dashboard.dart'),
 ('app/composition/review_style.dart','app/composition/review/review_style.dart'),
 ('app/composition/record.dart','app/composition/record/record.dart'),
 ('app/composition/record_water_target.dart','app/composition/record/record_water_target.dart'),
 ('app/composition/today.dart','app/composition/today/today.dart'),
 ('app/composition/today_suggestion.dart','app/composition/today/today_suggestion.dart'),
 ('app/composition/mine.dart','app/composition/mine/mine.dart'),
 ('app/composition/notification.dart','app/composition/notification/notification.dart'),
 ('app/composition/health_context.dart','app/composition/health_context/health_context.dart'),
 ('app/composition/legal.dart','app/composition/legal/legal.dart'),
]
changed = 0
for dp, _, fs in os.walk('.'):
    if any(x in dp for x in ('.git', '.dart_tool', 'build', 'node_modules')):
        continue
    for f in fs:
        if not f.endswith('.dart'):
            continue
        p = os.path.join(dp, f)
        try:
            s = open(p, encoding='utf-8').read()
        except Exception:
            continue
        o = s
        for a, b in PAIRS:
            if os.path.exists('lib/' + b):
                s = s.replace('package:luminous/' + a, 'package:luminous/' + b)
        if s != o:
            open(p, 'w', encoding='utf-8', newline='').write(s)
            changed += 1
print('修正文件数:', changed)
PY

echo
echo "== 2) 离线 sqlite3 钩子（临时，不进提交）=="
if ! grep -q '^hooks:' pubspec.yaml; then
  printf '\nhooks:\n  user_defines:\n    sqlite3:\n      source: system\n      name: winsqlite3\n' >> pubspec.yaml
  echo "appended"
fi
flutter pub get >/dev/null 2>&1 && echo "pub get ok"

echo
echo "== 3) 重新生成 =="
rm -f $(find lib test integration_test -name '*.g.dart' -o -name '*.freezed.dart' 2>/dev/null) 2>/dev/null
dart run build_runner build 2>&1 | tail -2

echo
echo "== 4) analyze =="
flutter analyze 2>&1 | grep -cE '^\s*error' || true
