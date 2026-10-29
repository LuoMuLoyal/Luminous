#!/usr/bin/env bash
set -u
cd /d/25080/Documents/VSCodeProject/Lumos/Luminous || exit 1

echo "### domain_purity 明细"
for f in lib/features/medicine/domain/repositories/workspace_style.dart \
         lib/features/record/domain/services/medication_quick_entry.dart \
         lib/features/record/domain/services/water_quick_entry.dart \
         lib/features/review/domain/repositories/dashboard_style.dart; do
  echo "--- $f"
  grep -n '^import' "$f" | grep -v "dart:\|fpdart\|freezed\|package:meta\|package:clock"
done

echo
echo "### data_layer 明细（全部）"
sed 's/:0:0//' /tmp/lint/data_layer.txt | head -40

echo
echo "### presentation_layer 明细（全部）"
cat /tmp/lint/presentation_layer.txt

echo
echo "### data/providers 目录里剩什么"
for d in lib/features/*/data/providers; do [ -d "$d" ] && echo "$d: $(ls -A "$d" | tr '\n' ' ')"; done
