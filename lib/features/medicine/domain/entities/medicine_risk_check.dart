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
  });

  final MedicineRiskFindingType type;
  final MedicineRiskSeverity severity;
  final MedicineRiskFindingContext context;
  final String primaryMedicineName;
  final String? secondaryMedicineName;
  final String? relatedLabel;
  final String? evidence;
}

class MedicineRiskCoverageIssue {
  const MedicineRiskCoverageIssue({
    required this.medicineName,
    required this.reason,
  });

  final String medicineName;
  final MedicineRiskCoverageReason reason;
}

enum RedFlagRule {
  severeAllergy,
  pregnancyContraindication,
  informationGap,
}

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
