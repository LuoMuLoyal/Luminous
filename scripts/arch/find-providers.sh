#!/usr/bin/env bash
set -u
cd /d/25080/Documents/VSCodeProject/Lumos/Luminous || exit 1

for p in talkerProvider healthContextSnapshotProvider quickEntryPreferencesProvider \
         localeControllerProvider todayRepositoryProvider mineRepositoryProvider \
         medicineSearchRepositoryProvider scanRepositoryProvider paddleOcrProvider ocrModelManagerProvider; do
  f=$(git grep -l "$p =" arch/data -- 'lib/**/*.dart' 2>/dev/null | head -1)
  printf '%-36s %s\n' "$p" "${f:-<未找到>}"
done
