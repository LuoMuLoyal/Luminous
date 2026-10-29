#!/usr/bin/env bash
set -u
cd /d/25080/Documents/VSCodeProject/Lumos/Luminous || exit 1
for f in \
  lib/shared/domain/failure.dart \
  lib/core/network/app_log.dart \
  lib/core/network/i18n/app_locale.dart \
  lib/features/record/domain/entities/quick_entry_preferences.dart \
  lib/features/record/presentation/providers/data_access.dart \
  lib/features/scan/presentation/providers/data_access.dart \
  lib/core/providers/instrumentation/data_change_bus.dart \
  lib/features/record/presentation/mappers \
  lib/features/settings/presentation/pages/data ; do
  if [ -e "$f" ]; then echo "存在: $f"; else echo "缺失: $f"; fi
done
echo
echo "### data_change_bus 定义位置"
grep -rl 'dataChangeVersionProvider' lib/core | head -3
echo
echo "### quick_entry_preferences 相关"
ls lib/features/record/domain/entities/ | grep -i pref
ls lib/features/record/data/datasources/ | grep -i pref
