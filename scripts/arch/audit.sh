#!/usr/bin/env bash
# 架构审计：分层结构、规则清零、目录约束、依赖方向、结构性异味。
set -u
cd /d/25080/Documents/VSCodeProject/Lumos/Luminous || exit 1

echo "############ 1. 分层文件分布 ############"
printf '%-16s %6s %6s %6s %8s\n' feature domain app data presentation
for d in lib/features/*/; do
  f=$(basename "$d")
  cnt() {
    local n=0
    [ -d "$d$1" ] && n=$(find "$d$1" -name '*.dart' ! -name '*.g.dart' ! -name '*.freezed.dart' | wc -l)
    echo "$n"
  }
  printf '%-16s %6s %6s %6s %8s\n' "$f" "$(cnt domain)" "$(cnt application)" "$(cnt data)" "$(cnt presentation)"
done

echo
echo "############ 2. 门禁各规则 ############"
cd tool/luminous_lints
dart run bin/luminous_lints.dart --clean-layers 2>/dev/null | grep -E '^lib/.*\[[a-z_]+\]' > /tmp/audit.txt
cd ../..
for r in domain_purity application_layer data_layer presentation_layer \
         core_not_import_features cross_feature_import directory_file_cap forbidden_directory; do
  printf '%-28s %s\n' "$r" "$(grep -c "\[$r\]" /tmp/audit.txt || true)"
done

echo
echo "############ 3. 依赖方向抽查（domain 是否零框架依赖）############"
bad=0
for f in $(find lib/features -path '*/domain/*' -name '*.dart' ! -name '*.g.dart' ! -name '*.freezed.dart'); do
  if grep -qE "^import '(package:flutter|package:flutter_riverpod|package:dio|package:lucide|package:drift|package:luminous/core|package:luminous/app|package:luminous/features/[a-z_]+/(data|presentation))" "$f"; then
    echo "  VIOLATION $f"; bad=$((bad+1))
  fi
done
echo "  domain 违规文件数: $bad"

echo
echo "############ 4. 目录裸文件 > 8 ############"
find lib -type d | while read -r d; do
  n=$(find "$d" -maxdepth 1 -name '*.dart' ! -name '*.g.dart' ! -name '*.freezed.dart' | wc -l)
  [ "$n" -gt 8 ] && echo "  $n  $d"
done || true

echo
echo "############ 5. 结构异味扫描 ############"
echo "-- 空的 data/providers 目录:"
find lib/features -type d -name providers -path '*/data/*' 2>/dev/null | while read -r d; do
  [ -z "$(ls -A "$d")" ] && echo "  EMPTY $d"
done
echo "-- 自引用 import/export:"
python3 - <<'PY'
import os
n = 0
for dp, _, fs in os.walk('lib'):
    for f in fs:
        if not f.endswith('.dart'):
            continue
        p = os.path.join(dp, f)
        rel = p[len('lib/'):]
        uri = 'package:luminous/' + rel
        s = open(p, encoding='utf-8').read()
        if uri in s:
            print('  SELF', p); n += 1
print('  合计:', n)
PY
echo "-- part 指令不匹配:"
python3 - <<'PY'
import os, re
n = 0
for dp, _, fs in os.walk('lib'):
    for f in fs:
        if not f.endswith('.dart') or f.endswith('.g.dart') or f.endswith('.freezed.dart'):
            continue
        p = os.path.join(dp, f)
        s = open(p, encoding='utf-8').read()
        for m in re.finditer(r"^part '(.+?)';", s, re.M):
            expected = m.group(1)
            if not expected.endswith('.g.dart') and not expected.endswith('.freezed.dart'):
                continue
            if not os.path.exists(os.path.join(dp, expected)):
                print('  MISSING PART', p, '->', expected); n += 1
print('  合计:', n)
PY

echo
echo "############ 6. 分层规模 ############"
for layer in domain application data presentation; do
  n=$(find lib/features -path "*/$layer/*" -name '*.dart' ! -name '*.g.dart' ! -name '*.freezed.dart' | wc -l)
  printf '  %-14s %s\n' "$layer" "$n"
done
echo "  core:            $(find lib/core -name '*.dart' ! -name '*.g.dart' ! -name '*.freezed.dart' | wc -l)"
echo "  app(composition):$(find lib/app -name '*.dart' ! -name '*.g.dart' ! -name '*.freezed.dart' | wc -l)"
echo "  shared:          $(find lib/shared -name '*.dart' ! -name '*.g.dart' ! -name '*.freezed.dart' | wc -l)"
