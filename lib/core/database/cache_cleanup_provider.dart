import 'package:luminous/core/database/database_providers.dart';
import 'package:luminous/core/logger/app_logger.dart';
import 'package:luminous/features/settings/presentation/providers/data_storage_settings_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cache_cleanup_provider.g.dart';

/// Performs cache cleanup based on the user's data retention preference.
///
/// This provider is triggered at app startup (or when the retention setting
/// changes) and removes old synced cache entries that exceed the retention
/// period. Pending (unsynced) entries are always preserved.
///
/// - 30 days: entries older than 30 days are purged.
/// - 90 days: entries older than 90 days are purged.
/// - forever: no cleanup is performed.
@Riverpod(keepAlive: true)
Future<void> cacheCleanup(Ref ref) async {
  final settings = ref.watch(dataStorageSettingsControllerProvider);
  final period =
      settings.asData?.value.retentionPeriod ?? DataRetentionPeriod.ninetyDays;

  if (period.days < 0) {
    // Forever — no cleanup
    return;
  }

  final cutoff = DateTime.now().subtract(Duration(days: period.days));

  final dailyRecordDao = ref.read(dailyRecordDaoProvider);
  final doseLogDao = ref.read(medicineDoseLogDaoProvider);

  try {
    final deletedRecords = await dailyRecordDao.cleanup(cutoff);
    final deletedLogs = await doseLogDao.cleanup(cutoff);

    if (deletedRecords > 0 || deletedLogs > 0) {
      appTalker.info(
        'Cache cleanup: removed $deletedRecords daily records, '
        '$deletedLogs dose logs older than ${period.days} days',
      );
    }
  } catch (e) {
    appTalker.warning('Cache cleanup failed: $e');
  }
}
