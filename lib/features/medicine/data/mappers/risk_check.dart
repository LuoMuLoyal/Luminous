import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/features/medicine/domain/entities/risk_check.dart';

/// Maps generated OpenAPI DTOs to domain entities for the risk check feature.
///
/// 响应侧 zod 再生成后,record 载荷由 per-op DTO 表达:list records 的
/// `static`/`llm` 槽位是 `MedicineRiskCheckRecordsResponseDtoStatic`,
/// run-check/precheck 单条响应是 `MedicineRiskCheckRecordResponseDto`,
/// 两者字段布局相同且 `result` 共用
/// `MedicineRiskCheckRecordsResponseDtoStaticResult`。
class MedicineRiskCheckMapper {
  const MedicineRiskCheckMapper();

  MedicineRiskCheckRecords recordsDtoToDomain(
    MedicineRiskCheckRecordsResponseDto dto,
  ) {
    return MedicineRiskCheckRecords(
      staticRecord: dto.static_ == null
          ? null
          : _listRecordToDomain(dto.static_!),
      llmRecord: dto.llm == null ? null : _listRecordToDomain(dto.llm!),
    );
  }

  MedicineRiskCheckRecord recordDtoToDomain(
    MedicineRiskCheckRecordResponseDto dto,
  ) {
    return _record(
      checkType: _mapCheckType(dto.checkType),
      result: resultDtoToDomain(dto.result),
      riskScore: dto.riskScore.toInt(),
      riskLevel: _mapRiskLevelFromRecord(dto.riskLevel),
      stale: dto.stale,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }

  MedicineRiskCheckResult resultDtoToDomain(
    MedicineRiskCheckRecordsResponseDtoStaticResult dto,
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

  MedicineRiskFinding? findingDtoToDomain(
    MedicineRiskCheckRecordsResponseDtoStaticResultFindingsInner dto,
  ) {
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
    MedicineRiskCheckRecordsResponseDtoStaticResultCoverageIssuesInner dto,
  ) {
    return MedicineRiskCoverageIssue(
      medicineName: dto.medicineName,
      reason: _mapCoverageReason(dto.reason),
    );
  }

  RedFlagAlert redFlagDtoToDomain(
    MedicineRiskCheckRecordsResponseDtoStaticResultRedFlagsInner dto,
  ) {
    return RedFlagAlert(
      rule: _mapRedFlagRule(dto.rule),
      primaryMedicineName: dto.primaryMedicineName,
      relatedLabel: dto.relatedLabel,
    );
  }

  MedicinesControllerRunRiskCheckV1Request checkTypeToDto(
    MedicineRiskCheckType type,
  ) {
    return MedicinesControllerRunRiskCheckV1Request(
      type: switch (type) {
        MedicineRiskCheckType.static_ =>
          MedicinesControllerRunRiskCheckV1RequestTypeEnum.static_,
        MedicineRiskCheckType.llm =>
          MedicinesControllerRunRiskCheckV1RequestTypeEnum.llm,
      },
    );
  }

  /// Builds the static precheck request DTO for a candidate medicine from a
  /// trusted drug-library source ('cn' / 'drugbank'). The server checks the
  /// current box plus this candidate without persisting a record.
  MedicinesControllerRunRiskCheckV1Request precheckToDto({
    required String source,
    required String sourceRefId,
  }) {
    return MedicinesControllerRunRiskCheckV1Request(
      type: MedicinesControllerRunRiskCheckV1RequestTypeEnum.static_,
      candidate: MedicinesControllerRunRiskCheckV1RequestCandidate(
        source_: _mapCandidateSource(source),
        id: sourceRefId,
      ),
    );
  }

  // ─── Record builders ─────────────────────────────────────────────────────

  MedicineRiskCheckRecord _listRecordToDomain(
    MedicineRiskCheckRecordsResponseDtoStatic dto,
  ) {
    return _record(
      checkType: _mapCheckTypeFromList(dto.checkType),
      result: resultDtoToDomain(dto.result),
      riskScore: dto.riskScore.toInt(),
      riskLevel: _mapRiskLevelFromListRecord(dto.riskLevel),
      stale: dto.stale,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }

  MedicineRiskCheckRecord _record({
    required MedicineRiskCheckType checkType,
    required MedicineRiskCheckResult result,
    required int riskScore,
    required MedicineRiskLevel riskLevel,
    required bool stale,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) {
    return MedicineRiskCheckRecord(
      checkType: checkType,
      result: result,
      riskScore: riskScore,
      riskLevel: riskLevel,
      stale: stale,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // ─── Enum mappers ────────────────────────────────────────────────────────

  MedicineRiskLevel _mapRiskLevel(
    MedicineRiskCheckRecordsResponseDtoStaticResultOverallRiskLevelEnum level,
  ) {
    return switch (level) {
      MedicineRiskCheckRecordsResponseDtoStaticResultOverallRiskLevelEnum
          .safe =>
        MedicineRiskLevel.safe,
      MedicineRiskCheckRecordsResponseDtoStaticResultOverallRiskLevelEnum
          .caution =>
        MedicineRiskLevel.caution,
      MedicineRiskCheckRecordsResponseDtoStaticResultOverallRiskLevelEnum
          .risk =>
        MedicineRiskLevel.risk,
      MedicineRiskCheckRecordsResponseDtoStaticResultOverallRiskLevelEnum
          .danger =>
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

  MedicineRiskLevel _mapRiskLevelFromListRecord(
    MedicineRiskCheckRecordsResponseDtoStaticRiskLevelEnum level,
  ) {
    return switch (level) {
      MedicineRiskCheckRecordsResponseDtoStaticRiskLevelEnum.safe =>
        MedicineRiskLevel.safe,
      MedicineRiskCheckRecordsResponseDtoStaticRiskLevelEnum.caution =>
        MedicineRiskLevel.caution,
      MedicineRiskCheckRecordsResponseDtoStaticRiskLevelEnum.risk =>
        MedicineRiskLevel.risk,
      MedicineRiskCheckRecordsResponseDtoStaticRiskLevelEnum.danger =>
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

  MedicineRiskCheckType _mapCheckTypeFromList(
    MedicineRiskCheckRecordsResponseDtoStaticCheckTypeEnum type,
  ) {
    return switch (type) {
      MedicineRiskCheckRecordsResponseDtoStaticCheckTypeEnum.static_ =>
        MedicineRiskCheckType.static_,
      MedicineRiskCheckRecordsResponseDtoStaticCheckTypeEnum.llm =>
        MedicineRiskCheckType.llm,
      _ => MedicineRiskCheckType.static_,
    };
  }

  MedicinesControllerRunRiskCheckV1RequestCandidateSource_Enum
  _mapCandidateSource(String source) {
    return switch (source) {
      'cn' => MedicinesControllerRunRiskCheckV1RequestCandidateSource_Enum.cn,
      'drugbank' =>
        MedicinesControllerRunRiskCheckV1RequestCandidateSource_Enum.drugbank,
      // Unknown sources are rejected by the server; the precheck failure path
      // is non-blocking by design.
      _ =>
        MedicinesControllerRunRiskCheckV1RequestCandidateSource_Enum
            .unknownDefaultOpenApi,
    };
  }

  MedicineRiskFindingType? _mapFindingType(
    MedicineRiskCheckRecordsResponseDtoStaticResultFindingsInnerTypeEnum type,
  ) {
    return switch (type) {
      MedicineRiskCheckRecordsResponseDtoStaticResultFindingsInnerTypeEnum
          .interaction =>
        MedicineRiskFindingType.interaction,
      MedicineRiskCheckRecordsResponseDtoStaticResultFindingsInnerTypeEnum
          .duplicateIngredient =>
        MedicineRiskFindingType.duplicateIngredient,
      MedicineRiskCheckRecordsResponseDtoStaticResultFindingsInnerTypeEnum
          .allergy =>
        MedicineRiskFindingType.allergy,
      MedicineRiskCheckRecordsResponseDtoStaticResultFindingsInnerTypeEnum
          .foodInteraction =>
        MedicineRiskFindingType.foodInteraction,
      MedicineRiskCheckRecordsResponseDtoStaticResultFindingsInnerTypeEnum
          .longTermUse =>
        MedicineRiskFindingType.longTermUse,
      MedicineRiskCheckRecordsResponseDtoStaticResultFindingsInnerTypeEnum
          .schedulingConflict =>
        MedicineRiskFindingType.schedulingConflict,
      MedicineRiskCheckRecordsResponseDtoStaticResultFindingsInnerTypeEnum
          .specialGroup =>
        MedicineRiskFindingType.specialGroup,
      _ => null,
    };
  }

  MedicineRiskSeverity _mapSeverity(
    MedicineRiskCheckRecordsResponseDtoStaticResultFindingsInnerSeverityEnum
    severity,
  ) {
    return switch (severity) {
      MedicineRiskCheckRecordsResponseDtoStaticResultFindingsInnerSeverityEnum
          .high =>
        MedicineRiskSeverity.high,
      MedicineRiskCheckRecordsResponseDtoStaticResultFindingsInnerSeverityEnum
          .medium =>
        MedicineRiskSeverity.medium,
      MedicineRiskCheckRecordsResponseDtoStaticResultFindingsInnerSeverityEnum
          .info =>
        MedicineRiskSeverity.info,
      _ => MedicineRiskSeverity.info,
    };
  }

  MedicineRiskFindingContext _mapFindingContext(
    MedicineRiskCheckRecordsResponseDtoStaticResultFindingsInnerContextEnum
    context,
  ) {
    return switch (context) {
      MedicineRiskCheckRecordsResponseDtoStaticResultFindingsInnerContextEnum
          .none =>
        MedicineRiskFindingContext.none,
      MedicineRiskCheckRecordsResponseDtoStaticResultFindingsInnerContextEnum
          .alcohol =>
        MedicineRiskFindingContext.alcohol,
      MedicineRiskCheckRecordsResponseDtoStaticResultFindingsInnerContextEnum
          .caffeine =>
        MedicineRiskFindingContext.caffeine,
      _ => MedicineRiskFindingContext.none,
    };
  }

  MedicineRiskCoverageReason _mapCoverageReason(
    MedicineRiskCheckRecordsResponseDtoStaticResultCoverageIssuesInnerReasonEnum
    reason,
  ) {
    return switch (reason) {
      MedicineRiskCheckRecordsResponseDtoStaticResultCoverageIssuesInnerReasonEnum
          .manualEntry =>
        MedicineRiskCoverageReason.manualEntry,
      MedicineRiskCheckRecordsResponseDtoStaticResultCoverageIssuesInnerReasonEnum
          .missingSourceRef =>
        MedicineRiskCoverageReason.missingSourceRef,
      MedicineRiskCheckRecordsResponseDtoStaticResultCoverageIssuesInnerReasonEnum
          .detailUnavailable =>
        MedicineRiskCoverageReason.detailUnavailable,
      _ => MedicineRiskCoverageReason.detailUnavailable,
    };
  }

  RedFlagRule _mapRedFlagRule(
    MedicineRiskCheckRecordsResponseDtoStaticResultRedFlagsInnerRuleEnum rule,
  ) {
    return switch (rule) {
      MedicineRiskCheckRecordsResponseDtoStaticResultRedFlagsInnerRuleEnum
          .severeAllergy =>
        RedFlagRule.severeAllergy,
      MedicineRiskCheckRecordsResponseDtoStaticResultRedFlagsInnerRuleEnum
          .informationGap =>
        RedFlagRule.informationGap,
      _ => RedFlagRule.informationGap,
    };
  }
}
