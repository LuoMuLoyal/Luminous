#!/usr/bin/env bash
set -u
cd /d/25080/Documents/VSCodeProject/Lumos/Luminous || exit 1

echo "== 修 app/auth_session_adapter.dart 的自引用 export =="
python - <<'PY'
p = 'lib/app/auth_session_adapter.dart'
s = open(p, encoding='utf-8').read()
bad = "export 'package:luminous/app/auth_session_adapter.dart';"
if bad in s:
    s = s.replace(bad, "export 'package:luminous/core/auth/session_provider.dart';")
    open(p, 'w', encoding='utf-8', newline='').write(s)
    print('fixed self-export')
else:
    print('no self-export')
PY

echo
echo "== 扫描其它自引用 import/export =="
python - <<'PY'
import os, re
for dp, _, fs in os.walk('lib'):
    for f in fs:
        if not f.endswith('.dart'):
            continue
        p = os.path.join(dp, f).replace('\\', '/')
        rel = p[len('lib/'):]
        self_uri = 'package:luminous/' + rel
        s = open(p, encoding='utf-8').read()
        if self_uri in s:
            print('自引用:', p)
PY

echo
echo "== analyze 错误数 =="
flutter analyze 2>&1 | grep -cE '^\s*error' || true
