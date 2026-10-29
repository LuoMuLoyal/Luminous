#!/usr/bin/env bash
set -u
cd /d/25080/Documents/VSCodeProject/Lumos/Luminous || exit 1

echo "== 1) appLog 不再抛异常：未安装 sink 时用本地 Talker 兜底 =="
python - <<'PY'
p = 'lib/core/network/app_log.dart'
s = open(p, encoding='utf-8').read()
old = s[s.find('/// The app-wide log sink.'):]
new = '''/// The app-wide log sink.
///
/// Falls back to a standalone Talker until `core/logger/log_level.dart` installs
/// the real one, so diagnostics from the data layer are never dropped (and unit
/// tests that never boot the logger keep working).
talker_pkg.Talker get appLog => _sink ?? (_fallback ??= talker_pkg.Talker());

talker_pkg.Talker? _fallback;
'''
s = s.replace(old, new)
open(p, 'w', encoding='utf-8', newline='').write(s)
print('patched app_log')
PY

echo
echo "== 2) 重新跑受影响测试 =="
flutter test test/assistant test/features/legal 2>&1 | tail -6
