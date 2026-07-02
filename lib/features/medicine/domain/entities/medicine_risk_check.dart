import 'package:freezed_annotation/freezed_annotation.dart';

part 'medicine_risk_check.freezed.dart';

enum MedicineRiskSeverity { high, medium, info }

enum MedicineRiskFindingType {
  interaction,
  duplicateIngredient,
  allergy,
  specialGroup,
  foodInteraction,
}

enum MedicineRiskFindingContext { none, alcohol, caffeine }

enum MedicineRiskCoverageReason {
  manualEntry,
  missingSourceRef,
  detailUnavailable,
}

@freezed
abstract class MedicineRiskCheckResult with _$MedicineRiskCheckResult {
  const MedicineRiskCheckResult._();

  const factory MedicineRiskCheckResult({
    required int currentMedicineCount,
    required int checkedMedicineCount,
    required List<MedicineRiskFinding> findings,
    required List<MedicineRiskCoverageIssue> coverageIssues,
    @Default('') String coverageSummary,
  }) = _MedicineRiskCheckResult;

  int get findingCount => findings.length;
  int get coverageCount => coverageIssues.length;
  bool get hasFindings => findings.isNotEmpty;
  bool get hasCoverageGaps => coverageIssues.isNotEmpty;
}

@freezed
abstract class MedicineRiskFinding with _$MedicineRiskFinding {
  const factory MedicineRiskFinding({
    required MedicineRiskFindingType type,
    required MedicineRiskSeverity severity,
    required MedicineRiskFindingContext context,
    required String primaryMedicineName,
    String? secondaryMedicineName,
    String? relatedLabel,
    String? evidence,
  }) = _MedicineRiskFinding;
}

@freezed
abstract class MedicineRiskCoverageIssue with _$MedicineRiskCoverageIssue {
  const factory MedicineRiskCoverageIssue({
    required String medicineName,
    required MedicineRiskCoverageReason reason,
  }) = _MedicineRiskCoverageIssue;
}

enum RedFlagRule { severeAllergy, informationGap }

@freezed
abstract class RedFlagAlert with _$RedFlagAlert {
  const factory RedFlagAlert({
    required RedFlagRule rule,
    required String primaryMedicineName,
    String? relatedLabel,
  }) = _RedFlagAlert;
}
