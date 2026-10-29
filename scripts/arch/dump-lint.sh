#!/usr/bin/env bash
# 把门禁违规按规则导出到文件，便于逐类处理。
set -u
REPO=${1:-/d/25080/Documents/VSCodeProject/Lumos/Luminous}
cd "$REPO/tool/luminous_lints" || exit 1
OUT=/tmp/lint
mkdir -p "$OUT"
dart run bin/luminous_lints.dart --clean-layers 2>/dev/null \
  | grep -E '^lib/.*\[[a-z_]+\]' > "$OUT/all.txt"

for rule in application_layer core_not_import_features cross_feature_import data_layer \
            directory_file_cap domain_purity forbidden_directory presentation_layer; do
  grep "\[$rule\]" "$OUT/all.txt" > "$OUT/$rule.txt" || true
  printf '%-28s %s\n' "$rule" "$(wc -l < "$OUT/$rule.txt")"
done
