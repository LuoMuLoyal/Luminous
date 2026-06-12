import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_openapi/lucent_openapi.dart'
    show MedicineDoseLogsApi, MedicineRemindersApi;
import 'package:luminous/features/health_context/domain/entities/health_context_snapshot.dart';
import 'package:luminous/features/health_context/domain/entities/health_context_write_inputs.dart';
import 'package:luminous/features/health_context/domain/repositories/health_context_repository.dart';
import 'package:luminous/features/medicine/data/datasources/dose_log_remote_data_source.dart';
import 'package:luminous/features/medicine/data/datasources/medicine_reminder_remote_data_source.dart';
import 'package:luminous/features/medicine/data/repositories/lucent_medicine_workspace.dart';
import 'package:luminous/features/medicine/domain/entities/medicine_workspace.dart';

void main() {
  test(
    'Lucent medicine workspace maps current medicines from health context',
    () async {
      final repository = LucentMedicineWorkspaceRepository(
        healthRepo: _FakeHealthContextRepository(),
        doseLogDs: _FakeDoseLogDataSource(),
        reminderDs: _FakeReminderDataSource([
          _reminder(id: 'reminder-1', currentMedicineId: 'med-1'),
        ]),
      );

      final workspace = await repository.fetchWorkspace();

      expect(workspace.hero.metricDosesToday, '1');
      expect(workspace.hero.metricAdherence, '0%');
      expect(workspace.hero.metricNextDose, '07:45');
      expect(workspace.plan.items, hasLength(1));
      expect(workspace.plan.items[0].rawName, 'Example medicine A');
      expect(workspace.plan.items[0].rawDosage, '500 mg');
      expect(workspace.plan.items[0].rawSchedule, 'Morning and evening');
      expect(workspace.plan.items[0].rawState, isNull);
      expect(workspace.plan.items[0].currentMedicineId, 'med-1');
      expect(workspace.plan.items[0].todayStatus, MedicineDoseStatus.pending);
      expect(workspace.plan.items[0].slots, hasLength(1));
      expect(workspace.plan.items[0].slots.single.rawTime, '07:45');
      expect(
        workspace.plan.items[0].stateKey,
        MedicineCopyKey.doseStatusPending,
      );
    },
  );

  test(
    'Lucent medicine workspace maps skipped dose logs as completed state',
    () async {
      final repository = LucentMedicineWorkspaceRepository(
        healthRepo: _FakeHealthContextRepository(),
        doseLogDs: _FakeDoseLogDataSource([
          const DoseLogItem(
            id: 'dose-1',
            currentMedicineId: 'med-1',
            status: DoseLogStatus.skipped,
            scheduledFor: '2026-06-04',
            createdAt: '2026-06-04T08:00:00.000Z',
          ),
        ]),
        reminderDs: _FakeReminderDataSource([
          _reminder(id: 'reminder-1', currentMedicineId: 'med-1'),
        ]),
      );

      final workspace = await repository.fetchWorkspace();

      expect(workspace.hero.metricAdherence, '100%');
      expect(workspace.hero.metricNextDose, '--');
      expect(
        workspace.plan.items[0].stateKey,
        MedicineCopyKey.doseStatusSkipped,
      );
      expect(workspace.plan.items[0].todayStatus, MedicineDoseStatus.skipped);
      expect(
        workspace.plan.items[0].slots.single.status,
        MedicineDoseStatus.skipped,
      );
    },
  );

  test(
    'Lucent medicine workspace leaves reminder slots empty when unset',
    () async {
      final repository = LucentMedicineWorkspaceRepository(
        healthRepo: _FakeHealthContextRepository(),
        doseLogDs: _FakeDoseLogDataSource(),
        reminderDs: _FakeReminderDataSource(),
      );

      final workspace = await repository.fetchWorkspace();

      expect(workspace.hero.metricNextDose, '--');
      expect(workspace.plan.items.single.slots, isEmpty);
      expect(
        workspace.plan.items.single.todayStatus,
        MedicineDoseStatus.pending,
      );
    },
  );
}

class _FakeHealthContextRepository implements HealthContextRepository {
  @override
  Future<HealthContextSnapshot> fetchHealthContext() async => _snapshot;

  @override
  Future<HealthContextSnapshot> updateProfile(
    HealthProfileUpdateInput input,
  ) async => _snapshot;

  @override
  Future<HealthContextSnapshot> createAllergy(
    HealthAllergyWriteInput input,
  ) async => _snapshot;

  @override
  Future<HealthContextSnapshot> updateAllergy(
    String id,
    HealthAllergyUpdateInput input,
  ) async => _snapshot;

  @override
  Future<HealthContextSnapshot> deleteAllergy(String id) async => _snapshot;

  @override
  Future<HealthContextSnapshot> createCondition(
    HealthConditionWriteInput input,
  ) async => _snapshot;

  @override
  Future<HealthContextSnapshot> updateCondition(
    String id,
    HealthConditionUpdateInput input,
  ) async => _snapshot;

  @override
  Future<HealthContextSnapshot> deleteCondition(String id) async => _snapshot;

  @override
  Future<HealthContextSnapshot> createCurrentMedicine(
    CurrentMedicineWriteInput input,
  ) async => _snapshot;

  @override
  Future<HealthContextSnapshot> updateCurrentMedicine(
    String id,
    CurrentMedicineUpdateInput input,
  ) async => _snapshot;

  @override
  Future<HealthContextSnapshot> deleteCurrentMedicine(String id) async =>
      _snapshot;
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

MedicineReminderItem _reminder({
  required String id,
  required String currentMedicineId,
  int scheduledHour = 7,
  int scheduledMinute = 45,
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
      displayName: 'Stopped med',
      strengthText: null,
      doseText: null,
      route: null,
      startedAt: null,
      endedAt: '2026-01-02',
      isCurrent: false,
      note: null,
      createdAt: '2026-01-01T00:00:00.000Z',
      updatedAt: '2026-01-02T00:00:00.000Z',
    ),
  ],
);
