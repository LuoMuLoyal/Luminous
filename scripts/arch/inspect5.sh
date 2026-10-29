#!/usr/bin/env bash
set -u
cd /d/25080/Documents/VSCodeProject/Lumos/Luminous || exit 1
cd tool/luminous_lints
dart run bin/luminous_lints.dart --clean-layers 2>/dev/null | grep -E '^lib/.*\[[a-z_]+\]' > /tmp/lint/all.txt
cd ../..
echo "--- data_layer ---"; grep '\[data_layer\]' /tmp/lint/all.txt | sed 's/:[0-9]*:[0-9]*//'
echo "--- core ---"; grep '\[core_not_import_features\]' /tmp/lint/all.txt | sed 's/:[0-9]*:[0-9]*//'
echo "--- file_cap ---"; grep '\[directory_file_cap\]' /tmp/lint/all.txt
echo "--- presentation ---"; grep '\[presentation_layer\]' /tmp/lint/all.txt | sed 's/:[0-9]*:[0-9]*//'
echo "--- cross_feature 按 (源feature -> 目标feature) ---"
grep '\[cross_feature_import\]' /tmp/lint/all.txt | sed 's/:[0-9]*:[0-9]*//' | awk -F'[][]' '{print $1"|"$2}' | sed 's/\[cross_feature_import\] //' | \
  awk -F'|' '{src=$1; tgt=$2; n=split(src,a,"/"); s=a[3]; m=split(tgt,b,"/"); t=b[3]; print s" -> "t}' | sort | uniq -c | sort -rn | head -20
