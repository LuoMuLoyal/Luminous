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
  });

  final int currentMedicineCount;
  final int checkedMedicineCount;
  final List<MedicineRiskFinding> findings;
  final List<MedicineRiskCoverageIssue> coverageIssues;

  int get findingCount => findings.length;

  int get coverageCount => coverageIssues.length;

  bool get hasFindings => findings.isNotEmpty;
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
