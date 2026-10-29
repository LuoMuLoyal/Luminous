#!/usr/bin/env bash
# 第三批：结构迁移 + import 重定向，把合并引入的违规清掉。
set -u
cd /d/25080/Documents/VSCodeProject/Lumos/Luminous || exit 1

echo "== A) 删除残留的 data/providers 目录 =="
for d in lib/features/*/data/providers; do
  [ -d "$d" ] || continue
  rm -rf "$d" && echo "rm -rf $d"
done

echo
echo "== B) settings/presentation/pages/data -> pages/storage（避开 /data/ 路径） =="
if [ -d lib/features/settings/presentation/pages/data ]; then
  git mv lib/features/settings/presentation/pages/data lib/features/settings/presentation/pages/storage 2>/dev/null \
    || { mkdir -p lib/features/settings/presentation/pages/storage
         for f in lib/features/settings/presentation/pages/data/*; do git mv "$f" lib/features/settings/presentation/pages/storage/; done
         rmdir lib/features/settings/presentation/pages/data; }
  echo "moved pages/data -> pages/storage"
fi

echo
echo "== C) domain 不纯的文件移到 presentation =="
mkdir -p lib/features/medicine/presentation/utils lib/features/review/presentation/utils \
         lib/features/record/presentation/quick_entry/flows
for pair in \
  "lib/features/medicine/domain/repositories/workspace_style.dart:lib/features/medicine/presentation/utils/workspace_style.dart" \
  "lib/features/review/domain/repositories/dashboard_style.dart:lib/features/review/presentation/utils/dashboard_style.dart" \
  "lib/features/record/domain/services/medication_quick_entry.dart:lib/features/record/presentation/quick_entry/flows/medication_quick_entry.dart" \
  "lib/features/record/domain/services/water_quick_entry.dart:lib/features/record/presentation/quick_entry/flows/water_quick_entry.dart" ; do
  src="${pair%%:*}"; dst="${pair##*:}"
  [ -f "$src" ] && git mv "$src" "$dst" && echo "mv $src -> $dst"
done

echo
echo "== D) record/application 的 UI 型 mappers 与用例移到 presentation =="
mkdir -p lib/features/record/presentation/mappers
for f in dashboard_assembler dashboard_static_data record_view_mappers; do
  src="lib/features/record/application/mappers/$f.dart"
  [ -f "$src" ] && git mv "$src" "lib/features/record/presentation/mappers/$f.dart" && echo "mv $f"
done
for f in change_record_date record_detail_actions; do
  src="lib/features/record/application/usecases/$f.dart"
  [ -f "$src" ] && git mv "$src" "lib/features/record/presentation/quick_entry/sheets/$f.dart" && echo "mv $f"
done

echo
echo "== E) import 重定向 =="
python - <<'PY'
import os, re

MAP = {
 # data 层的错误/日志/本地化出口
 'core/errors/lucent_failure.dart': 'shared/domain/failure.dart',
 'core/errors/client_error_code.dart': 'shared/domain/failure.dart',
 'core/errors/network_error_code.dart': 'shared/domain/failure.dart',
 'core/logger/log_level.dart': 'core/network/app_log.dart',
 'core/i18n/locale.dart': 'core/network/i18n/app_locale.dart',
 # 展示层：会话统一走 app 适配器
 'core/auth/session_provider.dart': 'app/auth_session_adapter.dart',
 # record 快捷入口偏好：datasource -> domain 值模型
 'features/record/data/datasources/quick_entry_preferences.dart':
   'features/record/domain/entities/quick_entry_preferences.dart',
 # 迁移后的新位置
 'features/medicine/domain/repositories/workspace_style.dart':
   'features/medicine/presentation/utils/workspace_style.dart',
 'features/review/domain/repositories/dashboard_style.dart':
   'features/review/presentation/utils/dashboard_style.dart',
 'features/record/domain/services/medication_quick_entry.dart':
   'features/record/presentation/quick_entry/flows/medication_quick_entry.dart',
 'features/record/domain/services/water_quick_entry.dart':
   'features/record/presentation/quick_entry/flows/water_quick_entry.dart',
 'features/record/application/mappers/dashboard_assembler.dart':
   'features/record/presentation/mappers/dashboard_assembler.dart',
 'features/record/application/mappers/dashboard_static_data.dart':
   'features/record/presentation/mappers/dashboard_static_data.dart',
 'features/record/application/mappers/record_view_mappers.dart':
   'features/record/presentation/mappers/record_view_mappers.dart',
 'features/record/application/usecases/change_record_date.dart':
   'features/record/presentation/quick_entry/sheets/change_record_date.dart',
 'features/record/application/usecases/record_detail_actions.dart':
   'features/record/presentation/quick_entry/sheets/record_detail_actions.dart',
 'features/settings/presentation/pages/data/':
   'features/settings/presentation/pages/storage/',
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
echo "== F) 清掉不再使用的重复文件 =="
[ -f lib/features/record/data/datasources/quick_entry_preferences.dart ] && \
  grep -rq 'data/datasources/quick_entry_preferences.dart' lib test integration_test 2>/dev/null || \
  { git rm -q lib/features/record/data/datasources/quick_entry_preferences.dart && echo "rm 旧 datasource"; }

echo
echo "== 门禁 =="
cd tool/luminous_lints && dart run bin/luminous_lints.dart --clean-layers --quiet 2>&1 | tail -11
