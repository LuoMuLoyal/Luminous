import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_openapi/lucent_openapi.dart'
    show MedicineDoseLogsApi, MedicineRemindersApi;
import 'package:luminous/features/health_context/data/providers/health_context_data_providers.dart';
import 'package:luminous/features/health_context/domain/entities/health_context_snapshot.dart';
import 'package:luminous/features/medicine/data/datasources/dose_log_remote_data_source.dart';
import 'package:luminous/features/medicine/data/datasources/medicine_reminder_remote_data_source.dart';
import 'package:luminous/features/medicine/data/repositories/mock_medicine_workspace_repository.dart';
import 'package:luminous/features/record/data/providers/daily_record_providers.dart';
import 'package:luminous/features/record/domain/entities/daily_record.dart';
import 'package:luminous/features/record/domain/entities/daily_record_candidates.dart';
import 'package:luminous/features/record/domain/entities/daily_record_inputs.dart';
import 'package:luminous/features/record/domain/repositories/daily_record_repository.dart';
import 'package:luminous/features/today/data/repositories/mock_today_repository.dart';

void main() {
  test(
    'Lucent today repository uses earliest pending medicine reminder',
    () async {
      final container = ProviderContainer(
        overrides: [
          healthContextSnapshotProvider.overrideWith((ref) async => _snapshot),
          dailyRecordRepositoryProvider.overrideWithValue(
            _FakeDailyRecordRepository(),
          ),
          doseLogRemoteDataSourceProvider.overrideWithValue(
            _FakeDoseLogDataSource([
              const DoseLogItem(
                id: 'dose-1',
                currentMedicineId: 'med-1',
                status: DoseLogStatus.taken,
                scheduledFor: '2026-06-08',
                createdAt: '2026-06-08T07:00:00.000Z',
              ),
            ]),
          ),
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
        ],
      );
      addTearDown(container.dispose);

      final dashboard = await container
          .read(todayRepositoryProvider)
          .fetchDashboard();

      expect(dashboard.medication.medicineCount, 2);
      expect(dashboard.medication.pendingCount, 1);
      expect(dashboard.medication.nextDoseTimeLabel, '12:30');
      expect(dashboard.medication.nextMedicineName, 'Example medicine B');
    },
  );

  test(
    'Lucent today repository falls back when reminders are unavailable',
    () async {
      final container = ProviderContainer(
        overrides: [
          healthContextSnapshotProvider.overrideWith((ref) async => _snapshot),
          dailyRecordRepositoryProvider.overrideWithValue(
            _FakeDailyRecordRepository(),
          ),
          doseLogRemoteDataSourceProvider.overrideWithValue(
            _FakeDoseLogDataSource(),
          ),
          medicineReminderRemoteDataSourceProvider.overrideWithValue(
            _ThrowingReminderDataSource(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final dashboard = await container
          .read(todayRepositoryProvider)
          .fetchDashboard();

      expect(dashboard.medication.pendingCount, 2);
      expect(dashboard.medication.nextDoseTimeLabel, '--');
      expect(dashboard.medication.nextMedicineName, 'Example medicine A');
    },
  );
}

class _FakeDailyRecordRepository implements DailyRecordRepository {
  @override
  Future<DailyRecordListData> fetchRecords(
    String date, {
    String? kind,
    int page = 1,
    int pageSize = 50,
  }) async {
    return const DailyRecordListData(items: [], total: 0);
  }

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
  Future<List<MedicineReminderItem>> fetchActive() async => _items;
}

class _ThrowingReminderDataSource extends _FakeReminderDataSource {
  @override
  Future<List<MedicineReminderItem>> fetchActive() async {
    throw StateError('reminders unavailable');
  }
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
    pregnancyState: null,
    lactationState: null,
    bloodType: null,
    locale: null,
    timezone: null,
    unitSystem: null,
    onboardingCompletedAt: null,
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
