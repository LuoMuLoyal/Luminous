import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/config/pref_keys.dart';
import 'package:luminous/core/providers/data_change_bus.dart';
import 'package:luminous/features/health_data/data/providers/health_sync.dart';
import 'package:luminous/features/health_data/domain/entities/health_metric.dart';
import 'package:luminous/features/health_data/domain/entities/health_permission.dart';
import 'package:luminous/features/health_data/domain/entities/health_sync_result.dart';
import 'package:luminous/features/health_data/presentation/providers/health_auto_sync.dart';
import 'package:luminous/features/health_data/presentation/providers/health_sync.dart';
import 'package:luminous/features/health_data/presentation/providers/health_sync_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/mocks/health_data.dart';

HealthMetric _metric() {
  return HealthMetric(
    type: HealthMetricType.heartRate,
    value: 72,
    unit: 'bpm',
    recordedAt: DateTime(2026, 7, 12, 8, 30),
  );
}

void main() {
  late FakeHealthSyncRepository repo;

  setUp(() {
    repo = FakeHealthSyncRepository();
  });

  ProviderContainer makeContainer() {
    final c = ProviderContainer(
      overrides: [healthSyncRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(c.dispose);
    return c;
  }

  group('HealthSyncController — state', () {
    test('build returns defaults', () {
      final c = makeContainer();
      final state = c.read(healthSyncControllerProvider);

      expect(state.selectedTypes, {
        HealthMetricType.heartRate,
        HealthMetricType.bloodPressure,
        HealthMetricType.bloodOxygen,
        HealthMetricType.weight,
        HealthMetricType.steps,
        HealthMetricType.sleep,
      });
      expect(state.timeRange, HealthSyncTimeRange.threeDays);
      expect(state.fetchedMetrics, isEmpty);
      expect(state.isLoading, isFalse);
    });

    test('toggleType adds and removes types', () {
      final c = makeContainer();
      final notifier = c.read(healthSyncControllerProvider.notifier);

      notifier.toggleType(HealthMetricType.water);
      expect(
        c.read(healthSyncControllerProvider).selectedTypes,
        contains(HealthMetricType.water),
      );

      notifier.toggleType(HealthMetricType.water);
      expect(
        c.read(healthSyncControllerProvider).selectedTypes,
        isNot(contains(HealthMetricType.water)),
      );
    });

    test('setTimeRange updates range', () {
      final c = makeContainer();
      final notifier = c.read(healthSyncControllerProvider.notifier);

      notifier.setTimeRange(HealthSyncTimeRange.sevenDays);
      expect(
        c.read(healthSyncControllerProvider).timeRange,
        HealthSyncTimeRange.sevenDays,
      );
    });

    test('reset clears fetched data and errors', () async {
      final c = makeContainer();
      final notifier = c.read(healthSyncControllerProvider.notifier);
      repo.fetchResult = [_metric()];
      await notifier.fetchData();
      expect(c.read(healthSyncControllerProvider).fetchedMetrics, hasLength(1));

      notifier.reset();
      final state = c.read(healthSyncControllerProvider);
      expect(state.fetchedMetrics, isEmpty);
      expect(state.syncResult, isNull);
      expect(state.error, isNull);
    });
  });

  group('HealthSyncController — requestPermissions', () {
    test('returns granted status and clears error', () async {
      final c = makeContainer();
      final notifier = c.read(healthSyncControllerProvider.notifier);

      final status = await notifier.requestPermissions();

      expect(status, HealthPermissionStatus.granted);
      expect(
        c.read(healthSyncControllerProvider).isRequestingPermissions,
        isFalse,
      );
    });

    test('returns denied status when repo denies', () async {
      repo.permissionStatus = HealthPermissionStatus.denied;
      final c = makeContainer();

      final status = await c
          .read(healthSyncControllerProvider.notifier)
          .requestPermissions();

      expect(status, HealthPermissionStatus.denied);
    });

    test('falls back to denied and records error on exception', () async {
      final throwing = _ThrowingPermissionsRepo();
      final c = ProviderContainer(
        overrides: [healthSyncRepositoryProvider.overrideWithValue(throwing)],
      );
      addTearDown(c.dispose);

      final status = await c
          .read(healthSyncControllerProvider.notifier)
          .requestPermissions();

      expect(status, HealthPermissionStatus.denied);
      expect(
        c.read(healthSyncControllerProvider).error,
        contains('permission denied'),
      );
      expect(
        c.read(healthSyncControllerProvider).isRequestingPermissions,
        isFalse,
      );
    });
  });

  group('HealthSyncController — fetchData', () {
    test('no-op when no types selected', () async {
      final c = makeContainer();
      final notifier = c.read(healthSyncControllerProvider.notifier);
      for (final type in c.read(healthSyncControllerProvider).selectedTypes) {
        notifier.toggleType(type);
      }

      await notifier.fetchData();

      expect(repo.lastFetchTypes, isNull);
      expect(c.read(healthSyncControllerProvider).isFetching, isFalse);
    });

    test('fetches metrics and stores them', () async {
      repo.fetchResult = [_metric()];
      final c = makeContainer();

      await c.read(healthSyncControllerProvider.notifier).fetchData();

      final state = c.read(healthSyncControllerProvider);
      expect(state.isFetching, isFalse);
      expect(state.fetchedMetrics, hasLength(1));
      expect(state.fetchedMetrics.single.value, 72);
      expect(repo.lastFetchTypes, state.selectedTypes);
      // threeDays range → start ≈ now - 3 days
      expect(
        DateTime.now().difference(repo.lastFetchStart!).inHours,
        closeTo(72, 2),
      );
      expect(repo.lastFetchEnd, isNotNull);
    });

    test('uses today range when selected', () async {
      final c = makeContainer();
      final notifier = c.read(healthSyncControllerProvider.notifier);
      notifier.setTimeRange(HealthSyncTimeRange.today);

      await notifier.fetchData();

      final now = DateTime.now();
      final expectedStart = DateTime(now.year, now.month, now.day);
      expect(repo.lastFetchStart, expectedStart);
    });

    test('records error on failure', () async {
      repo.fetchError = Exception('fetch failed');
      final c = makeContainer();

      await c.read(healthSyncControllerProvider.notifier).fetchData();

      final state = c.read(healthSyncControllerProvider);
      expect(state.isFetching, isFalse);
      expect(state.fetchedMetrics, isEmpty);
      expect(state.error, contains('fetch failed'));
    });
  });

  group('HealthSyncController — sync', () {
    test('no-op without fetched metrics', () async {
      final c = makeContainer();
      repo.syncResult = const HealthSyncResult(
        successCount: 3,
        skippedCount: 0,
        failedCount: 0,
      );

      await c.read(healthSyncControllerProvider.notifier).sync();

      expect(c.read(healthSyncControllerProvider).syncResult, isNull);
    });

    test('emits dailyRecords bus event on success', () async {
      repo.fetchResult = [_metric()];
      repo.syncResult = const HealthSyncResult(
        successCount: 1,
        skippedCount: 0,
        failedCount: 0,
      );
      final c = makeContainer();
      final notifier = c.read(healthSyncControllerProvider.notifier);
      await notifier.fetchData();

      final before = c.read(
        dataChangeVersionProvider(DataChangeTopic.dailyRecords),
      );
      await notifier.sync();

      final state = c.read(healthSyncControllerProvider);
      expect(state.syncResult?.successCount, 1);
      expect(state.isSyncing, isFalse);
      expect(
        c.read(dataChangeVersionProvider(DataChangeTopic.dailyRecords)),
        before + 1,
      );
    });

    test('does not emit bus event when nothing succeeded', () async {
      repo.fetchResult = [_metric()];
      repo.syncResult = const HealthSyncResult(
        successCount: 0,
        skippedCount: 1,
        failedCount: 0,
      );
      final c = makeContainer();
      final notifier = c.read(healthSyncControllerProvider.notifier);
      await notifier.fetchData();

      final before = c.read(
        dataChangeVersionProvider(DataChangeTopic.dailyRecords),
      );
      await notifier.sync();

      expect(c.read(healthSyncControllerProvider).syncResult?.skippedCount, 1);
      expect(
        c.read(dataChangeVersionProvider(DataChangeTopic.dailyRecords)),
        before,
      );
    });

    test('records error on failure', () async {
      repo.fetchResult = [_metric()];
      repo.syncError = Exception('sync failed');
      final c = makeContainer();
      final notifier = c.read(healthSyncControllerProvider.notifier);
      await notifier.fetchData();

      await notifier.sync();

      final state = c.read(healthSyncControllerProvider);
      expect(state.isSyncing, isFalse);
      expect(state.syncResult, isNull);
      expect(state.error, contains('sync failed'));
    });
  });

  group('HealthAutoSyncPreference', () {
    test('defaults to false and reads persisted value', () async {
      SharedPreferences.setMockInitialValues({
        PrefKeys.healthAutoSyncEnabled: true,
      });
      final c = ProviderContainer();
      addTearDown(c.dispose);

      // build() returns false synchronously; init completes on the next turn
      expect(c.read(healthAutoSyncPreferenceProvider), isFalse);
      await Future<void>.delayed(Duration.zero);
      expect(c.read(healthAutoSyncPreferenceProvider), isTrue);
    });

    test('toggle flips and persists', () async {
      SharedPreferences.setMockInitialValues({});
      final c = ProviderContainer();
      addTearDown(c.dispose);

      final notifier = c.read(healthAutoSyncPreferenceProvider.notifier);
      await notifier.toggle();

      expect(c.read(healthAutoSyncPreferenceProvider), isTrue);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(PrefKeys.healthAutoSyncEnabled), isTrue);

      await notifier.toggle();
      expect(c.read(healthAutoSyncPreferenceProvider), isFalse);
      expect(prefs.getBool(PrefKeys.healthAutoSyncEnabled), isFalse);
    });
  });
}

class _ThrowingPermissionsRepo extends FakeHealthSyncRepository {
  @override
  Future<HealthPermissionStatus> requestPermissions(
    Set<HealthMetricType> types,
  ) async {
    throw Exception('permission denied by platform');
  }
}
