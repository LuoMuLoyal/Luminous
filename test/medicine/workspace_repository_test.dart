import 'package:clock/clock.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lucent_api/lucent_api.dart'
    show MedicineDoseLogsApi, MedicineRemindersApi;
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/features/health_context/domain/entities/snapshot.dart';
import 'package:luminous/features/health_context/domain/entities/write_inputs.dart';
import 'package:luminous/features/health_context/domain/repositories/snapshot.dart';
import 'package:luminous/features/medicine/data/datasources/dose_log_remote.dart';
import 'package:luminous/features/medicine/data/datasources/reminder_remote.dart';
import 'package:luminous/features/medicine/data/repositories/lucent_workspace.dart';
import 'package:luminous/features/medicine/domain/entities/risk_check.dart';
import 'package:luminous/features/medicine/domain/entities/workspace.dart';
import 'package:luminous/features/medicine/domain/repositories/risk_check.dart';

import '../helpers/task_either.dart';

void main() {
  test(
    'Lucent medicine workspace maps current medicines from health context',
    () async {
      final repository = _repository(
        reminders: [_reminder(id: 'reminder-1', currentMedicineId: 'med-1')],
      );

      // 06:00 早于 07:45 槽，槽位未到期（not overdue）。
      final workspace = await withClock(
        Clock.fixed(DateTime(2026, 6, 4, 6, 0)),
        () => expectTaskRight(repository.fetchWorkspace()),
      );

      expect(workspace.hero.metricDosesToday, '1');
      expect(workspace.hero.metricAdherence, '--');
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
      expect(workspace.plan.items[0].slots.single.isOverdue, isFalse);
      expect(
        workspace.plan.items[0].stateKey,
        MedicineCopyKey.doseStatusPending,
      );
    },
  );

  test(
    'keeps later reminder slots pending after an earlier slot is marked',
    () async {
      final repository = _repository(
        logs: [
          _doseLog(
            id: 'dose-1',
            reminderId: 'reminder-1',
            scheduledTime: '07:45',
            status: DoseLogStatus.taken,
          ),
        ],
        reminders: [
          _reminder(id: 'reminder-1', currentMedicineId: 'med-1'),
          _reminder(
            id: 'reminder-2',
            currentMedicineId: 'med-1',
            scheduledHour: 19,
            scheduledMinute: 0,
          ),
        ],
      );

      // 10:00：07:45 已到期（taken），19:00 未到期。
      final workspace = await withClock(
        Clock.fixed(DateTime(2026, 6, 4, 10, 0)),
        () => expectTaskRight(repository.fetchWorkspace()),
      );

      expect(workspace.hero.metricDosesToday, '2');
      expect(workspace.hero.metricAdherence, '100%');
      expect(workspace.hero.metricNextDose, '19:00');
      expect(workspace.plan.items, hasLength(1));
      expect(workspace.plan.items[0].todayStatus, MedicineDoseStatus.pending);
      expect(
        workspace.plan.items[0].stateKey,
        MedicineCopyKey.doseStatusPending,
      );
      expect(workspace.plan.items[0].slots, hasLength(2));
      expect(workspace.plan.items[0].slots[0].reminderId, 'reminder-1');
      expect(workspace.plan.items[0].slots[0].scheduledTime, '07:45');
      expect(workspace.plan.items[0].slots[0].status, MedicineDoseStatus.taken);
      expect(workspace.plan.items[0].slots[0].isOverdue, isFalse);
      expect(workspace.plan.items[0].slots[1].reminderId, 'reminder-2');
      expect(workspace.plan.items[0].slots[1].scheduledTime, '19:00');
      expect(
        workspace.plan.items[0].slots[1].status,
        MedicineDoseStatus.pending,
      );
      expect(workspace.plan.items[0].slots[1].isOverdue, isFalse);
    },
  );

  test(
    'due taken slot counts 100% and next dose skips future pending slot',
    () async {
      final repository = _repository(
        logs: [
          _doseLog(
            id: 'dose-1',
            reminderId: 'reminder-1',
            scheduledTime: '07:45',
            status: DoseLogStatus.taken,
          ),
        ],
        reminders: [
          _reminder(id: 'reminder-1', currentMedicineId: 'med-1'),
          _reminder(
            id: 'reminder-2',
            currentMedicineId: 'med-1',
            scheduledHour: 12,
            scheduledMinute: 0,
          ),
          _reminder(
            id: 'reminder-3',
            currentMedicineId: 'med-1',
            scheduledHour: 19,
            scheduledMinute: 0,
          ),
        ],
      );

      final workspace = await withClock(
        Clock.fixed(DateTime(2026, 6, 4, 10, 0)),
        () => expectTaskRight(repository.fetchWorkspace()),
      );

      // 分母只有 07:45（已到期 taken），12:00/19:00 未到期不计入分母。
      expect(workspace.hero.metricAdherence, '100%');
      expect(workspace.hero.metricNextDose, '12:00');
      expect(workspace.hero.metricDosesToday, '3');
    },
  );

  test(
    'all-future slots yield -- adherence and earliest pending next dose',
    () async {
      final repository = _repository(
        reminders: [
          _reminder(
            id: 'reminder-1',
            currentMedicineId: 'med-1',
            scheduledHour: 12,
            scheduledMinute: 0,
          ),
          _reminder(
            id: 'reminder-2',
            currentMedicineId: 'med-1',
            scheduledHour: 19,
            scheduledMinute: 0,
          ),
        ],
      );

      final workspace = await withClock(
        Clock.fixed(DateTime(2026, 6, 4, 10, 0)),
        () => expectTaskRight(repository.fetchWorkspace()),
      );

      expect(workspace.hero.metricAdherence, '--');
      expect(workspace.hero.metricNextDose, '12:00');
      expect(workspace.hero.metricDosesToday, '2');
    },
  );

  test(
    'unconfirmed past-due slot is overdue and not counted as confirmed',
    () async {
      final repository = _repository(
        logs: [
          _doseLog(
            id: 'dose-1',
            reminderId: 'reminder-1',
            scheduledTime: '07:45',
            status: DoseLogStatus.taken,
          ),
        ],
        reminders: [
          _reminder(id: 'reminder-1', currentMedicineId: 'med-1'),
          _reminder(
            id: 'reminder-2',
            currentMedicineId: 'med-1',
            scheduledHour: 19,
            scheduledMinute: 0,
          ),
        ],
      );

      // 20:00：07:45 taken（已到期），19:00 未确认且已过时刻 → overdue。
      final workspace = await withClock(
        Clock.fixed(DateTime(2026, 6, 4, 20, 0)),
        () => expectTaskRight(repository.fetchWorkspace()),
      );

      expect(workspace.hero.metricAdherence, '50%');
      expect(workspace.hero.metricNextDose, '--');
      final slot19 = workspace.plan.items.single.slots[1];
      expect(slot19.scheduledTime, '19:00');
      expect(slot19.status, MedicineDoseStatus.pending);
      expect(slot19.isOverdue, isTrue);
    },
  );

  test(
    'single overdue pending slot yields -- next dose and 0% adherence',
    () async {
      final repository = _repository(
        reminders: [
          _reminder(
            id: 'reminder-1',
            currentMedicineId: 'med-1',
            scheduledHour: 8,
            scheduledMinute: 0,
          ),
        ],
      );

      // 10:00：08:00 槽未确认且已过时刻 → overdue，todayStatus 仍 pending。
      final workspace = await withClock(
        Clock.fixed(DateTime(2026, 6, 4, 10, 0)),
        () => expectTaskRight(repository.fetchWorkspace()),
      );

      expect(workspace.hero.metricNextDose, '--');
      expect(workspace.hero.metricAdherence, '0%');
      expect(
        workspace.plan.items.single.todayStatus,
        MedicineDoseStatus.pending,
      );
      expect(
        workspace.plan.items.single.slots.single.status,
        MedicineDoseStatus.pending,
      );
      expect(workspace.plan.items.single.slots.single.isOverdue, isTrue);
    },
  );

  test('skipped due slot counts in denominator but not numerator', () async {
    final repository = _repository(
      logs: [
        _doseLog(
          id: 'dose-1',
          reminderId: 'reminder-1',
          scheduledTime: '07:45',
          status: DoseLogStatus.skipped,
        ),
      ],
      reminders: [_reminder(id: 'reminder-1', currentMedicineId: 'med-1')],
    );

    final workspace = await withClock(
      Clock.fixed(DateTime(2026, 6, 4, 10, 0)),
      () => expectTaskRight(repository.fetchWorkspace()),
    );

    expect(workspace.hero.metricAdherence, '0%');
    expect(workspace.hero.metricNextDose, '--');
    expect(workspace.plan.items[0].stateKey, MedicineCopyKey.doseStatusSkipped);
    expect(workspace.plan.items[0].todayStatus, MedicineDoseStatus.skipped);
    expect(
      workspace.plan.items[0].slots.single.status,
      MedicineDoseStatus.skipped,
    );
    expect(workspace.plan.items[0].slots.single.isOverdue, isFalse);
  });

  test(
    'medicine without reminder slots contributes nothing to adherence',
    () async {
      final repository = _repository();

      final workspace = await withClock(
        Clock.fixed(DateTime(2026, 6, 4, 10, 0)),
        () => expectTaskRight(repository.fetchWorkspace()),
      );

      expect(workspace.hero.metricDosesToday, '0');
      expect(workspace.hero.metricAdherence, '--');
      expect(workspace.hero.metricNextDose, '--');
      expect(workspace.plan.items.single.slots, isEmpty);
      expect(
        workspace.plan.items.single.todayStatus,
        MedicineDoseStatus.pending,
      );
    },
  );

  test(
    '_isSlotDue boundary: equal minute is overdue, one minute before is not',
    () async {
      Future<MedicineWorkspace> fetchAt(DateTime now) async {
        final repository = _repository(
          reminders: [
            _reminder(
              id: 'reminder-1',
              currentMedicineId: 'med-1',
              scheduledHour: 10,
              scheduledMinute: 0,
            ),
          ],
        );
        return withClock(
          Clock.fixed(now),
          () => expectTaskRight(repository.fetchWorkspace()),
        );
      }

      final atMinute = await fetchAt(DateTime(2026, 6, 4, 10, 0));
      final beforeMinute = await fetchAt(DateTime(2026, 6, 4, 9, 59));

      expect(atMinute.plan.items.single.slots.single.isOverdue, isTrue);
      expect(beforeMinute.plan.items.single.slots.single.isOverdue, isFalse);
    },
  );
}

LucentMedicineWorkspaceRepository _repository({
  List<DoseLogItem> logs = const [],
  List<MedicineReminderItem> reminders = const [],
}) {
  return LucentMedicineWorkspaceRepository(
    healthRepo: _FakeHealthContextRepository(),
    doseLogDs: _FakeDoseLogDataSource(logs),
    reminderDs: _FakeReminderDataSource(reminders),
    riskCheckRepository: _FakeRiskCheckRepository(),
  );
}

DoseLogItem _doseLog({
  required String id,
  required String reminderId,
  required String scheduledTime,
  required DoseLogStatus status,
}) {
  return DoseLogItem(
    id: id,
    currentMedicineId: 'med-1',
    reminderId: reminderId,
    status: status,
    scheduledFor: '2026-06-04',
    scheduledTime: scheduledTime,
    createdAt: '2026-06-04T08:00:00.000Z',
    updatedAt: '2026-06-04T08:00:00.000Z',
  );
}

class _FakeHealthContextRepository implements HealthContextRepository {
  @override
  TaskEither<LucentFailure, HealthContextSnapshot> fetchHealthContext() =>
      TaskEither.right(_snapshot);

  @override
  TaskEither<LucentFailure, HealthContextSnapshot> updateProfile(
    HealthProfileUpdateInput input,
  ) => TaskEither.right(_snapshot);

  @override
  TaskEither<LucentFailure, HealthContextSnapshot> createAllergy(
    HealthAllergyWriteInput input,
  ) => TaskEither.right(_snapshot);

  @override
  TaskEither<LucentFailure, HealthContextSnapshot> updateAllergy(
    String id,
    HealthAllergyUpdateInput input,
  ) => TaskEither.right(_snapshot);

  @override
  TaskEither<LucentFailure, HealthContextSnapshot> deleteAllergy(String id) =>
      TaskEither.right(_snapshot);

  @override
  TaskEither<LucentFailure, HealthContextSnapshot> createCondition(
    HealthConditionWriteInput input,
  ) => TaskEither.right(_snapshot);

  @override
  TaskEither<LucentFailure, HealthContextSnapshot> updateCondition(
    String id,
    HealthConditionUpdateInput input,
  ) => TaskEither.right(_snapshot);

  @override
  TaskEither<LucentFailure, HealthContextSnapshot> deleteCondition(String id) =>
      TaskEither.right(_snapshot);

  @override
  TaskEither<LucentFailure, HealthContextSnapshot> createCurrentMedicine(
    CurrentMedicineWriteInput input,
  ) => TaskEither.right(_snapshot);

  @override
  TaskEither<LucentFailure, HealthContextSnapshot> updateCurrentMedicine(
    String id,
    CurrentMedicineUpdateInput input,
  ) => TaskEither.right(_snapshot);

  @override
  TaskEither<LucentFailure, HealthContextSnapshot> deleteCurrentMedicine(
    String id,
  ) => TaskEither.right(_snapshot);
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

class _FakeRiskCheckRepository implements MedicineRiskCheckRepository {
  @override
  TaskEither<LucentFailure, MedicineRiskCheckRecords> getRecords() {
    return TaskEither.right(const MedicineRiskCheckRecords());
  }

  @override
  TaskEither<LucentFailure, MedicineRiskCheckRecord> runCheck(
    MedicineRiskCheckType type,
  ) {
    return TaskEither.right(
      MedicineRiskCheckRecord(
        checkType: type,
        result: const MedicineRiskCheckResult(
          currentMedicineCount: 0,
          checkedMedicineCount: 0,
          findings: [],
          coverageIssues: [],
        ),
        riskScore: 0,
        riskLevel: MedicineRiskLevel.safe,
        stale: false,
        createdAt: DateTime(2026, 7, 27),
        updatedAt: DateTime(2026, 7, 27),
      ),
    );
  }

  @override
  TaskEither<LucentFailure, MedicineRiskCheckResult> runPrecheck({
    required String source,
    required String sourceRefId,
  }) {
    return TaskEither.right(
      const MedicineRiskCheckResult(
        currentMedicineCount: 0,
        checkedMedicineCount: 0,
        findings: [],
        coverageIssues: [],
      ),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
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
