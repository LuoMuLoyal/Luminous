import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lucent_api/lucent_api.dart'
    show MedicineDoseLogsApi, MedicineRemindersApi;
import 'package:luminous/core/database/connection_providers.dart';
import 'package:luminous/core/database/database.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/features/health_context/data/providers/health_context.dart';
import 'package:luminous/features/health_context/domain/entities/snapshot.dart';
import 'package:luminous/features/medicine/data/datasources/dose_log_cached.dart';
import 'package:luminous/features/medicine/data/datasources/dose_log_remote.dart';
import 'package:luminous/features/medicine/data/datasources/reminder_remote.dart';
import 'package:luminous/features/medicine/data/providers/workspace.dart';
import 'package:luminous/features/notification/data/repositories/lucent.dart';
import 'package:luminous/features/notification/domain/entities/notification.dart';
import 'package:luminous/features/notification/domain/repositories/notification.dart';
import 'package:luminous/features/record/data/providers/record_access.dart';
import 'package:luminous/features/record/domain/entities/candidates.dart';
import 'package:luminous/features/record/domain/entities/inputs.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/features/record/domain/repositories/daily.dart';
import 'package:luminous/features/settings/data/repositories/lucent.dart';
import 'package:luminous/features/settings/domain/entities/user_settings.dart';
import 'package:luminous/features/settings/domain/repositories/user_settings.dart';
import 'package:luminous/features/today/data/providers/today_suggestion.dart';
import 'package:luminous/features/today/domain/entities/dashboard.dart';

import '../helpers/task_either.dart';

void main() {
  test(
    'Lucent today repository uses earliest pending medicine reminder',
    () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      final container = ProviderContainer(
        overrides: [
          healthContextSnapshotProvider.overrideWith((ref) async => _snapshot),
          dailyRecordRepositoryProvider.overrideWithValue(
            _FakeDailyRecordRepository(
              waterRecords: [
                _waterRecord(id: 'water-zero', value: '0'),
                _waterRecord(id: 'water-500', value: '500'),
                _waterRecord(id: 'water-cup', value: '1', unit: 'cup'),
              ],
            ),
          ),
          appDatabaseProvider.overrideWithValue(db),
          cachedDoseLogDataSourceProvider.overrideWith((ref) {
            return CachedDoseLogDataSource(
              remote: _FakeDoseLogDataSource([
                const DoseLogItem(
                  id: 'dose-1',
                  currentMedicineId: 'med-1',
                  status: DoseLogStatus.taken,
                  scheduledFor: '2026-06-08',
                  createdAt: '2026-06-08T07:00:00.000Z',
                  updatedAt: '2026-06-08T07:00:00.000Z',
                ),
              ]),
              dao: db.medicineDoseLogDao,
            );
          }),
          medicineReminderRemoteDataSourceProvider.overrideWithValue(
            _FakeReminderDataSource([
              _reminder(
                id: 'reminder-1',
                currentMedicineId: 'med-1',
                scheduledHour: 7,
                scheduledMinute: 0,
              ),
              _reminder(
                id: 'reminder-2',
                currentMedicineId: 'med-2',
                scheduledHour: 12,
                scheduledMinute: 30,
              ),
            ]),
          ),
          userSettingsRepositoryProvider.overrideWithValue(
            _FakeUserSettingsRepository(),
          ),
          notificationRepositoryProvider.overrideWithValue(
            _FakeNotificationRepository(count: 3),
          ),
        ],
      );
      addTearDown(container.dispose);

      final dashboard = await expectTaskRight(
        container.read(todayRepositoryProvider).fetchDashboard(),
      );

      expect(dashboard.medication.medicineCount, 2);
      expect(dashboard.medication.pendingCount, 1);
      expect(dashboard.medication.nextDoseTimeLabel, '12:30');
      expect(dashboard.medication.nextMedicineName, 'Example medicine B');
      expect(dashboard.water.observedMetric?.value, 500);
      expect(
        dashboard.water.observedMetric?.coverage,
        TodayObservedMetricCoverage.partial,
      );
      expect(dashboard.water.observedMetric?.observedCount, 2);
      expect(dashboard.user.hasUnreadNotifications, isTrue);
    },
  );

  test(
    'Lucent today repository falls back when reminders are unavailable',
    () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      final container = ProviderContainer(
        overrides: [
          healthContextSnapshotProvider.overrideWith((ref) async => _snapshot),
          dailyRecordRepositoryProvider.overrideWithValue(
            _FakeDailyRecordRepository(),
          ),
          appDatabaseProvider.overrideWithValue(db),
          cachedDoseLogDataSourceProvider.overrideWith((ref) {
            return CachedDoseLogDataSource(
              remote: _FakeDoseLogDataSource(),
              dao: db.medicineDoseLogDao,
            );
          }),
          medicineReminderRemoteDataSourceProvider.overrideWithValue(
            _ThrowingReminderDataSource(),
          ),
          userSettingsRepositoryProvider.overrideWithValue(
            _FakeUserSettingsRepository(),
          ),
          notificationRepositoryProvider.overrideWithValue(
            _FakeNotificationRepository(count: 0),
          ),
        ],
      );
      addTearDown(container.dispose);

      final dashboard = await expectTaskRight(
        container.read(todayRepositoryProvider).fetchDashboard(),
      );

      expect(dashboard.medication.pendingCount, 2);
      expect(dashboard.medication.nextDoseTimeLabel, '--');
      expect(dashboard.medication.nextMedicineName, 'Example medicine A');
      expect(dashboard.water.observedMetric?.value, isNull);
      expect(
        dashboard.water.observedMetric?.state,
        TodayObservedMetricState.unknown,
      );
      expect(dashboard.user.hasUnreadNotifications, isFalse);
    },
  );

  test(
    'returns degraded dashboard when health context snapshot fails',
    () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      final container = ProviderContainer(
        overrides: [
          healthContextSnapshotProvider.overrideWith(
            (ref) async => throw StateError('snapshot unavailable'),
          ),
          dailyRecordRepositoryProvider.overrideWithValue(
            _FakeDailyRecordRepository(),
          ),
          appDatabaseProvider.overrideWithValue(db),
          cachedDoseLogDataSourceProvider.overrideWith((ref) {
            return CachedDoseLogDataSource(
              remote: _FakeDoseLogDataSource(),
              dao: db.medicineDoseLogDao,
            );
          }),
          medicineReminderRemoteDataSourceProvider.overrideWithValue(
            _FakeReminderDataSource(),
          ),
          userSettingsRepositoryProvider.overrideWithValue(
            _FakeUserSettingsRepository(),
          ),
          notificationRepositoryProvider.overrideWithValue(
            _FakeNotificationRepository(count: 0),
          ),
        ],
      );
      addTearDown(container.dispose);

      final dashboard = await expectTaskRight(
        container.read(todayRepositoryProvider).fetchDashboard(),
      );

      expect(
        dashboard.water.observedMetric?.state,
        TodayObservedMetricState.degraded,
      );
      expect(
        dashboard.medication.observedMetric?.state,
        TodayObservedMetricState.degraded,
      );
      final sleepVital = dashboard.vitals.firstWhere(
        (v) => v.type == TodayVitalType.sleep,
      );
      expect(
        sleepVital.observedMetric?.state,
        TodayObservedMetricState.degraded,
      );
      expect(dashboard.user.hasUnreadNotifications, isFalse);
    },
  );

  test(
    'marks water metric degraded when dailyRecordRepository.fetchRecords fails',
    () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      final container = ProviderContainer(
        overrides: [
          healthContextSnapshotProvider.overrideWith((ref) async => _snapshot),
          dailyRecordRepositoryProvider.overrideWithValue(
            _ThrowingWaterDailyRecordRepository(),
          ),
          appDatabaseProvider.overrideWithValue(db),
          cachedDoseLogDataSourceProvider.overrideWith((ref) {
            return CachedDoseLogDataSource(
              remote: _FakeDoseLogDataSource(),
              dao: db.medicineDoseLogDao,
            );
          }),
          medicineReminderRemoteDataSourceProvider.overrideWithValue(
            _FakeReminderDataSource(),
          ),
          userSettingsRepositoryProvider.overrideWithValue(
            _FakeUserSettingsRepository(),
          ),
          notificationRepositoryProvider.overrideWithValue(
            _FakeNotificationRepository(count: 0),
          ),
        ],
      );
      addTearDown(container.dispose);

      final dashboard = await expectTaskRight(
        container.read(todayRepositoryProvider).fetchDashboard(),
      );

      expect(
        dashboard.water.observedMetric?.state,
        TodayObservedMetricState.degraded,
      );
      expect(dashboard.medication.observedMetric, isNull);
      expect(dashboard.user.hasUnreadNotifications, isFalse);
    },
  );

  test(
    'marks medication metric degraded when doseLogRepository.fetchForDate fails',
    () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      final container = ProviderContainer(
        overrides: [
          healthContextSnapshotProvider.overrideWith((ref) async => _snapshot),
          dailyRecordRepositoryProvider.overrideWithValue(
            _FakeDailyRecordRepository(),
          ),
          appDatabaseProvider.overrideWithValue(db),
          cachedDoseLogDataSourceProvider.overrideWith((ref) {
            return CachedDoseLogDataSource(
              remote: _ThrowingDoseLogDataSource(),
              dao: db.medicineDoseLogDao,
            );
          }),
          medicineReminderRemoteDataSourceProvider.overrideWithValue(
            _FakeReminderDataSource(),
          ),
          userSettingsRepositoryProvider.overrideWithValue(
            _FakeUserSettingsRepository(),
          ),
          notificationRepositoryProvider.overrideWithValue(
            _FakeNotificationRepository(count: 0),
          ),
        ],
      );
      addTearDown(container.dispose);

      final dashboard = await expectTaskRight(
        container.read(todayRepositoryProvider).fetchDashboard(),
      );

      expect(
        dashboard.medication.observedMetric?.state,
        TodayObservedMetricState.degraded,
      );
      expect(
        dashboard.water.observedMetric?.state,
        isNot(TodayObservedMetricState.degraded),
      );
      expect(dashboard.user.hasUnreadNotifications, isFalse);
    },
  );
}

class _FakeDailyRecordRepository implements DailyRecordRepository {
  _FakeDailyRecordRepository({this.waterRecords = const []});

  final List<DailyRecordItem> waterRecords;

  @override
  Future<DailyRecordListData> fetchRecords(
    String date, {
    String? kind,
    int page = 1,
    int pageSize = 50,
  }) async => DailyRecordListData(
    items: kind == DailyRecordKind.water.name ? waterRecords : const [],
    total: kind == DailyRecordKind.water.name ? waterRecords.length : 0,
  );

  @override
  Future<DailyRecordSummaryData> fetchSummary(String date) async {
    return const DailyRecordSummaryData(
      summaries: [DailyRecordSummary(kind: DailyRecordKind.water, count: 3)],
    );
  }

  @override
  Future<DailyRecordItem> get(String id) async {
    throw UnimplementedError();
  }

  @override
  Future<DailyRecordAttachmentInput> uploadImage(
    DailyRecordImageUploadInput input,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<DailyRecordCandidateResult> generateCandidates({
    required String text,
    required String occurredAt,
  }) async {
    return const DailyRecordCandidateResult(
      locale: 'zh-CN',
      generatedAt: '2026-06-14T00:00:00.000Z',
      confirmationHint: '确认后再保存。',
      items: <DailyRecordCandidateItem>[],
    );
  }

  @override
  Future<DailyRecordItem> create(DailyRecordCreateInput input) async {
    throw UnimplementedError();
  }

  @override
  Future<DailyRecordItem> update(
    String id,
    DailyRecordUpdateInput input,
  ) async {
    throw UnimplementedError();
  }

  @override
  Future<void> delete(String id) async {}
}

DailyRecordItem _waterRecord({
  required String id,
  required String value,
  String unit = 'ml',
}) {
  return DailyRecordItem(
    id: id,
    kind: DailyRecordKind.water,
    occurredAt: '2026-06-08',
    value: value,
    unit: unit,
    createdAt: '2026-06-08T08:00:00.000Z',
    updatedAt: '2026-06-08T08:00:00.000Z',
  );
}

class _FakeDoseLogDataSource extends DoseLogRemoteDataSource {
  _FakeDoseLogDataSource([this._items = const []])
    : super(
        api: MedicineDoseLogsApi(Dio(BaseOptions())),
        dio: Dio(BaseOptions()),
      );

  final List<DoseLogItem> _items;

  @override
  Future<List<DoseLogItem>> fetchForDate(String date) async => _items;
}

class _FakeReminderDataSource extends MedicineReminderRemoteDataSource {
  _FakeReminderDataSource([this._items = const []])
    : super(
        api: MedicineRemindersApi(Dio(BaseOptions())),
        dio: Dio(BaseOptions()),
      );

  final List<MedicineReminderItem> _items;

  @override
  TaskEither<LucentFailure, List<MedicineReminderItem>> fetchActive() =>
      TaskEither.right(_items);
}

class _ThrowingReminderDataSource extends _FakeReminderDataSource {
  @override
  TaskEither<LucentFailure, List<MedicineReminderItem>> fetchActive() {
    return TaskEither.left(
      LucentFailure.unknown(message: 'reminders unavailable'),
    );
  }
}

class _FakeUserSettingsRepository implements UserSettingsRepository {
  @override
  Future<UserSettings> getSettings() async => const UserSettings(
    aiSummariesEnabled: true,
    dataSharingConsent: false,
    assistantEnabled: true,
    assistantMemoryEnabled: false,
    waterTargetCount: 8,
    assistantContext: AssistantContextSettings(
      healthProfile: false,
      dailyRecords: false,
      sleepRecords: false,
      currentMedicines: false,
    ),
    securityPin: SecurityPinSettings(enabled: false),
  );

  @override
  Future<UserSettings> updateSettings({
    required bool aiSummariesEnabled,
    required bool dataSharingConsent,
    required bool assistantEnabled,
    required bool assistantMemoryEnabled,
    required int waterTargetCount,
    required AssistantContextPatch assistantContext,
  }) async => getSettings();

  @override
  Future<UserSettings> enableSecurityPin(String pin) async => getSettings();

  @override
  Future<UserSettings> changeSecurityPin(String oldPin, String newPin) async =>
      getSettings();

  @override
  Future<UserSettings> disableSecurityPin(String pin) async => getSettings();
}

MedicineReminderItem _reminder({
  required String id,
  required String currentMedicineId,
  required int scheduledHour,
  required int scheduledMinute,
}) {
  return MedicineReminderItem(
    id: id,
    currentMedicineId: currentMedicineId,
    scheduledHour: scheduledHour,
    scheduledMinute: scheduledMinute,
    isActive: true,
    createdAt: '2026-06-08T07:00:00.000Z',
    updatedAt: '2026-06-08T07:00:00.000Z',
  );
}

class _ThrowingWaterDailyRecordRepository extends _FakeDailyRecordRepository {
  @override
  Future<DailyRecordListData> fetchRecords(
    String date, {
    String? kind,
    int page = 1,
    int pageSize = 50,
  }) async {
    if (kind == DailyRecordKind.water.name) {
      throw StateError('water records unavailable');
    }
    return super.fetchRecords(date, kind: kind, page: page, pageSize: pageSize);
  }
}

class _ThrowingDoseLogDataSource extends _FakeDoseLogDataSource {
  @override
  Future<List<DoseLogItem>> fetchForDate(String date) async {
    throw StateError('dose logs unavailable');
  }
}

class _FakeNotificationRepository implements NotificationRepository {
  _FakeNotificationRepository({required this.count});

  final int count;

  @override
  Future<NotificationPage> findAll({
    required int page,
    required int pageSize,
  }) async => throw UnimplementedError();

  @override
  Future<NotificationDetail?> findOne(String id) async =>
      throw UnimplementedError();

  @override
  Future<int> getUnreadCount() async => count;

  @override
  Future<void> markAllAsRead() async {}

  @override
  Future<void> markAsRead(String id) async {}

  @override
  Future<void> markAsUnread(String id) async {}

  @override
  Future<void> delete(String id) async {}
}

const _snapshot = HealthContextSnapshot(
  summary: HealthSummary(
    age: 40,
    onboardingCompleted: true,
    activeAllergyCount: 0,
    conditionCount: 0,
    currentMedicineCount: 2,
    missingCoreProfileFields: [],
  ),
  profile: HealthProfile(
    birthDate: null,
    sexAtBirth: null,
    heightCm: null,
    weightKg: null,
    bloodType: null,
    locale: null,
    timezone: null,
    unitSystem: null,
    onboardingCompletedAt: null,
    emergencyContactName: null,
    emergencyContactPhone: null,
    extras: {},
  ),
  allergies: [],
  conditions: [],
  currentMedicines: [
    CurrentMedicineItem(
      id: 'med-1',
      source: 'manual',
      sourceRefId: null,
      displayName: 'Example medicine A',
      strengthText: '500 mg',
      doseText: 'Morning and evening',
      route: 'oral',
      startedAt: null,
      endedAt: null,
      isCurrent: true,
      note: null,
      createdAt: '2026-01-01T00:00:00.000Z',
      updatedAt: '2026-01-01T00:00:00.000Z',
    ),
    CurrentMedicineItem(
      id: 'med-2',
      source: 'manual',
      sourceRefId: null,
      displayName: 'Example medicine B',
      strengthText: '20 mg',
      doseText: 'Daily',
      route: 'oral',
      startedAt: null,
      endedAt: null,
      isCurrent: true,
      note: null,
      createdAt: '2026-01-01T00:00:00.000Z',
      updatedAt: '2026-01-01T00:00:00.000Z',
    ),
  ],
);
