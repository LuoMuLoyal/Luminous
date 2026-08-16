import 'dart:async';

import 'package:luminous/features/health_context/domain/entities/snapshot.dart';
import 'package:luminous/features/health_context/domain/entities/write_inputs.dart';
import 'package:luminous/features/health_context/domain/repositories/snapshot.dart';
import 'package:luminous/features/medicine/domain/entities/risk_check.dart';
import 'package:luminous/features/medicine/domain/repositories/risk_check.dart';

/// Builds an empty health context snapshot (optionally with
/// [currentMedicines]) for provider overrides in widget tests.
HealthContextSnapshot testHealthSnapshot({
  List<CurrentMedicineItem> currentMedicines = const [],
}) {
  return HealthContextSnapshot(
    summary: const HealthSummary(
      age: null,
      onboardingCompleted: false,
      activeAllergyCount: 0,
      conditionCount: 0,
      currentMedicineCount: 0,
      missingCoreProfileFields: [],
    ),
    profile: const HealthProfile(
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
    currentMedicines: currentMedicines,
  );
}

/// Test-only in-memory [HealthContextRepository] that records the most recent
/// [createCurrentMedicine] input (mirrors the fake in `test/search/page_test.dart`).
class FakeHealthContextRepository implements HealthContextRepository {
  CurrentMedicineWriteInput? createdCurrentMedicine;

  /// When set, [createCurrentMedicine] suspends until the completer completes.
  /// Lets tests observe pre-create UI (e.g. the precheck-unavailable toast).
  Completer<void>? createGate;

  /// When true, [createCurrentMedicine] returns a snapshot that contains the
  /// newly created medicine, so the success toast can render.
  bool reflectCreatedMedicine = false;

  @override
  Future<HealthContextSnapshot> fetchHealthContext() async {
    // Mirror [createCurrentMedicine]: when the fake reflects created
    // medicines, fetches return a snapshot containing them — so snapshot
    // provider refreshes (e.g. the DataChangeBus re-fetch after an add) flip
    // scan/search surfaces into the「已加入」state in tests.
    final created = createdCurrentMedicine;
    if (reflectCreatedMedicine && created != null) {
      return testHealthSnapshot(
        currentMedicines: [_createdMedicineItem(created)],
      );
    }
    return testHealthSnapshot();
  }

  CurrentMedicineItem _createdMedicineItem(CurrentMedicineWriteInput input) {
    return CurrentMedicineItem(
      id: 'created-medicine-1',
      source: input.source.name,
      sourceRefId: input.sourceRefId,
      displayName: input.displayName,
      strengthText: null,
      doseText: null,
      route: null,
      startedAt: null,
      endedAt: null,
      isCurrent: true,
      note: null,
      createdAt: '2026-08-16T00:00:00.000Z',
      updatedAt: '2026-08-16T00:00:00.000Z',
    );
  }

  @override
  Future<HealthContextSnapshot> updateProfile(
    HealthProfileUpdateInput input,
  ) async => testHealthSnapshot();

  @override
  Future<HealthContextSnapshot> createAllergy(
    HealthAllergyWriteInput input,
  ) async => testHealthSnapshot();

  @override
  Future<HealthContextSnapshot> updateAllergy(
    String id,
    HealthAllergyUpdateInput input,
  ) async => testHealthSnapshot();

  @override
  Future<HealthContextSnapshot> deleteAllergy(String id) async =>
      testHealthSnapshot();

  @override
  Future<HealthContextSnapshot> createCondition(
    HealthConditionWriteInput input,
  ) async => testHealthSnapshot();

  @override
  Future<HealthContextSnapshot> updateCondition(
    String id,
    HealthConditionUpdateInput input,
  ) async => testHealthSnapshot();

  @override
  Future<HealthContextSnapshot> deleteCondition(String id) async =>
      testHealthSnapshot();

  @override
  Future<HealthContextSnapshot> createCurrentMedicine(
    CurrentMedicineWriteInput input,
  ) async {
    final gate = createGate;
    if (gate != null) {
      await gate.future;
    }
    createdCurrentMedicine = input;
    if (reflectCreatedMedicine) {
      return testHealthSnapshot(
        currentMedicines: [_createdMedicineItem(input)],
      );
    }
    return testHealthSnapshot();
  }

  @override
  Future<HealthContextSnapshot> updateCurrentMedicine(
    String id,
    CurrentMedicineUpdateInput input,
  ) async => testHealthSnapshot();

  @override
  Future<HealthContextSnapshot> deleteCurrentMedicine(String id) async =>
      testHealthSnapshot();
}

/// Test-only in-memory [MedicineRiskCheckRepository] with a configurable
/// [runPrecheck] result (mirrors the fake in `test/search/page_test.dart`).
class FakeMedicineRiskCheckRepository implements MedicineRiskCheckRepository {
  FakeMedicineRiskCheckRepository(this.result, {this.failPrecheck = false});

  final MedicineRiskCheckResult result;

  /// When true, [runPrecheck] throws — simulating an unavailable pre-check.
  final bool failPrecheck;

  /// Records the most recent [runPrecheck] invocation arguments.
  ({String source, String sourceRefId})? lastPrecheck;

  @override
  Future<MedicineRiskCheckResult> runPrecheck({
    required String source,
    required String sourceRefId,
  }) async {
    lastPrecheck = (source: source, sourceRefId: sourceRefId);
    if (failPrecheck) {
      throw Exception('precheck unavailable');
    }
    return result;
  }

  @override
  Future<MedicineRiskCheckRecords> getRecords() async =>
      MedicineRiskCheckRecords(
        staticRecord: MedicineRiskCheckRecord(
          checkType: MedicineRiskCheckType.static_,
          result: result,
          riskScore: 0,
          riskLevel: result.overallRiskLevel,
          stale: false,
          createdAt: DateTime(2026, 7, 27),
          updatedAt: DateTime(2026, 7, 27),
        ),
      );

  @override
  Future<MedicineRiskCheckRecord> runCheck(MedicineRiskCheckType type) async =>
      MedicineRiskCheckRecord(
        checkType: type,
        result: result,
        riskScore: 0,
        riskLevel: result.overallRiskLevel,
        stale: false,
        createdAt: DateTime(2026, 7, 27),
        updatedAt: DateTime(2026, 7, 27),
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// A precheck result without findings or coverage issues: adding proceeds
/// without the confirm dialog.
const clearRiskCheckResult = MedicineRiskCheckResult(
  currentMedicineCount: 1,
  checkedMedicineCount: 1,
  findings: [],
  coverageIssues: [],
);
