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

enum MedicineRiskFindingContext {
  none,
  pregnancy,
  lactation,
  pediatric,
  geriatric,
  alcohol,
  caffeine,
}

enum MedicineRiskCoverageReason {
  manualEntry,
  missingSourceRef,
  detailUnavailable,
}

/// Conservative structured conclusion for special-population risk text.
/// Classified via keyword matching — never via NLP.
/// Falls back to [insufficientInformation] when no confident keyword is found.
enum SpecialPopulationConclusion {
  /// Explicit contraindication (禁用 / contraindicated / 禁忌).
  contraindicated,

  /// Should avoid (避免使用 / avoid / not recommended).
  avoid,

  /// Use with caution (慎用 / caution / use with care).
  caution,

  /// Consult a clinician or pharmacist (咨询医生 / consult).
  consultClinician,

  /// Text exists but no keyword matched — cannot classify confidently.
  insufficientInformation,
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

    /// Non-null only when [type] is [MedicineRiskFindingType.specialGroup]
    /// and the source text was classified into a structured conclusion.
    /// Carries the classified risk level for UI two-layer display
    /// (conclusion label + evidence source text).
    SpecialPopulationConclusion? specialPopulationConclusion,
  }) = _MedicineRiskFinding;
}

@freezed
abstract class MedicineRiskCoverageIssue with _$MedicineRiskCoverageIssue {
  const factory MedicineRiskCoverageIssue({
    required String medicineName,
    required MedicineRiskCoverageReason reason,
  }) = _MedicineRiskCoverageIssue;
}

enum RedFlagRule { severeAllergy, pregnancyContraindication, informationGap }

@freezed
abstract class RedFlagAlert with _$RedFlagAlert {
  const factory RedFlagAlert({
    required RedFlagRule rule,
    required String primaryMedicineName,
    String? relatedLabel,

    /// Matches a support-resource id (e.g. 'campus-emergency', 'campus-hospital').
    String? resourceId,
  }) = _RedFlagAlert;
}
