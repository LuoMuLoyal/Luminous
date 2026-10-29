#!/usr/bin/env bash
set -u
cd /d/25080/Documents/VSCodeProject/Lumos/Luminous || exit 1
OUT=/tmp/lint; mkdir -p "$OUT"
cd tool/luminous_lints
dart run bin/luminous_lints.dart --clean-layers 2>/dev/null | grep -E '^lib/.*\[[a-z_]+\]' > "$OUT/all.txt"
cd ../..
for r in application_layer core_not_import_features cross_feature_import data_layer domain_purity forbidden_directory presentation_layer; do
  grep "\[$r\]" "$OUT/all.txt" > "$OUT/$r.txt" 2>/dev/null || true
done

echo "### forbidden_directory（目录是否真空）"
for d in lib/features/*/data/providers; do [ -d "$d" ] && echo "$d : $(ls -A "$d" | wc -l) 项"; done

echo
echo "### core_not_import_features"
cat "$OUT/core_not_import_features.txt"

echo
echo "### domain_purity"
awk -F'[][]' '{print $2" "$1}' "$OUT/domain_purity.txt" | sed 's/:[0-9]*:[0-9]*//' | head -20

echo
echo "### application_layer"
sed 's/:[0-9]*:[0-9]*//' "$OUT/application_layer.txt" | head -30

echo
echo "### data_layer 目标前缀统计"
sed 's/.*\] //' "$OUT/data_layer.txt" | sed 's|lib/||' | cut -d/ -f1-2 | sort | uniq -c | sort -rn | head -12

echo
echo "### presentation_layer 目标统计"
sed 's/.*\] //' "$OUT/presentation_layer.txt" | sed 's|lib/||' | cut -d/ -f1-3 | sort | uniq -c | sort -rn | head -12
