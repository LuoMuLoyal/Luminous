import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_openapi/lucent_openapi.dart';
import 'package:luminous/features/health_context/domain/entities/health_context_snapshot.dart';
import 'package:luminous/features/medicine/domain/entities/medicine_risk_check.dart';
import 'package:luminous/features/medicine/domain/services/medicine_risk_checker.dart';

void main() {
  test('medicine risk checker detects interaction and coverage issues', () {
    const snapshot = HealthContextSnapshot(
      summary: HealthSummary(
        age: 30,
        onboardingCompleted: true,
        activeAllergyCount: 1,
        conditionCount: 0,
        currentMedicineCount: 3,
        missingCoreProfileFields: [],
      ),
      profile: HealthProfile(
        birthDate: null,
        sexAtBirth: null,
        heightCm: null,
        pregnancyState: 'not_pregnant',
        lactationState: 'no',
        bloodType: null,
        locale: null,
        timezone: null,
        unitSystem: null,
        onboardingCompletedAt: null,
        extras: {},
      ),
      allergies: [
        AllergyItem(
          id: 'allergy-1',
          kind: 'drug',
          label: 'penicillin',
          reaction: null,
          severity: null,
          isActive: true,
          note: null,
          createdAt: '2026-06-14T00:00:00.000Z',
          updatedAt: '2026-06-14T00:00:00.000Z',
        ),
      ],
      conditions: [],
      currentMedicines: [
        CurrentMedicineItem(
          id: 'med-1',
          source: 'drugbank',
          sourceRefId: 'DB00001',
          displayName: 'Drug A',
          strengthText: null,
          doseText: null,
          route: null,
          startedAt: null,
          endedAt: null,
          isCurrent: true,
          note: null,
          createdAt: '2026-06-14T00:00:00.000Z',
          updatedAt: '2026-06-14T00:00:00.000Z',
        ),
        CurrentMedicineItem(
          id: 'med-2',
          source: 'drugbank',
          sourceRefId: 'DB00002',
          displayName: 'Drug B',
          strengthText: null,
          doseText: null,
          route: null,
          startedAt: null,
          endedAt: null,
          isCurrent: true,
          note: null,
          createdAt: '2026-06-14T00:00:00.000Z',
          updatedAt: '2026-06-14T00:00:00.000Z',
        ),
        CurrentMedicineItem(
          id: 'med-3',
          source: 'manual',
          sourceRefId: null,
          displayName: 'Manual C',
          strengthText: null,
          doseText: null,
          route: null,
          startedAt: null,
          endedAt: null,
          isCurrent: true,
          note: null,
          createdAt: '2026-06-14T00:00:00.000Z',
          updatedAt: '2026-06-14T00:00:00.000Z',
        ),
      ],
    );

    final checker = const MedicineRiskChecker();
    final result = checker.evaluate(
      snapshot: snapshot,
      medicines: [
        MedicineRiskMedicineDetail(
          item: snapshot.currentMedicines[0],
          detail: _detail(
            id: 'DB00001',
            name: 'Drug A',
            drugInteractions: [
              {'drugbankId': 'DB00002', 'description': 'Interaction detail'},
            ],
          ),
        ),
        MedicineRiskMedicineDetail(
          item: snapshot.currentMedicines[1],
          detail: _detail(id: 'DB00002', name: 'Drug B'),
        ),
      ],
    );

    expect(result.currentMedicineCount, 3);
    expect(result.checkedMedicineCount, 2);
    expect(result.coverageIssues, hasLength(1));
    expect(
      result.coverageIssues.single.reason,
      MedicineRiskCoverageReason.manualEntry,
    );
    expect(
      result.findings.any(
        (finding) => finding.type == MedicineRiskFindingType.interaction,
      ),
      isTrue,
    );
  });

  test('medicine risk checker detects duplicate ingredient and food note', () {
    const snapshot = HealthContextSnapshot(
      summary: HealthSummary(
        age: 30,
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
        pregnancyState: 'not_pregnant',
        lactationState: 'no',
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
          source: 'cn',
          sourceRefId: 'cn-1',
          displayName: '药品甲',
          strengthText: null,
          doseText: null,
          route: null,
          startedAt: null,
          endedAt: null,
          isCurrent: true,
          note: null,
          createdAt: '2026-06-14T00:00:00.000Z',
          updatedAt: '2026-06-14T00:00:00.000Z',
        ),
        CurrentMedicineItem(
          id: 'med-2',
          source: 'cn',
          sourceRefId: 'cn-2',
          displayName: '药品乙',
          strengthText: null,
          doseText: null,
          route: null,
          startedAt: null,
          endedAt: null,
          isCurrent: true,
          note: null,
          createdAt: '2026-06-14T00:00:00.000Z',
          updatedAt: '2026-06-14T00:00:00.000Z',
        ),
      ],
    );

    final checker = const MedicineRiskChecker();
    final result = checker.evaluate(
      snapshot: snapshot,
      medicines: [
        MedicineRiskMedicineDetail(
          item: snapshot.currentMedicines[0],
          detail: _detail(
            id: 'cn-1',
            name: '药品甲',
            ingredients: '布洛芬',
            foodInteractions: const ['Avoid alcohol while taking this medicine'],
          ),
        ),
        MedicineRiskMedicineDetail(
          item: snapshot.currentMedicines[1],
          detail: _detail(
            id: 'cn-2',
            name: '药品乙',
            ingredients: '布洛芬',
          ),
        ),
      ],
    );

    expect(
      result.findings.any(
        (finding) =>
            finding.type == MedicineRiskFindingType.duplicateIngredient,
      ),
      isTrue,
    );
    expect(
      result.findings.any(
        (finding) =>
            finding.type == MedicineRiskFindingType.foodInteraction &&
            finding.context == MedicineRiskFindingContext.alcohol,
      ),
      isTrue,
    );
  });
}

MedicineDetailDataDto _detail({
  required String id,
  required String name,
  Object? ingredients,
  List<String> foodInteractions = const [],
  Object? drugInteractions,
}) {
  return MedicineDetailDataDto(
    id: id,
    source_: id.startsWith('DB')
        ? MedicineDetailDataDtoSource_Enum.drugbank
        : MedicineDetailDataDtoSource_Enum.cn,
    name: name,
    subtitle: null,
    detail: MedicineDetailDataDtoDetail(
      kind: 'generic',
      groups: const [],
      categories: const [],
      atcCodes: const [],
      synonyms: const [],
      foodInteractions: foodInteractions,
      drugInteractions: drugInteractions,
      ingredients: ingredients,
    ),
  );
}
