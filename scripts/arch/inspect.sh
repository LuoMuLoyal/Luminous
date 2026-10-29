#!/usr/bin/env bash
set -u
cd /d/25080/Documents/VSCodeProject/Lumos/Luminous || exit 1

echo "== data/providers 目录内容 =="
for d in lib/features/*/data/providers; do
  n=$(git ls-files "$d" 2>/dev/null | wc -l)
  echo "$d : $n"
done

echo
echo "== 引用 data/providers 的文件数 =="
grep -rl 'data/providers/' lib test integration_test tool 2>/dev/null | wc -l

echo
echo "== app/composition 扁平文件 =="
ls lib/app/composition/*.dart 2>/dev/null | head -20

echo
echo "== record/presentation/quick_entry 文件 =="
ls lib/features/record/presentation/quick_entry/ | head -20

echo
echo "== core/utils 文件 =="
ls lib/core/utils/*.dart | head -15
