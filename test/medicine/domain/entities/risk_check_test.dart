import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/medicine/domain/entities/risk_check.dart';

void main() {
  group('MedicineRiskCheckResult computed getters', () {
    test('findingCount returns findings length', () {
      const result = MedicineRiskCheckResult(
        currentMedicineCount: 3,
        checkedMedicineCount: 2,
        findings: [
          MedicineRiskFinding(
            type: MedicineRiskFindingType.interaction,
            severity: MedicineRiskSeverity.high,
            context: MedicineRiskFindingContext.none,
            primaryMedicineName: 'Med A',
          ),
          MedicineRiskFinding(
            type: MedicineRiskFindingType.allergy,
            severity: MedicineRiskSeverity.medium,
            context: MedicineRiskFindingContext.none,
            primaryMedicineName: 'Med B',
          ),
        ],
        coverageIssues: [],
      );

      expect(result.findingCount, 2);
      expect(result.hasFindings, isTrue);
    });

    test('hasFindings is false when findings is empty', () {
      const result = MedicineRiskCheckResult(
        currentMedicineCount: 0,
        checkedMedicineCount: 0,
        findings: [],
        coverageIssues: [],
      );

      expect(result.hasFindings, isFalse);
      expect(result.findingCount, 0);
    });

    test('coverageCount returns coverageIssues length', () {
      const result = MedicineRiskCheckResult(
        currentMedicineCount: 3,
        checkedMedicineCount: 1,
        findings: [],
        coverageIssues: [
          MedicineRiskCoverageIssue(
            medicineName: 'Med C',
            reason: MedicineRiskCoverageReason.manualEntry,
          ),
          MedicineRiskCoverageIssue(
            medicineName: 'Med D',
            reason: MedicineRiskCoverageReason.missingSourceRef,
          ),
        ],
      );

      expect(result.coverageCount, 2);
      expect(result.hasCoverageGaps, isTrue);
    });

    test('hasCoverageGaps is false when coverageIssues is empty', () {
      const result = MedicineRiskCheckResult(
        currentMedicineCount: 2,
        checkedMedicineCount: 2,
        findings: [],
        coverageIssues: [],
      );

      expect(result.hasCoverageGaps, isFalse);
      expect(result.coverageCount, 0);
    });

    test('coverageSummary defaults to empty string', () {
      const result = MedicineRiskCheckResult(
        currentMedicineCount: 0,
        checkedMedicineCount: 0,
        findings: [],
        coverageIssues: [],
      );

      expect(result.coverageSummary, '');
    });

    test('coverageSummary can be set to a non-empty value', () {
      const result = MedicineRiskCheckResult(
        currentMedicineCount: 3,
        checkedMedicineCount: 2,
        findings: [],
        coverageIssues: [],
        coverageSummary: '2 of 3 medicines checked',
      );

      expect(result.coverageSummary, '2 of 3 medicines checked');
    });

    test('both hasFindings and hasCoverageGaps can be true simultaneously', () {
      const result = MedicineRiskCheckResult(
        currentMedicineCount: 3,
        checkedMedicineCount: 1,
        findings: [
          MedicineRiskFinding(
            type: MedicineRiskFindingType.interaction,
            severity: MedicineRiskSeverity.high,
            context: MedicineRiskFindingContext.none,
            primaryMedicineName: 'Med A',
          ),
        ],
        coverageIssues: [
          MedicineRiskCoverageIssue(
            medicineName: 'Med C',
            reason: MedicineRiskCoverageReason.detailUnavailable,
          ),
        ],
      );

      expect(result.hasFindings, isTrue);
      expect(result.hasCoverageGaps, isTrue);
    });
  });

  group('MedicineRiskFinding', () {
    test('can be constructed with all fields', () {
      const finding = MedicineRiskFinding(
        type: MedicineRiskFindingType.duplicateIngredient,
        severity: MedicineRiskSeverity.medium,
        context: MedicineRiskFindingContext.none,
        primaryMedicineName: 'Aspirin',
        secondaryMedicineName: 'Ecotrin',
        relatedLabel: 'Acetylsalicylic acid',
        evidence: 'Both contain ASA',
      );

      expect(finding.type, MedicineRiskFindingType.duplicateIngredient);
      expect(finding.severity, MedicineRiskSeverity.medium);
      expect(finding.primaryMedicineName, 'Aspirin');
      expect(finding.secondaryMedicineName, 'Ecotrin');
      expect(finding.relatedLabel, 'Acetylsalicylic acid');
      expect(finding.evidence, 'Both contain ASA');
    });

    test('optional fields default to null', () {
      const finding = MedicineRiskFinding(
        type: MedicineRiskFindingType.foodInteraction,
        severity: MedicineRiskSeverity.info,
        context: MedicineRiskFindingContext.alcohol,
        primaryMedicineName: 'Metronidazole',
      );

      expect(finding.secondaryMedicineName, isNull);
      expect(finding.relatedLabel, isNull);
      expect(finding.evidence, isNull);
    });
  });

  group('MedicineRiskCoverageIssue', () {
    test('can be constructed with required fields', () {
      const issue = MedicineRiskCoverageIssue(
        medicineName: 'Unknown Med',
        reason: MedicineRiskCoverageReason.manualEntry,
      );

      expect(issue.medicineName, 'Unknown Med');
      expect(issue.reason, MedicineRiskCoverageReason.manualEntry);
    });
  });

  group('RedFlagAlert', () {
    test('can be constructed with required fields', () {
      const alert = RedFlagAlert(
        rule: RedFlagRule.severeAllergy,
        primaryMedicineName: 'Penicillin',
      );

      expect(alert.rule, RedFlagRule.severeAllergy);
      expect(alert.primaryMedicineName, 'Penicillin');
      expect(alert.relatedLabel, isNull);
    });

    test('can be constructed with relatedLabel', () {
      const alert = RedFlagAlert(
        rule: RedFlagRule.informationGap,
        primaryMedicineName: 'Med X',
        relatedLabel: 'Missing interaction data',
      );

      expect(alert.rule, RedFlagRule.informationGap);
      expect(alert.relatedLabel, 'Missing interaction data');
    });
  });

  group('Enum completeness', () {
    test('MedicineRiskSeverity contains expected values', () {
      expect(
        MedicineRiskSeverity.values,
        containsAll([
          MedicineRiskSeverity.high,
          MedicineRiskSeverity.medium,
          MedicineRiskSeverity.info,
        ]),
      );
    });

    test('MedicineRiskFindingType contains expected values', () {
      expect(
        MedicineRiskFindingType.values,
        containsAll([
          MedicineRiskFindingType.interaction,
          MedicineRiskFindingType.allergy,
          MedicineRiskFindingType.duplicateIngredient,
          MedicineRiskFindingType.foodInteraction,
          MedicineRiskFindingType.specialGroup,
        ]),
      );
    });

    test('MedicineRiskFindingContext contains expected values', () {
      expect(
        MedicineRiskFindingContext.values,
        containsAll([
          MedicineRiskFindingContext.none,
          MedicineRiskFindingContext.alcohol,
          MedicineRiskFindingContext.caffeine,
        ]),
      );
    });

    test('MedicineRiskCoverageReason contains expected values', () {
      expect(
        MedicineRiskCoverageReason.values,
        containsAll([
          MedicineRiskCoverageReason.manualEntry,
          MedicineRiskCoverageReason.missingSourceRef,
          MedicineRiskCoverageReason.detailUnavailable,
        ]),
      );
    });

    test('RedFlagRule contains expected values', () {
      expect(
        RedFlagRule.values,
        containsAll([RedFlagRule.severeAllergy, RedFlagRule.informationGap]),
      );
    });
  });
}
