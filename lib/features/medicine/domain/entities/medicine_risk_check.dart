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

class MedicineRiskCheckResult {
  const MedicineRiskCheckResult({
    required this.currentMedicineCount,
    required this.checkedMedicineCount,
    required this.findings,
    required this.coverageIssues,
    this.coverageSummary = '',
  });

  final int currentMedicineCount;
  final int checkedMedicineCount;
  final List<MedicineRiskFinding> findings;
  final List<MedicineRiskCoverageIssue> coverageIssues;

  /// Human-readable summary of coverage gaps (e.g. "2 种手动录入药品无法自动检查").
  /// Empty when all medicines are fully covered.
  final String coverageSummary;

  int get findingCount => findings.length;

  int get coverageCount => coverageIssues.length;

  bool get hasFindings => findings.isNotEmpty;

  bool get hasCoverageGaps => coverageIssues.isNotEmpty;
}

class MedicineRiskFinding {
  const MedicineRiskFinding({
    required this.type,
    required this.severity,
    required this.context,
    required this.primaryMedicineName,
    this.secondaryMedicineName,
    this.relatedLabel,
    this.evidence,
    this.specialPopulationConclusion,
  });

  final MedicineRiskFindingType type;
  final MedicineRiskSeverity severity;
  final MedicineRiskFindingContext context;
  final String primaryMedicineName;
  final String? secondaryMedicineName;
  final String? relatedLabel;
  final String? evidence;

  /// Non-null only when [type] is [MedicineRiskFindingType.specialGroup]
  /// and the source text was classified into a structured conclusion.
  /// Carries the classified risk level for UI two-layer display
  /// (conclusion label + evidence source text).
  final SpecialPopulationConclusion? specialPopulationConclusion;
}

class MedicineRiskCoverageIssue {
  const MedicineRiskCoverageIssue({
    required this.medicineName,
    required this.reason,
  });

  final String medicineName;
  final MedicineRiskCoverageReason reason;
}

enum RedFlagRule { severeAllergy, pregnancyContraindication, informationGap }

class RedFlagAlert {
  const RedFlagAlert({
    required this.rule,
    required this.primaryMedicineName,
    this.relatedLabel,
    this.resourceId,
  });

  final RedFlagRule rule;
  final String primaryMedicineName;
  final String? relatedLabel;

  /// Matches a support-resource id (e.g. 'campus-emergency', 'campus-hospital').
  final String? resourceId;
}
