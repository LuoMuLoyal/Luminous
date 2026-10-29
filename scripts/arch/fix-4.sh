#!/usr/bin/env bash
set -u
cd /d/25080/Documents/VSCodeProject/Lumos/Luminous || exit 1

echo "== 规则补充：presentation 允许 shared/domain 与核心日志/本地化出口 =="
python - <<'PY'
p = 'tool/luminous_lints/lib/src/clean_layers.dart'
s = open(p, encoding='utf-8').read()
anchor = "  // Pure config constants (pref keys / env keys): values only, no I/O.\n  'lib/core/network/config/',"
add = anchor + """
  // Shared kernel (pure-Dart value objects + failure vocabulary).
  'lib/shared/domain/',
  // Logging + locale value exports (no I/O, used by every layer).
  'lib/core/network/app_log.dart',
  'lib/core/network/i18n/',"""
if "'lib/shared/domain/'" not in s:
    s = s.replace(anchor, add, 1)
    open(p, 'w', encoding='utf-8', newline='').write(s)
    print('updated')
else:
    print('already')
PY

echo
echo "== 重新统计 =="
cd tool/luminous_lints
dart run bin/luminous_lints.dart --clean-layers 2>/dev/null | grep -E '^lib/.*\[[a-z_]+\]' > /tmp/lint/all.txt
cd ../..
for r in application_layer core_not_import_features cross_feature_import data_layer directory_file_cap domain_purity forbidden_directory presentation_layer; do
  n=$(grep -c "\[$r\]" /tmp/lint/all.txt || true)
  printf '%-28s %s\n' "$r" "$n"
done

echo
echo "--- data_layer ---"; grep '\[data_layer\]' /tmp/lint/all.txt | sed 's/:[0-9]*:[0-9]*//'
echo "--- domain_purity ---"; grep '\[domain_purity\]' /tmp/lint/all.txt | sed 's/:[0-9]*:[0-9]*//'
echo "--- core ---"; grep '\[core_not_import_features\]' /tmp/lint/all.txt | sed 's/:[0-9]*:[0-9]*//'
echo "--- file_cap ---"; grep '\[directory_file_cap\]' /tmp/lint/all.txt
echo "--- presentation 目标统计 ---"; grep '\[presentation_layer\]' /tmp/lint/all.txt | sed 's/.*\] //' | sed 's|lib/||' | cut -d/ -f1-3 | sort | uniq -c | sort -rn | head -10
