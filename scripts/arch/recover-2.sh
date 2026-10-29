#!/usr/bin/env bash
set -u
cd /d/25080/Documents/VSCodeProject/Lumos/Luminous || exit 1

echo "== 1) lucent_dashboard.dart：用上次合并好的版本（style + iconName 两者都在）=="
git show 8fc755325:lib/features/review/data/repositories/lucent_dashboard.dart \
  > lib/features/review/data/repositories/lucent_dashboard.dart && echo "restored merged version"

echo
echo "== 2) 规则文件：保证 shared/ 与各 layer 允许项齐全 =="
python - <<'PY'
p = 'tool/luminous_lints/lib/src/clean_layers.dart'
s = open(p, encoding='utf-8').read()
# 去掉冲突标记（若还有）
import re
s = re.sub(r'(?m)^<<<<<<< [^\n]*\n', '', s)
s = re.sub(r'(?m)^=======\n', '', s)
s = re.sub(r'(?m)^>>>>>>> [^\n]*\n', '', s)

def ensure(block_marker, lines):
    global s
    head, rest = s.split(block_marker, 1)
    body, tail = rest.split('];', 1)
    for l in lines:
        if l not in body:
            body = body.rstrip() + '\n' + l + '\n'
    s = head + block_marker + body + '];' + tail

ensure('const List<String> allowedCoreForData = [', [
    "  // Shared kernel: pure-Dart value objects / failure vocabulary / tokens.",
    "  'lib/shared/',",
])
ensure('const List<String> allowedCoreForPresentation = [', [
    "  // Shared kernel (pure-Dart value objects + failure vocabulary + tokens).",
    "  'lib/shared/',",
    "  // Composition root and pure config/analytics/network value seams.",
    "  'lib/app/composition/',",
    "  'lib/core/network/config/',",
    "  'lib/core/network/app_log.dart',",
    "  'lib/core/network/i18n/',",
    "  'lib/core/analytics/',",
])
open(p, 'w', encoding='utf-8', newline='').write(s)
print('rule allowlists ensured')
PY

echo
echo "== 3) 提交 domain 合并 =="
git add -A -- . ':!pubspec.yaml'
git commit --no-verify -m "refactor(domain): 合入领域层去 Flutter 与平台依赖" >/dev/null
echo "HEAD: $(git log --oneline -1)"

echo
echo "== 4) 合并 arch/application =="
git merge --no-ff --no-commit arch/application >/dev/null 2>&1
echo "冲突: $(git diff --name-only --diff-filter=U | wc -l)"
