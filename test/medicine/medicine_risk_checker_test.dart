import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_openapi/lucent_openapi.dart';
import 'package:luminous/features/health_context/domain/entities/health_context_snapshot.dart';
import 'package:luminous/features/medicine/domain/entities/medicine_risk_check.dart';
import 'package:luminous/features/medicine/domain/services/medicine_risk_checker.dart';

void main() {
  test('detects interaction and coverage issues (DB-DB)', () {
    final snapshot = HealthContextSnapshot(
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
        _currentMed(id: 'med-1', source: 'drugbank', sourceRefId: 'DB00001', displayName: 'Drug A'),
        _currentMed(id: 'med-2', source: 'drugbank', sourceRefId: 'DB00002', displayName: 'Drug B'),
        _currentMed(id: 'med-3', source: 'manual', sourceRefId: null, displayName: 'Manual C'),
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
    expect(result.coverageSummary, contains('手动录入'));
    expect(result.hasCoverageGaps, isTrue);
    expect(
      result.findings.any(
        (f) => f.type == MedicineRiskFindingType.interaction,
      ),
      isTrue,
    );
  });

  test('detects CN duplicate ingredient and food interaction', () {
    final snapshot = _basicSnapshot(age: 30, medicineCount: 2);
    final checker = const MedicineRiskChecker();
    final result = checker.evaluate(
      snapshot: snapshot,
      medicines: [
        MedicineRiskMedicineDetail(
          item: snapshot.currentMedicines[0],
          detail: _detail(
            id: 'cn-1',
            name: '药品甲',
            ingredients: '布洛芬；对乙酰氨基酚',
            foodInteractions: const ['Avoid alcohol while taking this medicine'],
          ),
        ),
        MedicineRiskMedicineDetail(
          item: snapshot.currentMedicines[1],
          detail: _detail(
            id: 'cn-2',
            name: '药品乙',
            ingredients: '对乙酰氨基酚 500mg / 片',
          ),
        ),
      ],
    );

    final duplicate = result.findings.firstWhere(
      (f) => f.type == MedicineRiskFindingType.duplicateIngredient,
    );
    expect(duplicate.evidence, '对乙酰氨基酚');
    expect(
      result.findings.any(
        (f) =>
            f.type == MedicineRiskFindingType.foodInteraction &&
            f.context == MedicineRiskFindingContext.alcohol,
      ),
      isTrue,
    );
  });

  test('detects allergy via ingredient token match (CN)', () {
    final snapshot = _basicSnapshot(age: 30, medicineCount: 1).copyWith(
      allergies: [
        AllergyItem(
          id: 'allergy-1',
          kind: 'drug',
          label: '对乙酰氨基酚',
          reaction: null,
          severity: null,
          isActive: true,
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
            name: '感冒灵',
            ingredients: '对乙酰氨基酚；马来酸氯苯那敏',
          ),
        ),
      ],
    );

    expect(
      result.findings.any((f) => f.type == MedicineRiskFindingType.allergy),
      isTrue,
    );
  });

  test('detects allergy via cross-language mapping (penicillin ↔ 青霉素)', () {
    final snapshot = _basicSnapshot(age: 30, medicineCount: 1).copyWith(
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
    );
    final checker = const MedicineRiskChecker();
    // Drug allergy labeled "penicillin", but CN drug ingredient uses "青霉素"
    final result = checker.evaluate(
      snapshot: snapshot,
      medicines: [
        MedicineRiskMedicineDetail(
          item: snapshot.currentMedicines[0],
          detail: _detail(
            id: 'cn-1',
            name: '阿莫西林胶囊',
            ingredients: '阿莫西林；青霉素',
          ),
        ),
      ],
    );

    expect(
      result.findings.any((f) => f.type == MedicineRiskFindingType.allergy),
      isTrue,
    );
  });

  test('allergy does NOT fire for unrelated drugs', () {
    final snapshot = _basicSnapshot(age: 30, medicineCount: 1).copyWith(
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
    );
    final checker = const MedicineRiskChecker();
    final result = checker.evaluate(
      snapshot: snapshot,
      medicines: [
        MedicineRiskMedicineDetail(
          item: snapshot.currentMedicines[0],
          detail: _detail(
            id: 'cn-1',
            name: '布洛芬片',
            ingredients: '布洛芬',
          ),
        ),
      ],
    );

    expect(
      result.findings.any((f) => f.type == MedicineRiskFindingType.allergy),
      isFalse,
    );
  });

  test('pediatric finding only fires for age < 18', () {
    final childSnapshot = _basicSnapshot(age: 10, medicineCount: 1);
    final adultSnapshot = _basicSnapshot(age: 30, medicineCount: 1);

    final checker = const MedicineRiskChecker();
    final detail = _detail(
      id: 'cn-1',
      name: '药品',
      pediatricUse: '儿童慎用',
    );

    final childResult = checker.evaluate(
      snapshot: childSnapshot,
      medicines: [
        MedicineRiskMedicineDetail(
          item: childSnapshot.currentMedicines[0],
          detail: detail,
        ),
      ],
    );
    final adultResult = checker.evaluate(
      snapshot: adultSnapshot,
      medicines: [
        MedicineRiskMedicineDetail(
          item: adultSnapshot.currentMedicines[0],
          detail: detail,
        ),
      ],
    );

    expect(
      childResult.findings.any(
        (f) =>
            f.type == MedicineRiskFindingType.specialGroup &&
            f.context == MedicineRiskFindingContext.pediatric,
      ),
      isTrue,
    );
    expect(
      adultResult.findings.any(
        (f) =>
            f.type == MedicineRiskFindingType.specialGroup &&
            f.context == MedicineRiskFindingContext.pediatric,
      ),
      isFalse,
    );
  });

  test('pediatric without warning emits info-level boundary finding', () {
    final snapshot = _basicSnapshot(age: 10, medicineCount: 1);
    final checker = const MedicineRiskChecker();
    final result = checker.evaluate(
      snapshot: snapshot,
      medicines: [
        MedicineRiskMedicineDetail(
          item: snapshot.currentMedicines[0],
          detail: _detail(
            id: 'cn-1',
            name: '药品',
          ),
        ),
      ],
    );

    final pediatricFindings = result.findings.where(
      (f) =>
          f.type == MedicineRiskFindingType.specialGroup &&
          f.context == MedicineRiskFindingContext.pediatric,
    );
    expect(pediatricFindings, hasLength(1));
    expect(pediatricFindings.first.severity, MedicineRiskSeverity.info);
    expect(pediatricFindings.first.evidence, isNull);
  });

  test('geriatric without warning emits info-level boundary finding', () {
    final snapshot = _basicSnapshot(age: 72, medicineCount: 1);
    final checker = const MedicineRiskChecker();
    final result = checker.evaluate(
      snapshot: snapshot,
      medicines: [
        MedicineRiskMedicineDetail(
          item: snapshot.currentMedicines[0],
          detail: _detail(
            id: 'cn-1',
            name: '药品',
          ),
        ),
      ],
    );

    final geriatricFindings = result.findings.where(
      (f) =>
          f.type == MedicineRiskFindingType.specialGroup &&
          f.context == MedicineRiskFindingContext.geriatric,
    );
    expect(geriatricFindings, hasLength(1));
    expect(geriatricFindings.first.severity, MedicineRiskSeverity.info);
    expect(geriatricFindings.first.evidence, isNull);
  });

  test('pregnancy without warning emits info-level coverage finding', () {
    final snapshot = _basicSnapshot(age: 28, medicineCount: 1).copyWith(
      profile: _basicSnapshot(age: 28, medicineCount: 1).profile.copyWith(
        pregnancyState: 'pregnant',
        lactationState: 'no',
      ),
    );
    final checker = const MedicineRiskChecker();
    final result = checker.evaluate(
      snapshot: snapshot,
      medicines: [
        MedicineRiskMedicineDetail(
          item: snapshot.currentMedicines[0],
          detail: _detail(
            id: 'cn-1',
            name: '药品',
            // no pregnancyLactation field — warning unavailable
          ),
        ),
      ],
    );

    final pregFindings = result.findings.where(
      (f) =>
          f.type == MedicineRiskFindingType.specialGroup &&
          f.context == MedicineRiskFindingContext.pregnancy,
    );
    expect(pregFindings, hasLength(1));
    expect(pregFindings.first.severity, MedicineRiskSeverity.info);
    expect(pregFindings.first.evidence, isNull);
  });

  test('detects DrugBank-DrugBank duplicate via synonyms', () {
    final snapshot = _dbSnapshot(medicineCount: 2);
    final checker = const MedicineRiskChecker();
    final result = checker.evaluate(
      snapshot: snapshot,
      medicines: [
        MedicineRiskMedicineDetail(
          item: snapshot.currentMedicines[0],
          detail: _detail(
            id: 'DB00001',
            name: 'Ibuprofen',
            synonyms: const ['Advil', 'Motrin', 'Ibuprofen'],
          ),
        ),
        MedicineRiskMedicineDetail(
          item: snapshot.currentMedicines[1],
          detail: _detail(
            id: 'DB00002',
            name: 'Motrin',
            synonyms: const ['Motrin', 'Ibuprofen'],
          ),
        ),
      ],
    );

    expect(
      result.findings.any(
        (f) => f.type == MedicineRiskFindingType.duplicateIngredient,
      ),
      isTrue,
    );
  });

  test('allergy detects via DrugBank synonym tokens', () {
    final snapshot = _dbSnapshot(medicineCount: 1).copyWith(
      allergies: [
        AllergyItem(
          id: 'allergy-1',
          kind: 'drug',
          label: 'ibuprofen',
          reaction: null,
          severity: null,
          isActive: true,
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
            name: 'Advil',
            synonyms: const ['Advil', 'Ibuprofen'],
          ),
        ),
      ],
    );

    expect(
      result.findings.any((f) => f.type == MedicineRiskFindingType.allergy),
      isTrue,
    );
  });

  test('coverage summary stays explicit when no medicine detail could be checked', () {
    final snapshot = HealthContextSnapshot(
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
      allergies: const [],
      conditions: const [],
      currentMedicines: [
        _currentMed(
          id: 'med-1',
          source: 'manual',
          sourceRefId: null,
          displayName: '自备药',
        ),
        _currentMed(
          id: 'med-2',
          source: 'cn',
          sourceRefId: 'cn-2',
          displayName: '处方药',
        ),
      ],
    );

    final checker = const MedicineRiskChecker();
    final result = checker.evaluate(snapshot: snapshot, medicines: const []);

    expect(result.checkedMedicineCount, 0);
    expect(result.coverageIssues, hasLength(2));
    expect(result.coverageSummary, contains('手动录入'));
    expect(result.coverageSummary, contains('药品详情不可用'));
  });
}

HealthContextSnapshot _dbSnapshot({required int medicineCount}) {
  final medicines = List.generate(
    medicineCount,
    (i) => _currentMed(
      id: 'med-${i + 1}',
      source: 'drugbank',
      sourceRefId: 'DB0000${i + 1}',
      displayName: 'Drug ${i + 1}',
    ),
  );

  return HealthContextSnapshot(
    summary: HealthSummary(
      age: 30,
      onboardingCompleted: true,
      activeAllergyCount: 0,
      conditionCount: 0,
      currentMedicineCount: medicineCount,
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
    allergies: const [],
    conditions: const [],
    currentMedicines: medicines,
  );
}

HealthContextSnapshot _basicSnapshot({
  required int age,
  required int medicineCount,
}) {
  final medicines = List.generate(
    medicineCount,
    (i) => _currentMed(
      id: 'med-${i + 1}',
      source: 'cn',
      sourceRefId: 'cn-${i + 1}',
      displayName: '药品${i + 1}',
    ),
  );

  return HealthContextSnapshot(
    summary: HealthSummary(
      age: age,
      onboardingCompleted: true,
      activeAllergyCount: 0,
      conditionCount: 0,
      currentMedicineCount: medicineCount,
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
    allergies: const [],
    conditions: const [],
    currentMedicines: medicines,
  );
}

CurrentMedicineItem _currentMed({
  required String id,
  required String source,
  required String? sourceRefId,
  required String displayName,
}) {
  return CurrentMedicineItem(
    id: id,
    source: source,
    sourceRefId: sourceRefId,
    displayName: displayName,
    strengthText: null,
    doseText: null,
    route: null,
    startedAt: null,
    endedAt: null,
    isCurrent: true,
    note: null,
    createdAt: '2026-06-14T00:00:00.000Z',
    updatedAt: '2026-06-14T00:00:00.000Z',
  );
}

MedicineDetailDataDto _detail({
  required String id,
  required String name,
  Object? ingredients,
  List<String> synonyms = const [],
  List<String> foodInteractions = const [],
  Object? drugInteractions,
  String? pediatricUse,
  String? geriatricUse,
  String? pregnancyLactation,
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
      synonyms: synonyms,
      foodInteractions: foodInteractions,
      drugInteractions: drugInteractions,
      ingredients: ingredients,
      pediatricUse: pediatricUse,
      geriatricUse: geriatricUse,
      pregnancyLactation: pregnancyLactation,
    ),
  );
}
