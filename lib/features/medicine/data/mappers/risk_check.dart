import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/features/medicine/domain/entities/risk_check.dart';

/// Maps generated OpenAPI DTOs to domain entities for the risk check feature.
class MedicineRiskCheckMapper {
  const MedicineRiskCheckMapper();

  MedicineRiskCheckRecords recordsDtoToDomain(
    MedicineRiskCheckRecordsResponseDto dto,
  ) {
    return MedicineRiskCheckRecords(
      staticRecord: dto.static_ != null
          ? recordDtoToDomain(
              MedicineRiskCheckRecordResponseDto.fromJson(
                dto.static_!.toJson(),
              ),
            )
          : null,
      llmRecord: dto.llm == null
          ? null
          : recordDtoToDomain(
              MedicineRiskCheckRecordResponseDto.fromJson(dto.llm!.toJson()),
            ),
    );
  }

  MedicineRiskCheckRecord recordDtoToDomain(
    MedicineRiskCheckRecordResponseDto dto,
  ) {
    return MedicineRiskCheckRecord(
      checkType: _mapCheckType(dto.checkType),
      result: responseDtoToDomain(dto.result),
      riskScore: dto.riskScore.toInt(),
      riskLevel: _mapRiskLevelFromRecord(dto.riskLevel),
      stale: dto.stale,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }

  MedicineRiskCheckResult responseDtoToDomain(
    MedicineRiskCheckResponseDto dto,
  ) {
    return MedicineRiskCheckResult(
      overallRiskLevel: _mapRiskLevel(dto.overallRiskLevel),
      overallRiskScore: dto.overallRiskScore.toInt(),
      currentMedicineCount: dto.currentMedicineCount.toInt(),
      checkedMedicineCount: dto.checkedMedicineCount.toInt(),
      findings: dto.findings
          .map(findingDtoToDomain)
          .whereType<MedicineRiskFinding>()
          .toList(),
      coverageIssues: dto.coverageIssues.map(coverageIssueDtoToDomain).toList(),
      redFlags: dto.redFlags.map(redFlagDtoToDomain).toList(),
      overallRecommendation: dto.overallRecommendation,
    );
  }

  MedicineRiskFinding? findingDtoToDomain(MedicineRiskFindingDto dto) {
    final type = _mapFindingType(dto.type);
    if (type == null) {
      return null;
    }
    return MedicineRiskFinding(
      type: type,
      severity: _mapSeverity(dto.severity),
      context: _mapFindingContext(dto.context),
      primaryMedicineName: dto.primaryMedicineName,
      secondaryMedicineName: dto.secondaryMedicineName,
      relatedLabel: dto.relatedLabel,
      evidence: dto.evidence,
      recommendation: dto.recommendation,
    );
  }

  MedicineRiskCoverageIssue coverageIssueDtoToDomain(
    MedicineRiskCoverageIssueDto dto,
  ) {
    return MedicineRiskCoverageIssue(
      medicineName: dto.medicineName,
      reason: _mapCoverageReason(dto.reason),
    );
  }

  RedFlagAlert redFlagDtoToDomain(MedicineRedFlagDto dto) {
    return RedFlagAlert(
      rule: _mapRedFlagRule(dto.rule),
      primaryMedicineName: dto.primaryMedicineName,
      relatedLabel: dto.relatedLabel,
    );
  }

  RunRiskCheckDto checkTypeToDto(MedicineRiskCheckType type) {
    return RunRiskCheckDto(
      type: switch (type) {
        MedicineRiskCheckType.static_ => RunRiskCheckDtoTypeEnum.static_,
        MedicineRiskCheckType.llm => RunRiskCheckDtoTypeEnum.llm,
      },
    );
  }

  /// Builds the static precheck request DTO for a candidate medicine from a
  /// trusted drug-library source ('cn' / 'drugbank'). The server checks the
  /// current box plus this candidate without persisting a record.
  RunRiskCheckDto precheckToDto({
    required String source,
    required String sourceRefId,
  }) {
    return RunRiskCheckDto(
      type: RunRiskCheckDtoTypeEnum.static_,
      candidate: RiskCheckCandidateDto(
        source_: _mapCandidateSource(source),
        id: sourceRefId,
      ),
    );
  }

  // ─── Enum mappers ────────────────────────────────────────────────────────

  MedicineRiskLevel _mapRiskLevel(
    MedicineRiskCheckResponseDtoOverallRiskLevelEnum level,
  ) {
    return switch (level) {
      MedicineRiskCheckResponseDtoOverallRiskLevelEnum.safe =>
        MedicineRiskLevel.safe,
      MedicineRiskCheckResponseDtoOverallRiskLevelEnum.caution =>
        MedicineRiskLevel.caution,
      MedicineRiskCheckResponseDtoOverallRiskLevelEnum.risk =>
        MedicineRiskLevel.risk,
      MedicineRiskCheckResponseDtoOverallRiskLevelEnum.danger =>
        MedicineRiskLevel.danger,
      _ => MedicineRiskLevel.safe,
    };
  }

  MedicineRiskLevel _mapRiskLevelFromRecord(
    MedicineRiskCheckRecordResponseDtoRiskLevelEnum level,
  ) {
    return switch (level) {
      MedicineRiskCheckRecordResponseDtoRiskLevelEnum.safe =>
        MedicineRiskLevel.safe,
      MedicineRiskCheckRecordResponseDtoRiskLevelEnum.caution =>
        MedicineRiskLevel.caution,
      MedicineRiskCheckRecordResponseDtoRiskLevelEnum.risk =>
        MedicineRiskLevel.risk,
      MedicineRiskCheckRecordResponseDtoRiskLevelEnum.danger =>
        MedicineRiskLevel.danger,
      _ => MedicineRiskLevel.safe,
    };
  }

  MedicineRiskCheckType _mapCheckType(
    MedicineRiskCheckRecordResponseDtoCheckTypeEnum type,
  ) {
    return switch (type) {
      MedicineRiskCheckRecordResponseDtoCheckTypeEnum.static_ =>
        MedicineRiskCheckType.static_,
      MedicineRiskCheckRecordResponseDtoCheckTypeEnum.llm =>
        MedicineRiskCheckType.llm,
      _ => MedicineRiskCheckType.static_,
    };
  }

  RiskCheckCandidateDtoSource_Enum _mapCandidateSource(String source) {
    return switch (source) {
      'cn' => RiskCheckCandidateDtoSource_Enum.cn,
      'drugbank' => RiskCheckCandidateDtoSource_Enum.drugbank,
      // Unknown sources are rejected by the server; the precheck failure path
      // is non-blocking by design.
      _ => RiskCheckCandidateDtoSource_Enum.unknownDefaultOpenApi,
    };
  }

  MedicineRiskFindingType? _mapFindingType(
    MedicineRiskFindingDtoTypeEnum type,
  ) {
    return switch (type) {
      MedicineRiskFindingDtoTypeEnum.interaction =>
        MedicineRiskFindingType.interaction,
      MedicineRiskFindingDtoTypeEnum.duplicateIngredient =>
        MedicineRiskFindingType.duplicateIngredient,
      MedicineRiskFindingDtoTypeEnum.allergy => MedicineRiskFindingType.allergy,
      MedicineRiskFindingDtoTypeEnum.foodInteraction =>
        MedicineRiskFindingType.foodInteraction,
      MedicineRiskFindingDtoTypeEnum.longTermUse =>
        MedicineRiskFindingType.longTermUse,
      MedicineRiskFindingDtoTypeEnum.schedulingConflict =>
        MedicineRiskFindingType.schedulingConflict,
      MedicineRiskFindingDtoTypeEnum.specialGroup =>
        MedicineRiskFindingType.specialGroup,
      _ => null,
    };
  }

  MedicineRiskSeverity _mapSeverity(
    MedicineRiskFindingDtoSeverityEnum severity,
  ) {
    return switch (severity) {
      MedicineRiskFindingDtoSeverityEnum.high => MedicineRiskSeverity.high,
      MedicineRiskFindingDtoSeverityEnum.medium => MedicineRiskSeverity.medium,
      MedicineRiskFindingDtoSeverityEnum.info => MedicineRiskSeverity.info,
      _ => MedicineRiskSeverity.info,
    };
  }

  MedicineRiskFindingContext _mapFindingContext(
    MedicineRiskFindingDtoContextEnum context,
  ) {
    return switch (context) {
      MedicineRiskFindingDtoContextEnum.none => MedicineRiskFindingContext.none,
      MedicineRiskFindingDtoContextEnum.alcohol =>
        MedicineRiskFindingContext.alcohol,
      MedicineRiskFindingDtoContextEnum.caffeine =>
        MedicineRiskFindingContext.caffeine,
      _ => MedicineRiskFindingContext.none,
    };
  }

  MedicineRiskCoverageReason _mapCoverageReason(
    MedicineRiskCoverageIssueDtoReasonEnum reason,
  ) {
    return switch (reason) {
      MedicineRiskCoverageIssueDtoReasonEnum.manualEntry =>
        MedicineRiskCoverageReason.manualEntry,
      MedicineRiskCoverageIssueDtoReasonEnum.missingSourceRef =>
        MedicineRiskCoverageReason.missingSourceRef,
      MedicineRiskCoverageIssueDtoReasonEnum.detailUnavailable =>
        MedicineRiskCoverageReason.detailUnavailable,
      _ => MedicineRiskCoverageReason.detailUnavailable,
    };
  }

  RedFlagRule _mapRedFlagRule(MedicineRedFlagDtoRuleEnum rule) {
    return switch (rule) {
      MedicineRedFlagDtoRuleEnum.severeAllergy => RedFlagRule.severeAllergy,
      MedicineRedFlagDtoRuleEnum.informationGap => RedFlagRule.informationGap,
      _ => RedFlagRule.informationGap,
    };
  }
}
