#!/usr/bin/env bash
set -u
cd /d/25080/Documents/VSCodeProject/Lumos/Luminous || exit 1
cd tool/luminous_lints
dart run bin/luminous_lints.dart --clean-layers 2>/dev/null | grep -E '^lib/.*\[[a-z_]+\]' > /tmp/lint/all.txt
cd ../..
echo "--- data_layer ---"; grep '\[data_layer\]' /tmp/lint/all.txt | sed 's/:[0-9]*:[0-9]*//'
echo
echo "--- cross_feature 明细（前 25） ---"
grep '\[cross_feature_import\]' /tmp/lint/all.txt | sed 's/:[0-9]*:[0-9]*//' | head -25
