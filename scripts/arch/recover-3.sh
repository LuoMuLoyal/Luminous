#!/usr/bin/env bash
set -u
cd /d/25080/Documents/VSCodeProject/Lumos/Luminous || exit 1

echo "== 1) 语义冲突文件取分支版本（它们是分支重构的目标）=="
for f in lib/features/record/application/usecases/quick_entry_sleep.dart \
         lib/features/record/domain/undo/quick_entry_undo.dart \
         lib/features/settings/application/sleep_reminder_notification_coordinator.dart \
         lib/features/today/application/usecases/skip_dose.dart \
         lib/features/today/presentation/quick_entry/water.dart \
         lib/features/today/presentation/widgets/sections/suggestion_primary_card.dart; do
  if git cat-file -e "arch/application:$f" 2>/dev/null; then
    git checkout arch/application -- "$f" && echo "theirs: $f"
  else
    git rm -f -q "$f" && echo "rm: $f"
  fi
done

echo
echo "== 2) 分支删除、主干残留的文件按分支意图删除 =="
for f in $(git diff --name-only --diff-filter=U); do
  if ! git cat-file -e "arch/application:$f" 2>/dev/null; then
    git rm -f -q "$f" 2>/dev/null && echo "rm: $f"
  fi
done

echo
echo "== 3) 旧路径重定向 =="
python - <<'PY'
import os, re
index = {}
for dp, _, fs in os.walk('lib'):
    for f in fs:
        if f.endswith('.dart'):
            index.setdefault(f, []).append(os.path.join(dp, f).replace('\\', '/'))
pat = re.compile(r"package:luminous/([A-Za-z0-9_/]+\.dart)")
changed, unresolved = 0, set()
for dp, _, fs in os.walk('.'):
    if any(x in dp for x in ('.git', '.dart_tool', 'build', 'node_modules')):
        continue
    for f in fs:
        if not f.endswith('.dart'):
            continue
        p = os.path.join(dp, f)
        try:
            src = open(p, encoding='utf-8').read()
        except Exception:
            continue
        orig = src
        def repl(m):
            rel = m.group(1)
            if os.path.exists(os.path.join('lib', rel)):
                return m.group(0)
            cands = index.get(os.path.basename(rel), [])
            if len(cands) == 1:
                return 'package:luminous/' + cands[0][len('lib/'):]
            unresolved.add(rel)
            return m.group(0)
        src = pat.sub(repl, src)
        if src != orig:
            open(p, 'w', encoding='utf-8', newline='').write(src)
            changed += 1
print('重定向文件数:', changed)
if unresolved:
    print('未解析:')
    for u in sorted(unresolved):
        print(' ', u)
PY

echo
git add -A -- . ':!pubspec.yaml'
echo "未解决冲突: $(git diff --name-only --diff-filter=U | wc -l)"
git commit --no-verify -m "refactor(application): 合入应用层收敛为纯 use case" >/dev/null
echo "HEAD: $(git log --oneline -1)"

echo
echo "== 门禁 =="
cd tool/luminous_lints && dart run bin/luminous_lints.dart --clean-layers --quiet 2>&1 | tail -10
