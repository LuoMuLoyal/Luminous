#!/usr/bin/env bash
set -u
cd /d/25080/Documents/VSCodeProject/Lumos/Luminous || exit 1

echo "== 被我想当然 rm 掉的三个文件，从 data 分支取回内容 =="
for pair in \
  "lib/app/composition/health_context.dart:lib/app/composition/health_context/snapshot.dart" \
  "lib/app/composition/mine.dart:lib/app/composition/mine/mine_repository.dart" \
  "lib/app/composition/today_suggestion.dart:lib/app/composition/today/today_suggestion_repository.dart" ; do
  old="${pair%%:*}"; new="${pair##*:}"
  if git cat-file -e "arch/data:$old" 2>/dev/null; then
    mkdir -p "$(dirname "$new")"
    git show "arch/data:$old" > "$new"
    echo "restored $old -> $new"
  else
    echo "arch/data 中不存在: $old"
  fi
done

echo
echo "== 汇总所有 undefined provider =="
flutter analyze 2>&1 | grep -E "^\s*error - Undefined name '.*Provider'" | sed "s/.*Undefined name '//;s/'.*//" | sort | uniq -c | sort -rn | head -40
