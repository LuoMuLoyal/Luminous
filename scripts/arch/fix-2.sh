#!/usr/bin/env bash
set -u
cd /d/25080/Documents/VSCodeProject/Lumos/Luminous || exit 1

echo "== app/composition 扁平文件并入子目录 =="
move() { # $1=feature dir, rest=file basenames
  local g="$1"; shift
  mkdir -p "lib/app/composition/$g"
  for f in "$@"; do
    src="lib/app/composition/$f.dart"
    [ -f "$src" ] || continue
    dst="lib/app/composition/$g/$f.dart"
    if [ -f "$dst" ]; then
      git rm -q "$src" && echo "rm(dup) $src"
    else
      git mv "$src" "$dst" && echo "mv $src -> $dst"
    fi
  done
}
move medicine medicine_style medicine_workspace
move review review_dashboard review_style
move record record record_water_target
move today today today_suggestion
move mine mine
move notification notification
move health_context health_context
move legal legal

echo
echo "== 修 nlp_sheet 路径 =="
python - <<'PY'
import os
pat = 'package:luminous/features/record/presentation/quick_entry/nlp_sheet.dart'
new = 'package:luminous/features/record/presentation/quick_entry/sheets/nlp_sheet.dart'
if os.path.exists('lib/features/record/presentation/quick_entry/sheets/nlp_sheet.dart'):
    n = 0
    for dp, _, fs in os.walk('.'):
        if any(x in dp for x in ('.git', '.dart_tool', 'build')):
            continue
        for f in fs:
            if not f.endswith('.dart'):
                continue
            p = os.path.join(dp, f)
            s = open(p, encoding='utf-8').read()
            if pat in s:
                open(p, 'w', encoding='utf-8', newline='').write(s.replace(pat, new))
                n += 1
    print('修正', n, '处')
PY

echo
echo "== 门禁 =="
cd tool/luminous_lints && dart run bin/luminous_lints.dart --clean-layers --quiet 2>&1 | tail -11
