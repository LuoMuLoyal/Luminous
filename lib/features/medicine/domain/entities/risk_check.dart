import 'package:freezed_annotation/freezed_annotation.dart';

part 'risk_check.freezed.dart';

// ─── Enums ──────────────────────────────────────────────────────────────────

enum MedicineRiskLevel { safe, caution, risk, danger }

enum MedicineRiskSeverity { high, medium, info }

enum MedicineRiskFindingType {
  interaction,
  duplicateIngredient,
  allergy,
  foodInteraction,
  longTermUse,
  schedulingConflict,
  specialGroup,
}

enum MedicineRiskFindingContext { none, alcohol, caffeine }

enum MedicineRiskCoverageReason {
  manualEntry,
  missingSourceRef,
  detailUnavailable,
}

enum RedFlagRule { severeAllergy, informationGap }

enum MedicineRiskCheckType { static_, llm }

// ─── Findings ────────────────────────────────────────────────────────────────

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
    String? recommendation,
  }) = _MedicineRiskFinding;
}

@freezed
abstract class MedicineRiskCoverageIssue with _$MedicineRiskCoverageIssue {
  const factory MedicineRiskCoverageIssue({
    required String medicineName,
    required MedicineRiskCoverageReason reason,
  }) = _MedicineRiskCoverageIssue;
}

@freezed
abstract class RedFlagAlert with _$RedFlagAlert {
  const factory RedFlagAlert({
    required RedFlagRule rule,
    required String primaryMedicineName,
    String? relatedLabel,
  }) = _RedFlagAlert;
}

// ─── Check result ────────────────────────────────────────────────────────────

@freezed
abstract class MedicineRiskCheckResult with _$MedicineRiskCheckResult {
  const MedicineRiskCheckResult._();

  const factory MedicineRiskCheckResult({
    @Default(MedicineRiskLevel.safe) MedicineRiskLevel overallRiskLevel,
    @Default(0) int overallRiskScore,
    @Default(0) int currentMedicineCount,
    @Default(0) int checkedMedicineCount,
    @Default([]) List<MedicineRiskFinding> findings,
    @Default([]) List<MedicineRiskCoverageIssue> coverageIssues,
    @Default([]) List<RedFlagAlert> redFlags,
    String? overallRecommendation,
  }) = _MedicineRiskCheckResult;

  int get findingCount => findings.length;
  int get coverageCount => coverageIssues.length;
  bool get hasFindings => findings.isNotEmpty;
  bool get hasCoverageGaps => coverageIssues.isNotEmpty;
  bool get hasRedFlags => redFlags.isNotEmpty;
}

// ─── Check record (wraps result with metadata) ───────────────────────────────

@freezed
abstract class MedicineRiskCheckRecord with _$MedicineRiskCheckRecord {
  const factory MedicineRiskCheckRecord({
    required MedicineRiskCheckType checkType,
    required MedicineRiskCheckResult result,
    required int riskScore,
    required MedicineRiskLevel riskLevel,
    required bool stale,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _MedicineRiskCheckRecord;
}

// ─── Records pair (static + llm) ──────────────────────────────────────────────

@freezed
abstract class MedicineRiskCheckRecords with _$MedicineRiskCheckRecords {
  const MedicineRiskCheckRecords._();

  const factory MedicineRiskCheckRecords({
    MedicineRiskCheckRecord? staticRecord,
    MedicineRiskCheckRecord? llmRecord,
  }) = _MedicineRiskCheckRecords;

  /// The "best" record to show: LLM if available, else static, else null.
  MedicineRiskCheckRecord? get bestRecord => llmRecord ?? staticRecord;

  /// True if the best available record is marked stale.
  bool get isStale => bestRecord?.stale ?? false;

  /// True if there are no records at all.
  bool get isEmpty => staticRecord == null && llmRecord == null;
}
