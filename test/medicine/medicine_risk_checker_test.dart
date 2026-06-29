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

  test('pediatric finding only fires for age < 18', () {
    final childSnapshot = _basicSnapshot(age: 10, medicineCount: 1);
    final adultSnapshot = _basicSnapshot(age: 30, medicineCount: 1);

    final checker = const MedicineRiskChecker();
    final detail = _detail(id: 'cn-1', name: '药品', pediatricUse: '儿童慎用');

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
          detail: _detail(id: 'cn-1', name: '药品'),
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
          detail: _detail(id: 'cn-1', name: '药品'),
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
      profile: _basicSnapshot(
        age: 28,
        medicineCount: 1,
      ).profile.copyWith(pregnancyState: 'pregnant', lactationState: 'no'),
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
            // no pregnancy/lactation fields — warning unavailable
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

  // ── Special-population missing-field boundary tests ──────────────

  test('lactation without warning emits info-level boundary finding', () {
    final snapshot = _basicSnapshot(age: 28, medicineCount: 1).copyWith(
      profile: _basicSnapshot(
        age: 28,
        medicineCount: 1,
      ).profile.copyWith(pregnancyState: 'not_pregnant', lactationState: 'yes'),
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
            // no pregnancy/lactation fields
          ),
        ),
      ],
    );

    final lactFindings = result.findings.where(
      (f) =>
          f.type == MedicineRiskFindingType.specialGroup &&
          f.context == MedicineRiskFindingContext.lactation,
    );
    expect(lactFindings, hasLength(1));
    expect(lactFindings.first.severity, MedicineRiskSeverity.info);
    expect(lactFindings.first.evidence, isNull);
  });

  test(
    'pregnancy "trying" and "postpartum" without field emit info boundary',
    () {
      for (final state in ['trying', 'postpartum']) {
        final snapshot = _basicSnapshot(age: 28, medicineCount: 1).copyWith(
          profile: _basicSnapshot(
            age: 28,
            medicineCount: 1,
          ).profile.copyWith(pregnancyState: state, lactationState: 'no'),
        );
        final checker = const MedicineRiskChecker();
        final result = checker.evaluate(
          snapshot: snapshot,
          medicines: [
            MedicineRiskMedicineDetail(
              item: snapshot.currentMedicines[0],
              detail: _detail(id: 'cn-1', name: '药品'),
            ),
          ],
        );

        final pregFindings = result.findings.where(
          (f) =>
              f.type == MedicineRiskFindingType.specialGroup &&
              f.context == MedicineRiskFindingContext.pregnancy,
        );
        expect(pregFindings, hasLength(1), reason: 'state=$state');
        expect(
          pregFindings.first.severity,
          MedicineRiskSeverity.info,
          reason: 'state=$state',
        );
        expect(pregFindings.first.evidence, isNull, reason: 'state=$state');
      }
    },
  );

  test('pregnancy field present but user not at risk → silent', () {
    final snapshot = _basicSnapshot(age: 28, medicineCount: 1).copyWith(
      profile: _basicSnapshot(
        age: 28,
        medicineCount: 1,
      ).profile.copyWith(pregnancyState: 'not_pregnant', lactationState: 'no'),
    );
    final checker = const MedicineRiskChecker();
    final result = checker.evaluate(
      snapshot: snapshot,
      medicines: [
        MedicineRiskMedicineDetail(
          item: snapshot.currentMedicines[0],
          detail: _detail(id: 'cn-1', name: '药品', pregnancy: '孕妇禁用'),
        ),
      ],
    );

    final pregFindings = result.findings.where(
      (f) =>
          f.type == MedicineRiskFindingType.specialGroup &&
          f.context == MedicineRiskFindingContext.pregnancy,
    );
    expect(pregFindings, isEmpty);

    final lactFindings = result.findings.where(
      (f) =>
          f.type == MedicineRiskFindingType.specialGroup &&
          f.context == MedicineRiskFindingContext.lactation,
    );
    expect(lactFindings, isEmpty);
  });

  test('lactation field present but user not lactating → silent', () {
    final snapshot = _basicSnapshot(age: 28, medicineCount: 1).copyWith(
      profile: _basicSnapshot(
        age: 28,
        medicineCount: 1,
      ).profile.copyWith(pregnancyState: 'not_pregnant', lactationState: 'no'),
    );
    final checker = const MedicineRiskChecker();
    final result = checker.evaluate(
      snapshot: snapshot,
      medicines: [
        MedicineRiskMedicineDetail(
          item: snapshot.currentMedicines[0],
          detail: _detail(id: 'cn-1', name: '药品', lactation: '哺乳期禁用'),
        ),
      ],
    );

    final lactFindings = result.findings.where(
      (f) =>
          f.type == MedicineRiskFindingType.specialGroup &&
          f.context == MedicineRiskFindingContext.lactation,
    );
    expect(lactFindings, isEmpty);
  });

  test('null pregnancyState or lactationState with field → silent', () {
    final snapshot = _basicSnapshot(age: 28, medicineCount: 1).copyWith(
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
            pregnancy: '孕妇及哺乳期禁用',
            lactation: '孕妇及哺乳期禁用',
          ),
        ),
      ],
    );

    final pregFindings = result.findings.where(
      (f) =>
          f.type == MedicineRiskFindingType.specialGroup &&
          f.context == MedicineRiskFindingContext.pregnancy,
    );
    expect(pregFindings, isEmpty);

    final lactFindings = result.findings.where(
      (f) =>
          f.type == MedicineRiskFindingType.specialGroup &&
          f.context == MedicineRiskFindingContext.lactation,
    );
    expect(lactFindings, isEmpty);
  });

  // ── Special-population text classifier unit tests ───────────────

  test('classifier maps "孕妇禁用" → contraindicated → high', () {
    final snapshot = _basicSnapshot(age: 28, medicineCount: 1).copyWith(
      profile: _basicSnapshot(
        age: 28,
        medicineCount: 1,
      ).profile.copyWith(pregnancyState: 'pregnant', lactationState: 'no'),
    );
    final checker = const MedicineRiskChecker();
    final result = checker.evaluate(
      snapshot: snapshot,
      medicines: [
        MedicineRiskMedicineDetail(
          item: snapshot.currentMedicines[0],
          detail: _detail(id: 'cn-1', name: '药品', pregnancy: '孕妇禁用'),
        ),
      ],
    );

    final finding = result.findings.firstWhere(
      (f) => f.context == MedicineRiskFindingContext.pregnancy,
    );
    expect(
      finding.specialPopulationConclusion,
      SpecialPopulationConclusion.contraindicated,
    );
    expect(finding.severity, MedicineRiskSeverity.high);
  });

  test('pregnancy-only text does not leak into lactation finding', () {
    final snapshot = _basicSnapshot(age: 28, medicineCount: 1).copyWith(
      profile: _basicSnapshot(
        age: 28,
        medicineCount: 1,
      ).profile.copyWith(pregnancyState: 'not_pregnant', lactationState: 'yes'),
    );
    final checker = const MedicineRiskChecker();
    final result = checker.evaluate(
      snapshot: snapshot,
      medicines: [
        MedicineRiskMedicineDetail(
          item: snapshot.currentMedicines[0],
          detail: _detail(id: 'cn-1', name: '药品', pregnancy: '孕妇禁用'),
        ),
      ],
    );

    final lactationFinding = result.findings.singleWhere(
      (f) => f.context == MedicineRiskFindingContext.lactation,
    );
    expect(lactationFinding.evidence, isNull);
    expect(lactationFinding.specialPopulationConclusion, isNull);
    expect(lactationFinding.severity, MedicineRiskSeverity.info);
  });

  test('lactation-only text does not leak into pregnancy finding', () {
    final snapshot = _basicSnapshot(age: 28, medicineCount: 1).copyWith(
      profile: _basicSnapshot(
        age: 28,
        medicineCount: 1,
      ).profile.copyWith(pregnancyState: 'pregnant', lactationState: 'no'),
    );
    final checker = const MedicineRiskChecker();
    final result = checker.evaluate(
      snapshot: snapshot,
      medicines: [
        MedicineRiskMedicineDetail(
          item: snapshot.currentMedicines[0],
          detail: _detail(id: 'cn-1', name: '药品', lactation: '哺乳期禁用'),
        ),
      ],
    );

    final pregnancyFinding = result.findings.singleWhere(
      (f) => f.context == MedicineRiskFindingContext.pregnancy,
    );
    expect(pregnancyFinding.evidence, isNull);
    expect(pregnancyFinding.specialPopulationConclusion, isNull);
    expect(pregnancyFinding.severity, MedicineRiskSeverity.info);
  });

  test(
    'combined pregnancy and lactation text still supports both findings',
    () {
      final snapshot = _basicSnapshot(age: 28, medicineCount: 1).copyWith(
        profile: _basicSnapshot(
          age: 28,
          medicineCount: 1,
        ).profile.copyWith(pregnancyState: 'pregnant', lactationState: 'yes'),
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
              pregnancy: '孕妇及哺乳期禁用',
              lactation: '孕妇及哺乳期禁用',
            ),
          ),
        ],
      );

      final pregnancyFinding = result.findings.singleWhere(
        (f) => f.context == MedicineRiskFindingContext.pregnancy,
      );
      final lactationFinding = result.findings.singleWhere(
        (f) => f.context == MedicineRiskFindingContext.lactation,
      );
      expect(pregnancyFinding.evidence, '孕妇及哺乳期禁用');
      expect(lactationFinding.evidence, '孕妇及哺乳期禁用');
      expect(
        pregnancyFinding.specialPopulationConclusion,
        SpecialPopulationConclusion.contraindicated,
      );
      expect(
        lactationFinding.specialPopulationConclusion,
        SpecialPopulationConclusion.contraindicated,
      );
    },
  );

  test('classifier maps "避免使用" → avoid → high', () {
    final snapshot = _basicSnapshot(age: 28, medicineCount: 1).copyWith(
      profile: _basicSnapshot(
        age: 28,
        medicineCount: 1,
      ).profile.copyWith(pregnancyState: 'pregnant', lactationState: 'no'),
    );
    final checker = const MedicineRiskChecker();
    final result = checker.evaluate(
      snapshot: snapshot,
      medicines: [
        MedicineRiskMedicineDetail(
          item: snapshot.currentMedicines[0],
          detail: _detail(id: 'cn-1', name: '药品', pregnancy: '孕妇应避免使用'),
        ),
      ],
    );

    final finding = result.findings.firstWhere(
      (f) => f.context == MedicineRiskFindingContext.pregnancy,
    );
    expect(
      finding.specialPopulationConclusion,
      SpecialPopulationConclusion.avoid,
    );
    expect(finding.severity, MedicineRiskSeverity.high);
  });

  test('classifier maps "慎用" → caution → medium', () {
    final snapshot = _basicSnapshot(age: 10, medicineCount: 1);
    final checker = const MedicineRiskChecker();
    final result = checker.evaluate(
      snapshot: snapshot,
      medicines: [
        MedicineRiskMedicineDetail(
          item: snapshot.currentMedicines[0],
          detail: _detail(id: 'cn-1', name: '药品', pediatricUse: '儿童慎用'),
        ),
      ],
    );

    final finding = result.findings.firstWhere(
      (f) => f.context == MedicineRiskFindingContext.pediatric,
    );
    expect(
      finding.specialPopulationConclusion,
      SpecialPopulationConclusion.caution,
    );
    expect(finding.severity, MedicineRiskSeverity.medium);
  });

  test('classifier maps "咨询医生" → consultClinician → medium', () {
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
            geriatricUse: '老年患者应在医生指导下使用',
          ),
        ),
      ],
    );

    final finding = result.findings.firstWhere(
      (f) => f.context == MedicineRiskFindingContext.geriatric,
    );
    expect(
      finding.specialPopulationConclusion,
      SpecialPopulationConclusion.consultClinician,
    );
    expect(finding.severity, MedicineRiskSeverity.medium);
  });

  test(
    'classifier maps unrecognized text → insufficientInformation → info',
    () {
      final snapshot = _basicSnapshot(age: 10, medicineCount: 1);
      final checker = const MedicineRiskChecker();
      final result = checker.evaluate(
        snapshot: snapshot,
        medicines: [
          MedicineRiskMedicineDetail(
            item: snapshot.currentMedicines[0],
            detail: _detail(id: 'cn-1', name: '药品', pediatricUse: '参见药品说明书'),
          ),
        ],
      );

      final finding = result.findings.firstWhere(
        (f) => f.context == MedicineRiskFindingContext.pediatric,
      );
      expect(
        finding.specialPopulationConclusion,
        SpecialPopulationConclusion.insufficientInformation,
      );
      expect(finding.severity, MedicineRiskSeverity.info);
    },
  );

  test(
    'classifier: first matching keyword tier wins (慎用 + 禁用 → contraindicated)',
    () {
      final snapshot = _basicSnapshot(age: 28, medicineCount: 1).copyWith(
        profile: _basicSnapshot(
          age: 28,
          medicineCount: 1,
        ).profile.copyWith(pregnancyState: 'pregnant', lactationState: 'no'),
      );
      final checker = const MedicineRiskChecker();
      final result = checker.evaluate(
        snapshot: snapshot,
        medicines: [
          MedicineRiskMedicineDetail(
            item: snapshot.currentMedicines[0],
            detail: _detail(id: 'cn-1', name: '药品', pregnancy: '慎用，严重者禁用'),
          ),
        ],
      );

      final finding = result.findings.firstWhere(
        (f) => f.context == MedicineRiskFindingContext.pregnancy,
      );
      // '禁用' is checked before '慎用' — strongest signal wins
      expect(
        finding.specialPopulationConclusion,
        SpecialPopulationConclusion.contraindicated,
      );
      expect(finding.severity, MedicineRiskSeverity.high);
    },
  );

  // ── Age threshold boundary tests ────────────────────────────────

  test('pediatric fires for age 17 and 18 (with field)', () {
    final snapshot17 = _basicSnapshot(age: 17, medicineCount: 1);
    final snapshot18 = _basicSnapshot(age: 18, medicineCount: 1);
    final detail = _detail(id: 'cn-1', name: '药品', pediatricUse: '儿童慎用');
    final checker = const MedicineRiskChecker();
    final result17 = checker.evaluate(
      snapshot: snapshot17,
      medicines: [
        MedicineRiskMedicineDetail(
          item: snapshot17.currentMedicines[0],
          detail: detail,
        ),
      ],
    );
    final result18 = checker.evaluate(
      snapshot: snapshot18,
      medicines: [
        MedicineRiskMedicineDetail(
          item: snapshot18.currentMedicines[0],
          detail: detail,
        ),
      ],
    );

    final pediatric17 = result17.findings.where(
      (f) =>
          f.type == MedicineRiskFindingType.specialGroup &&
          f.context == MedicineRiskFindingContext.pediatric,
    );
    expect(pediatric17, hasLength(1));
    expect(pediatric17.first.severity, MedicineRiskSeverity.medium);
    expect(pediatric17.first.evidence, '儿童慎用');

    final pediatric18 = result18.findings.where(
      (f) =>
          f.type == MedicineRiskFindingType.specialGroup &&
          f.context == MedicineRiskFindingContext.pediatric,
    );
    expect(pediatric18, hasLength(1));
    expect(pediatric18.first.severity, MedicineRiskSeverity.medium);
    expect(pediatric18.first.evidence, '儿童慎用');
  });

  test('pediatric info-level boundary fires for age <= 18 without field', () {
    final snapshot17 = _basicSnapshot(age: 17, medicineCount: 1);
    final snapshot18 = _basicSnapshot(age: 18, medicineCount: 1);
    final detail = _detail(id: 'cn-1', name: '药品'); // no pediatricUse
    final checker = const MedicineRiskChecker();
    final result17 = checker.evaluate(
      snapshot: snapshot17,
      medicines: [
        MedicineRiskMedicineDetail(
          item: snapshot17.currentMedicines[0],
          detail: detail,
        ),
      ],
    );
    final result18 = checker.evaluate(
      snapshot: snapshot18,
      medicines: [
        MedicineRiskMedicineDetail(
          item: snapshot18.currentMedicines[0],
          detail: detail,
        ),
      ],
    );

    final pediatric17 = result17.findings.where(
      (f) =>
          f.type == MedicineRiskFindingType.specialGroup &&
          f.context == MedicineRiskFindingContext.pediatric,
    );
    expect(pediatric17, hasLength(1));
    expect(pediatric17.first.severity, MedicineRiskSeverity.info);
    expect(pediatric17.first.evidence, isNull);

    final pediatric18 = result18.findings.where(
      (f) =>
          f.type == MedicineRiskFindingType.specialGroup &&
          f.context == MedicineRiskFindingContext.pediatric,
    );
    expect(pediatric18, hasLength(1));
    expect(pediatric18.first.severity, MedicineRiskSeverity.info);
    expect(pediatric18.first.evidence, isNull);
  });

  test('geriatric fires for age >= 65, not for age 64 (with field)', () {
    final snapshot64 = _basicSnapshot(age: 64, medicineCount: 1);
    final snapshot65 = _basicSnapshot(age: 65, medicineCount: 1);
    final snapshot66 = _basicSnapshot(age: 66, medicineCount: 1);
    final detail = _detail(id: 'cn-1', name: '药品', geriatricUse: '老人慎用');
    final checker = const MedicineRiskChecker();

    final result64 = checker.evaluate(
      snapshot: snapshot64,
      medicines: [
        MedicineRiskMedicineDetail(
          item: snapshot64.currentMedicines[0],
          detail: detail,
        ),
      ],
    );
    final result65 = checker.evaluate(
      snapshot: snapshot65,
      medicines: [
        MedicineRiskMedicineDetail(
          item: snapshot65.currentMedicines[0],
          detail: detail,
        ),
      ],
    );
    final result66 = checker.evaluate(
      snapshot: snapshot66,
      medicines: [
        MedicineRiskMedicineDetail(
          item: snapshot66.currentMedicines[0],
          detail: detail,
        ),
      ],
    );

    final geriatric64 = result64.findings.where(
      (f) =>
          f.type == MedicineRiskFindingType.specialGroup &&
          f.context == MedicineRiskFindingContext.geriatric,
    );
    expect(geriatric64, isEmpty);

    final geriatric65 = result65.findings.where(
      (f) =>
          f.type == MedicineRiskFindingType.specialGroup &&
          f.context == MedicineRiskFindingContext.geriatric,
    );
    expect(geriatric65, hasLength(1));
    expect(geriatric65.first.severity, MedicineRiskSeverity.medium);
    expect(geriatric65.first.evidence, '老人慎用');

    final geriatric66 = result66.findings.where(
      (f) =>
          f.type == MedicineRiskFindingType.specialGroup &&
          f.context == MedicineRiskFindingContext.geriatric,
    );
    expect(geriatric66, hasLength(1));
    expect(geriatric66.first.severity, MedicineRiskSeverity.medium);
    expect(geriatric66.first.evidence, '老人慎用');
  });

  test(
    'geriatric info-level boundary fires for age >= 65 without field, silent for age 64',
    () {
      final snapshot64 = _basicSnapshot(age: 64, medicineCount: 1);
      final snapshot65 = _basicSnapshot(age: 65, medicineCount: 1);
      final snapshot66 = _basicSnapshot(age: 66, medicineCount: 1);
      final detail = _detail(id: 'cn-1', name: '药品'); // no geriatricUse
      final checker = const MedicineRiskChecker();
      final result64 = checker.evaluate(
        snapshot: snapshot64,
        medicines: [
          MedicineRiskMedicineDetail(
            item: snapshot64.currentMedicines[0],
            detail: detail,
          ),
        ],
      );
      final result65 = checker.evaluate(
        snapshot: snapshot65,
        medicines: [
          MedicineRiskMedicineDetail(
            item: snapshot65.currentMedicines[0],
            detail: detail,
          ),
        ],
      );
      final result66 = checker.evaluate(
        snapshot: snapshot66,
        medicines: [
          MedicineRiskMedicineDetail(
            item: snapshot66.currentMedicines[0],
            detail: detail,
          ),
        ],
      );

      final geriatric64 = result64.findings.where(
        (f) =>
            f.type == MedicineRiskFindingType.specialGroup &&
            f.context == MedicineRiskFindingContext.geriatric,
      );
      expect(geriatric64, isEmpty);

      final geriatric65 = result65.findings.where(
        (f) =>
            f.type == MedicineRiskFindingType.specialGroup &&
            f.context == MedicineRiskFindingContext.geriatric,
      );
      expect(geriatric65, hasLength(1));
      expect(geriatric65.first.severity, MedicineRiskSeverity.info);
      expect(geriatric65.first.evidence, isNull);

      final geriatric66 = result66.findings.where(
        (f) =>
            f.type == MedicineRiskFindingType.specialGroup &&
            f.context == MedicineRiskFindingContext.geriatric,
      );
      expect(geriatric66, hasLength(1));
      expect(geriatric66.first.severity, MedicineRiskSeverity.info);
      expect(geriatric66.first.evidence, isNull);
    },
  );

  test(
    'age null silences both pediatric and geriatric even when field present',
    () {
      final snapshot = _basicSnapshot(age: 30, medicineCount: 1).copyWith(
        summary: HealthSummary(
          age: null, // no age available
          onboardingCompleted: true,
          activeAllergyCount: 0,
          conditionCount: 0,
          currentMedicineCount: 1,
          missingCoreProfileFields: [],
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
              pediatricUse: '儿童禁用',
              geriatricUse: '老人禁用',
            ),
          ),
        ],
      );

      final pediatricFindings = result.findings.where(
        (f) =>
            f.type == MedicineRiskFindingType.specialGroup &&
            f.context == MedicineRiskFindingContext.pediatric,
      );
      expect(pediatricFindings, isEmpty);

      final geriatricFindings = result.findings.where(
        (f) =>
            f.type == MedicineRiskFindingType.specialGroup &&
            f.context == MedicineRiskFindingContext.geriatric,
      );
      expect(geriatricFindings, isEmpty);
    },
  );

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
  List<String>? drugbankIds,
  String? pediatricUse,
  String? geriatricUse,
  String? pregnancy,
  String? lactation,
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
      pediatricUse: pediatricUse,
      geriatricUse: geriatricUse,
      pregnancy: pregnancy,
      lactation: lactation,
    ),
  );
}
