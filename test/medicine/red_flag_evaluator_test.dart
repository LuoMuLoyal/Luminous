import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/health_context/domain/entities/health_context_snapshot.dart';
import 'package:luminous/features/medicine/domain/entities/medicine_risk_check.dart';
import 'package:luminous/features/medicine/domain/services/red_flag_evaluator.dart';

void main() {
  test('Rule 1: severe allergy match triggers red flag', () {
    final snapshot = HealthContextSnapshot(
      summary: HealthSummary(
        age: 30,
        onboardingCompleted: true,
        activeAllergyCount: 2,
        conditionCount: 0,
        currentMedicineCount: 1,
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
          id: 'a1',
          kind: 'drug',
          label: '青霉素',
          reaction: 'anaphylaxis',
          severity: 'severe',
          isActive: true,
          note: null,
          createdAt: '2026-01-01T00:00:00.000Z',
          updatedAt: '2026-01-01T00:00:00.000Z',
        ),
        AllergyItem(
          id: 'a2',
          kind: 'food',
          label: '花生',
          reaction: null,
          severity: 'mild',
          isActive: true,
          note: null,
          createdAt: '2026-01-01T00:00:00.000Z',
          updatedAt: '2026-01-01T00:00:00.000Z',
        ),
      ],
      conditions: [],
      currentMedicines: [
        CurrentMedicineItem(
          id: 'm1',
          source: 'cn',
          sourceRefId: 'cn-1',
          displayName: '阿莫西林',
          strengthText: null,
          doseText: null,
          route: null,
          startedAt: null,
          endedAt: null,
          isCurrent: true,
          note: null,
          createdAt: '2026-01-01T00:00:00.000Z',
          updatedAt: '2026-01-01T00:00:00.000Z',
        ),
      ],
    );

    final result = MedicineRiskCheckResult(
      currentMedicineCount: 1,
      checkedMedicineCount: 1,
      findings: [
        MedicineRiskFinding(
          type: MedicineRiskFindingType.allergy,
          severity: MedicineRiskSeverity.high,
          context: MedicineRiskFindingContext.none,
          primaryMedicineName: '阿莫西林',
          relatedLabel: '青霉素',
          evidence: '含青霉素成分',
        ),
      ],
      coverageIssues: [],
    );

    final evaluator = const RedFlagEvaluator();
    final alerts = evaluator.evaluate(snapshot: snapshot, result: result);

    expect(alerts, hasLength(1));
    expect(alerts.first.rule, RedFlagRule.severeAllergy);
    expect(alerts.first.primaryMedicineName, '阿莫西林');
    expect(alerts.first.resourceId, 'campus-emergency');
  });

  test('Rule 1: mild allergy does NOT trigger red flag', () {
    final snapshot = HealthContextSnapshot(
      summary: HealthSummary(
        age: 30,
        onboardingCompleted: true,
        activeAllergyCount: 1,
        conditionCount: 0,
        currentMedicineCount: 1,
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
          id: 'a1',
          kind: 'drug',
          label: '青霉素',
          reaction: null,
          severity: 'mild',
          isActive: true,
          note: null,
          createdAt: '2026-01-01T00:00:00.000Z',
          updatedAt: '2026-01-01T00:00:00.000Z',
        ),
      ],
      conditions: [],
      currentMedicines: [
        CurrentMedicineItem(
          id: 'm1',
          source: 'cn',
          sourceRefId: 'cn-1',
          displayName: '阿莫西林',
          strengthText: null,
          doseText: null,
          route: null,
          startedAt: null,
          endedAt: null,
          isCurrent: true,
          note: null,
          createdAt: '2026-01-01T00:00:00.000Z',
          updatedAt: '2026-01-01T00:00:00.000Z',
        ),
      ],
    );

    final result = MedicineRiskCheckResult(
      currentMedicineCount: 1,
      checkedMedicineCount: 1,
      findings: [
        MedicineRiskFinding(
          type: MedicineRiskFindingType.allergy,
          severity: MedicineRiskSeverity.high,
          context: MedicineRiskFindingContext.none,
          primaryMedicineName: '阿莫西林',
          relatedLabel: '青霉素',
          evidence: '含青霉素成分',
        ),
      ],
      coverageIssues: [],
    );

    final evaluator = const RedFlagEvaluator();
    final alerts = evaluator.evaluate(snapshot: snapshot, result: result);

    expect(alerts, isEmpty);
  });

  test(
    'Rule 1: missing severity with anaphylaxis reaction still triggers red flag',
    () {
      final snapshot = HealthContextSnapshot(
        summary: HealthSummary(
          age: 30,
          onboardingCompleted: true,
          activeAllergyCount: 1,
          conditionCount: 0,
          currentMedicineCount: 1,
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
            id: 'a1',
            kind: 'drug',
            label: '青霉素',
            reaction: 'anaphylactic shock',
            severity: null,
            isActive: true,
            note: null,
            createdAt: '2026-01-01T00:00:00.000Z',
            updatedAt: '2026-01-01T00:00:00.000Z',
          ),
        ],
        conditions: [],
        currentMedicines: [
          CurrentMedicineItem(
            id: 'm1',
            source: 'cn',
            sourceRefId: 'cn-1',
            displayName: '阿莫西林',
            strengthText: null,
            doseText: null,
            route: null,
            startedAt: null,
            endedAt: null,
            isCurrent: true,
            note: null,
            createdAt: '2026-01-01T00:00:00.000Z',
            updatedAt: '2026-01-01T00:00:00.000Z',
          ),
        ],
      );

      final result = MedicineRiskCheckResult(
        currentMedicineCount: 1,
        checkedMedicineCount: 1,
        findings: [
          MedicineRiskFinding(
            type: MedicineRiskFindingType.allergy,
            severity: MedicineRiskSeverity.high,
            context: MedicineRiskFindingContext.none,
            primaryMedicineName: '阿莫西林',
            relatedLabel: '青霉素',
            evidence: '含青霉素成分',
          ),
        ],
        coverageIssues: [],
      );

      final evaluator = const RedFlagEvaluator();
      final alerts = evaluator.evaluate(snapshot: snapshot, result: result);

      expect(alerts, hasLength(1));
      expect(alerts.first.rule, RedFlagRule.severeAllergy);
    },
  );

  test('Rule 3: information gap for high-risk user triggers red flag', () {
    final snapshot = HealthContextSnapshot(
      summary: HealthSummary(
        age: 28,
        onboardingCompleted: true,
        activeAllergyCount: 1,
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
      allergies: [
        AllergyItem(
          id: 'a1',
          kind: 'drug',
          label: '青霉素',
          reaction: 'anaphylaxis',
          severity: 'severe',
          isActive: true,
          note: null,
          createdAt: '2026-01-01T00:00:00.000Z',
          updatedAt: '2026-01-01T00:00:00.000Z',
        ),
      ],
      conditions: [],
      currentMedicines: [
        CurrentMedicineItem(
          id: 'm1',
          source: 'cn',
          sourceRefId: 'cn-1',
          displayName: '某中药',
          strengthText: null,
          doseText: null,
          route: null,
          startedAt: null,
          endedAt: null,
          isCurrent: true,
          note: null,
          createdAt: '2026-01-01T00:00:00.000Z',
          updatedAt: '2026-01-01T00:00:00.000Z',
        ),
        CurrentMedicineItem(
          id: 'm2',
          source: 'manual',
          sourceRefId: null,
          displayName: '自备药',
          strengthText: null,
          doseText: null,
          route: null,
          startedAt: null,
          endedAt: null,
          isCurrent: true,
          note: null,
          createdAt: '2026-01-01T00:00:00.000Z',
          updatedAt: '2026-01-01T00:00:00.000Z',
        ),
      ],
    );

    final result = MedicineRiskCheckResult(
      currentMedicineCount: 2,
      checkedMedicineCount: 1,
      findings: [],
      coverageIssues: [
        MedicineRiskCoverageIssue(
          medicineName: '自备药',
          reason: MedicineRiskCoverageReason.manualEntry,
        ),
      ],
    );

    final evaluator = const RedFlagEvaluator();
    final alerts = evaluator.evaluate(snapshot: snapshot, result: result);

    expect(alerts, hasLength(1));
    expect(alerts.first.rule, RedFlagRule.informationGap);
    expect(alerts.first.resourceId, isNull);
  });

  test('Rule 3: no red flag for low-risk user with coverage gaps', () {
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
      conditions: [],
      currentMedicines: [
        CurrentMedicineItem(
          id: 'm1',
          source: 'manual',
          sourceRefId: null,
          displayName: '自备药',
          strengthText: null,
          doseText: null,
          route: null,
          startedAt: null,
          endedAt: null,
          isCurrent: true,
          note: null,
          createdAt: '2026-01-01T00:00:00.000Z',
          updatedAt: '2026-01-01T00:00:00.000Z',
        ),
      ],
    );

    final result = MedicineRiskCheckResult(
      currentMedicineCount: 1,
      checkedMedicineCount: 0,
      findings: [],
      coverageIssues: [
        MedicineRiskCoverageIssue(
          medicineName: '自备药',
          reason: MedicineRiskCoverageReason.manualEntry,
        ),
      ],
    );

    final evaluator = const RedFlagEvaluator();
    final alerts = evaluator.evaluate(snapshot: snapshot, result: result);

    expect(alerts, isEmpty);
  });
}
