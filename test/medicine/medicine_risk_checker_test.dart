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
        _currentMed(
          id: 'med-1',
          source: 'drugbank',
          sourceRefId: 'DB00001',
          displayName: 'Drug A',
        ),
        _currentMed(
          id: 'med-2',
          source: 'drugbank',
          sourceRefId: 'DB00002',
          displayName: 'Drug B',
        ),
        _currentMed(
          id: 'med-3',
          source: 'manual',
          sourceRefId: null,
          displayName: 'Manual C',
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
    expect(result.coverageSummary, contains('手动录入'));
    expect(result.hasCoverageGaps, isTrue);
    expect(
      result.findings.any((f) => f.type == MedicineRiskFindingType.interaction),
      isTrue,
    );
  });

  test('detects DrugBank-CN interaction via mapped drugbankIds', () {
    final snapshot = _basicSnapshot(age: 30, medicineCount: 2).copyWith(
      currentMedicines: [
        _currentMed(
          id: 'med-1',
          source: 'drugbank',
          sourceRefId: 'DB00001',
          displayName: 'Drug A',
        ),
        _currentMed(
          id: 'med-2',
          source: 'cn',
          sourceRefId: 'cn-2',
          displayName: '中文药 B',
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
          detail: _detail(
            id: 'cn-2',
            name: '中文药 B',
            drugbankIds: const ['DB00002'],
          ),
        ),
      ],
    );

    expect(
      result.findings.any((f) => f.type == MedicineRiskFindingType.interaction),
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
            foodInteractions: const [
              'Avoid alcohol while taking this medicine',
            ],
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
    expect(duplicate.evidence, 'acetaminophen');
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
          detail: _detail(id: 'cn-1', name: '阿莫西林胶囊', ingredients: '阿莫西林；青霉素'),
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
          detail: _detail(id: 'cn-1', name: '布洛芬片', ingredients: '布洛芬'),
        ),
      ],
    );

    expect(
      result.findings.any((f) => f.type == MedicineRiskFindingType.allergy),
      isFalse,
    );
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

  // ── Allergy / Duplicate boundary tests ──────────────────────────

  test(
    'allergy does NOT fire for near-match drugs in different map groups',
    () {
      // aspirin ≠ acetaminophen: distinct map groups
      final snapshot1 = _basicSnapshot(age: 30, medicineCount: 1).copyWith(
        allergies: [
          AllergyItem(
            id: 'allergy-1',
            kind: 'drug',
            label: 'aspirin',
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
      final result1 = checker.evaluate(
        snapshot: snapshot1,
        medicines: [
          MedicineRiskMedicineDetail(
            item: snapshot1.currentMedicines[0],
            detail: _detail(id: 'cn-1', name: '感冒灵', ingredients: '对乙酰氨基酚'),
          ),
        ],
      );
      expect(
        result1.findings.any((f) => f.type == MedicineRiskFindingType.allergy),
        isFalse,
      );

      // cephalosporin ≠ penicillin: distinct map groups
      final snapshot2 = _basicSnapshot(age: 30, medicineCount: 1).copyWith(
        allergies: [
          AllergyItem(
            id: 'allergy-1',
            kind: 'drug',
            label: 'cephalosporin',
            reaction: null,
            severity: null,
            isActive: true,
            note: null,
            createdAt: '2026-06-14T00:00:00.000Z',
            updatedAt: '2026-06-14T00:00:00.000Z',
          ),
        ],
      );
      final result2 = checker.evaluate(
        snapshot: snapshot2,
        medicines: [
          MedicineRiskMedicineDetail(
            item: snapshot2.currentMedicines[0],
            detail: _detail(
              id: 'cn-1',
              name: '阿莫西林胶囊',
              ingredients: '阿莫西林；青霉素',
            ),
          ),
        ],
      );
      expect(
        result2.findings.any((f) => f.type == MedicineRiskFindingType.allergy),
        isFalse,
      );
    },
  );

  test('allergy fires for unmapped drug via ingredient token match', () {
    // "erythromycin" is NOT in _allergyCrossLanguageMap — should still match
    // directly via string-normalized token intersection
    final snapshot = _basicSnapshot(age: 30, medicineCount: 1).copyWith(
      allergies: [
        AllergyItem(
          id: 'allergy-1',
          kind: 'drug',
          label: 'erythromycin',
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
            name: 'Erythromycin Tablet',
            ingredients: 'Erythromycin 250 mg',
          ),
        ),
      ],
    );

    final allergyFindings = result.findings.where(
      (f) => f.type == MedicineRiskFindingType.allergy,
    );
    expect(allergyFindings, hasLength(1));
    expect(allergyFindings.first.relatedLabel, 'erythromycin');
  });

  test(
    'duplicate does NOT fire for CN medicines with disjoint ingredients',
    () {
      final snapshot = _basicSnapshot(age: 30, medicineCount: 2);
      final checker = const MedicineRiskChecker();
      final result = checker.evaluate(
        snapshot: snapshot,
        medicines: [
          MedicineRiskMedicineDetail(
            item: snapshot.currentMedicines[0],
            detail: _detail(id: 'cn-1', name: '布洛芬片', ingredients: '布洛芬'),
          ),
          MedicineRiskMedicineDetail(
            item: snapshot.currentMedicines[1],
            detail: _detail(
              id: 'cn-2',
              name: '阿莫西林胶囊',
              ingredients: '阿莫西林；克拉维酸',
            ),
          ),
        ],
      );

      expect(
        result.findings.any(
          (f) => f.type == MedicineRiskFindingType.duplicateIngredient,
        ),
        isFalse,
      );
    },
  );

  test(
    'duplicate does NOT fire for DrugBank medicines with disjoint synonyms',
    () {
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
              name: 'Amoxicillin',
              synonyms: const ['Amoxil', 'Trimox', 'Amoxicillin'],
            ),
          ),
        ],
      );

      expect(
        result.findings.any(
          (f) => f.type == MedicineRiskFindingType.duplicateIngredient,
        ),
        isFalse,
      );
    },
  );

  test(
    'coverage summary stays explicit when no medicine detail could be checked',
    () {
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
    },
  );

  // ── Findings + coverage coexistence tests ────────────────────────

  test(
    'findings and coverage coexist: summary non-empty, both lists populated',
    () {
      final snapshot = HealthContextSnapshot(
        summary: HealthSummary(
          age: 28,
          onboardingCompleted: true,
          activeAllergyCount: 0,
          conditionCount: 0,
          currentMedicineCount: 3,
          missingCoreProfileFields: [],
        ),
        profile: HealthProfile(
          birthDate: null,
          sexAtBirth: null,
          heightCm: null,
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
          _currentMed(
            id: 'med-1',
            source: 'cn',
            sourceRefId: 'cn-1',
            displayName: '布洛芬',
          ),
          _currentMed(
            id: 'med-2',
            source: 'cn',
            sourceRefId: 'cn-2',
            displayName: '阿莫西林',
          ),
          _currentMed(
            id: 'med-3',
            source: 'manual',
            sourceRefId: null,
            displayName: '自备药',
          ),
        ],
      );

      final checker = const MedicineRiskChecker();
      final result = checker.evaluate(
        snapshot: snapshot,
        medicines: [
          MedicineRiskMedicineDetail(
            item: snapshot.currentMedicines[0],
            detail: _detail(id: 'cn-1', name: '布洛芬', ingredients: '布洛芬；对乙酰氨基酚'),
          ),
          MedicineRiskMedicineDetail(
            item: snapshot.currentMedicines[1],
            detail: _detail(
              id: 'cn-2',
              name: '阿莫西林',
              ingredients: '对乙酰氨基酚 500mg',
            ),
          ),
          // med-3 (manual) intentionally omitted → coverage gap
        ],
      );

      // Both findings AND coverage issues exist
      expect(result.hasFindings, isTrue);
      expect(result.hasCoverageGaps, isTrue);
      expect(result.findingCount, greaterThan(0));
      expect(result.coverageCount, greaterThan(0));
      expect(result.coverageSummary, isNotEmpty);
      expect(result.coverageSummary, contains('手动录入'));
    },
  );

  test('findings only, no coverage → summary empty, coverageIssues empty', () {
    final snapshot = _basicSnapshot(age: 30, medicineCount: 2);
    final checker = const MedicineRiskChecker();
    final result = checker.evaluate(
      snapshot: snapshot,
      medicines: [
        MedicineRiskMedicineDetail(
          item: snapshot.currentMedicines[0],
          detail: _detail(id: 'cn-1', name: '药品甲', ingredients: '布洛芬；对乙酰氨基酚'),
        ),
        MedicineRiskMedicineDetail(
          item: snapshot.currentMedicines[1],
          detail: _detail(id: 'cn-2', name: '药品乙', ingredients: '对乙酰氨基酚 500mg'),
        ),
      ],
    );

    expect(result.hasFindings, isTrue);
    expect(result.hasCoverageGaps, isFalse);
    expect(result.coverageCount, 0);
    expect(result.coverageIssues, isEmpty);
    expect(result.coverageSummary, isEmpty);
  });

  test('coverage only, no findings → summary non-empty, findings empty', () {
    final snapshot = _basicSnapshot(age: 30, medicineCount: 2);
    final checker = const MedicineRiskChecker();
    final result = checker.evaluate(
      snapshot: snapshot,
      medicines: const [], // no medicine details provided
    );

    expect(result.hasFindings, isFalse);
    expect(result.findings, isEmpty);
    expect(result.hasCoverageGaps, isTrue);
    expect(result.coverageCount, greaterThan(0));
    expect(result.coverageSummary, isNotEmpty);
  });

  test('coverageSummary combines mixed reason counts correctly', () {
    final snapshot = HealthContextSnapshot(
      summary: HealthSummary(
        age: 30,
        onboardingCompleted: true,
        activeAllergyCount: 0,
        conditionCount: 0,
        currentMedicineCount: 3,
        missingCoreProfileFields: [],
      ),
      profile: HealthProfile(
        birthDate: null,
        sexAtBirth: null,
        heightCm: null,
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
          sourceRefId: null,
          displayName: '未知来源',
        ),
      ],
    );

    final checker = const MedicineRiskChecker();
    final result = checker.evaluate(snapshot: snapshot, medicines: const []);

    // 1 manual + 1 missingSourceRef → two separate clauses in summary
    expect(result.coverageSummary, contains('1 种手动录入'));
    expect(result.coverageSummary, contains('1 种药品详情不可用'));
    // Separator between clauses
    expect(result.coverageSummary, contains('；'));
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
  List<String>? drugbankIds,
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
      drugbankIds: drugbankIds,
      ingredients: ingredients,
    ),
  );
}
