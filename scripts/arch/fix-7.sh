#!/usr/bin/env bash
set -u
cd /d/25080/Documents/VSCodeProject/Lumos/Luminous || exit 1

echo "== 修 data 层两条反向引用（应指向 data 内部）=="
python - <<'PY'
import os
FIX = {
 'lib/features/scan/data/datasources/paddle_ocr_provider.dart': [
   ('package:luminous/features/scan/presentation/providers/data_access.dart',
    'package:luminous/features/scan/data/datasources/ocr_model_manager.dart')],
 'lib/features/search/data/repositories/lucent.dart': [
   ('package:luminous/features/search/presentation/providers/data_access.dart',
    'package:luminous/features/search/data/datasources/medicine_search.dart')],
}
for p, pairs in FIX.items():
    if not os.path.exists(p):
        print('缺失', p); continue
    s = open(p, encoding='utf-8').read()
    for a, b in pairs:
        s = s.replace(a, b)
    open(p, 'w', encoding='utf-8', newline='').write(s)
    print('fixed', p)
PY

echo
echo "== 门禁 =="
cd tool/luminous_lints && dart run bin/luminous_lints.dart --clean-layers --quiet 2>&1 | tail -6
cd ../..
echo
echo "== flutter analyze（检查文件移动有没有断链）=="
flutter analyze 2>&1 | grep -E '^\s*error' | head -20
echo "error 数: $(flutter analyze 2>&1 | grep -cE '^\s*error')"
