import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/health_context/domain/entities/health_context_snapshot.dart';
import 'package:luminous/features/health_context/domain/entities/health_context_write_inputs.dart';
import 'package:luminous/features/health_context/domain/repositories/health_context_repository.dart';
import 'package:luminous/features/medicine/data/repositories/lucent_medicine_workspace.dart';

void main() {
  test('Lucent medicine workspace maps current medicines from health context', () async {
    final repository = LucentMedicineWorkspaceRepository(
      healthRepo: _FakeHealthContextRepository(),
    );

    final workspace = await repository.fetchWorkspace();

    expect(workspace.hero.metricDosesToday, '2');
    expect(workspace.plan.items, hasLength(2));
    expect(workspace.plan.items[0].rawName, 'Metformin XR');
    expect(workspace.plan.items[0].rawDosage, '500 mg');
    expect(workspace.plan.items[0].rawSchedule, 'Morning and evening');
    expect(workspace.plan.items[0].rawStock, 'oral');
    expect(workspace.plan.items[0].rawState, 'In use');
    expect(workspace.plan.items[1].rawState, 'Stopped');
  });
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
      displayName: 'Metformin XR',
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
