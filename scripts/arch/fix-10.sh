#!/usr/bin/env bash
set -u
cd /d/25080/Documents/VSCodeProject/Lumos/Luminous || exit 1

echo "== 删除自引用 import/export 行 =="
python - <<'PY'
import os

targets = []
for dp, _, fs in os.walk('lib'):
    for f in fs:
        if not f.endswith('.dart'):
            continue
        p = os.path.join(dp, f).replace('\\', '/')
        rel = p[len('lib/'):]
        self_uri = 'package:luminous/' + rel
        s = open(p, encoding='utf-8').read()
        if self_uri in s:
            targets.append((p, self_uri))

for p, uri in targets:
    lines = open(p, encoding='utf-8').read().split('\n')
    out, i = [], 0
    while i < len(lines):
        l = lines[i]
        if uri in l and (l.strip().startswith('export ') or l.strip().startswith('import ')):
            # 可能是多行 export：吞掉后续带引号/分号的行
            while i < len(lines) and ';' not in lines[i]:
                i += 1
            i += 1
            continue
        out.append(l)
        i += 1
    open(p, 'w', encoding='utf-8', newline='').write('\n'.join(out))
    print('cleaned', p)
PY

echo
echo "== analyze 错误数 =="
flutter analyze 2>&1 | grep -cE '^\s*error' || true
echo "--- 错误分类 ---"
flutter analyze 2>&1 | grep -E '^\s*error' | sed 's/.* - [A-Za-z]*_[a-z_]*$//' | awk -F' - ' '{print $NF}' | sed 's/:[0-9]*:[0-9]*$//' | sort | uniq -c | sort -rn | head -6
