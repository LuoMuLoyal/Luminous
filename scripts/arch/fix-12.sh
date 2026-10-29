#!/usr/bin/env bash
# 恢复被合并/脚本误删的 provider 定义：从 arch/data 取回 app/composition 与 core 相关目录，
# 然后重新做目录归并（重名时用不同文件名而不是删除）。
set -u
cd /d/25080/Documents/VSCodeProject/Lumos/Luminous || exit 1

echo "== 1) 从 arch/data 恢复 app/composition 与 core 支撑目录 =="
git checkout arch/data -- lib/app/composition
for d in lib/core/i18n lib/core/providers lib/core/utils lib/core/storage lib/core/network; do
  [ -d "$d" ] && git checkout arch/data -- "$d" 2>/dev/null && echo "restored $d"
done

echo
echo "== 2) 重新做 app/composition 扁平文件归并（重名则改名，不删除）=="
merge_into() { # $1=subdir, rest=basenames
  local g="$1"; shift
  mkdir -p "lib/app/composition/$g"
  for f in "$@"; do
    src="lib/app/composition/$f.dart"
    [ -f "$src" ] || continue
    dst="lib/app/composition/$g/$f.dart"
    if [ -f "$dst" ]; then
      if cmp -s "$src" "$dst"; then
        git rm -q "$src" && echo "rm(same) $src"
      else
        alt="lib/app/composition/$g/${f}_composition.dart"
        git mv "$src" "$alt" && echo "mv(rename) $src -> $alt"
      fi
    else
      git mv "$src" "$dst" && echo "mv $src -> $dst"
    fi
  done
}
merge_into medicine medicine_style medicine_workspace
merge_into review review_dashboard review_style
merge_into record record record_water_target
merge_into today today today_suggestion
merge_into mine mine
merge_into notification notification
merge_into health_context health_context
merge_into legal legal

echo
echo "== 3) 重新生成 =="
dart run build_runner build 2>&1 | tail -2

echo
echo "== 4) analyze 错误数 =="
flutter analyze 2>&1 | grep -cE '^\s*error' || true
