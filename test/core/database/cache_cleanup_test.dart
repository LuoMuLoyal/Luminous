import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/database/cache_cleanup.dart' as cache_cleanup;
import 'package:luminous/core/database/connection_providers.dart';
import 'package:luminous/core/database/daos/daily_record.dart';
import 'package:luminous/core/database/daos/medicine_dose_log.dart';
import 'package:luminous/features/settings/presentation/providers/data_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Fake DAOs ───────────────────────────────────────────────────

class _FakeDailyRecordDao implements DailyRecordDao {
  DateTime? lastCutoff;
  int cleanupResult = 0;
  Object? cleanupError;

  @override
  Future<int> cleanup(DateTime olderThan) async {
    lastCutoff = olderThan;
    if (cleanupError != null) throw cleanupError!;
    return cleanupResult;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeMedicineDoseLogDao implements MedicineDoseLogDao {
  DateTime? lastCutoff;
  int cleanupResult = 0;
  Object? cleanupError;

  @override
  Future<int> cleanup(DateTime olderThan) async {
    lastCutoff = olderThan;
    if (cleanupError != null) throw cleanupError!;
    return cleanupResult;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('cacheCleanup', () {
    late _FakeDailyRecordDao dailyRecordDao;
    late _FakeMedicineDoseLogDao doseLogDao;

    ProviderContainer makeContainer({String retentionStorageValue = '90'}) {
      SharedPreferences.setMockInitialValues({
        'settings.dataStorage.retentionPeriod': retentionStorageValue,
      });

      dailyRecordDao = _FakeDailyRecordDao();
      doseLogDao = _FakeMedicineDoseLogDao();

      return ProviderContainer(
        overrides: [
          dailyRecordDaoProvider.overrideWithValue(dailyRecordDao),
          medicineDoseLogDaoProvider.overrideWithValue(doseLogDao),
        ],
      );
    }

    test('does nothing when retention is forever', () async {
      final c = makeContainer(retentionStorageValue: 'forever');
      addTearDown(c.dispose);

      // Wait for settings to load
      await c.read(dataStorageSettingsControllerProvider.future);

      await c.read(cache_cleanup.cacheCleanupProvider.future);

      expect(dailyRecordDao.lastCutoff, isNull);
      expect(doseLogDao.lastCutoff, isNull);
    });

    test('calls cleanup on both DAOs when retention is 30 days', () async {
      final c = makeContainer(retentionStorageValue: '30');
      addTearDown(c.dispose);

      await c.read(dataStorageSettingsControllerProvider.future);
      await c.read(cache_cleanup.cacheCleanupProvider.future);

      expect(dailyRecordDao.lastCutoff, isNotNull);
      expect(doseLogDao.lastCutoff, isNotNull);

      final now = DateTime.now();
      final diff = now.difference(dailyRecordDao.lastCutoff!).inDays;
      expect(diff, closeTo(30, 1));
    });

    test('calls cleanup on both DAOs when retention is 90 days', () async {
      final c = makeContainer(retentionStorageValue: '90');
      addTearDown(c.dispose);

      await c.read(dataStorageSettingsControllerProvider.future);
      await c.read(cache_cleanup.cacheCleanupProvider.future);

      expect(dailyRecordDao.lastCutoff, isNotNull);
      expect(doseLogDao.lastCutoff, isNotNull);

      final now = DateTime.now();
      final diff = now.difference(dailyRecordDao.lastCutoff!).inDays;
      expect(diff, closeTo(90, 1));
    });

    test('both DAOs receive approximately the same cutoff date', () async {
      final c = makeContainer(retentionStorageValue: '30');
      addTearDown(c.dispose);

      await c.read(dataStorageSettingsControllerProvider.future);
      await c.read(cache_cleanup.cacheCleanupProvider.future);

      expect(
        dailyRecordDao.lastCutoff!.millisecondsSinceEpoch,
        closeTo(doseLogDao.lastCutoff!.millisecondsSinceEpoch, 1000),
      );
    });

    test('completes without error when DAOs return zero deletions', () async {
      final c = makeContainer(retentionStorageValue: '30');
      addTearDown(c.dispose);

      dailyRecordDao.cleanupResult = 0;
      doseLogDao.cleanupResult = 0;

      await c.read(dataStorageSettingsControllerProvider.future);
      await c.read(cache_cleanup.cacheCleanupProvider.future);
    });

    test(
      'completes without error when DAOs return non-zero deletions',
      () async {
        final c = makeContainer(retentionStorageValue: '30');
        addTearDown(c.dispose);

        dailyRecordDao.cleanupResult = 5;
        doseLogDao.cleanupResult = 3;

        await c.read(dataStorageSettingsControllerProvider.future);
        await c.read(cache_cleanup.cacheCleanupProvider.future);
      },
    );

    test('swallows errors from dailyRecordDao cleanup', () async {
      final c = makeContainer(retentionStorageValue: '30');
      addTearDown(c.dispose);

      dailyRecordDao.cleanupError = Exception('DB locked');

      await c.read(dataStorageSettingsControllerProvider.future);
      // Should not throw — cacheCleanup catches and logs
      await c.read(cache_cleanup.cacheCleanupProvider.future);
    });

    test('swallows errors from medicineDoseLogDao cleanup', () async {
      final c = makeContainer(retentionStorageValue: '30');
      addTearDown(c.dispose);

      doseLogDao.cleanupError = Exception('DB locked');

      await c.read(dataStorageSettingsControllerProvider.future);
      // Should not throw — cacheCleanup catches and logs
      await c.read(cache_cleanup.cacheCleanupProvider.future);
    });

    test('defaults to ninetyDays when retention is unknown value', () async {
      final c = makeContainer(retentionStorageValue: 'unknown');
      addTearDown(c.dispose);

      await c.read(dataStorageSettingsControllerProvider.future);
      await c.read(cache_cleanup.cacheCleanupProvider.future);

      // Default is ninetyDays (days = 90), so cleanup should be called
      expect(dailyRecordDao.lastCutoff, isNotNull);
      final now = DateTime.now();
      final diff = now.difference(dailyRecordDao.lastCutoff!).inDays;
      expect(diff, closeTo(90, 1));
    });
  });
}
