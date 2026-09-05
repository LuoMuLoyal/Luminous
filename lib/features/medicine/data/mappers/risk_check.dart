import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/features/medicine/domain/entities/risk_check.dart';

/// Maps generated OpenAPI DTOs to domain entities for the risk check feature.
///
/// 响应侧 zod 再生成后,record 载荷由 per-op DTO 表达:list records 的
/// `static`/`llm` 槽位是 `MedicineRiskCheckRecordsResponseStatic` /
/// `MedicineRiskCheckRecordsResponseLlm`,run-check/precheck 单条响应是
/// `MedicineRiskCheckRecordResponse`。三者字段布局相同但类型族系不同
/// (static/llm/single-record 各自有独立的 result 与嵌套枚举),故这里把
/// 各族的 wire 枚举值收敛到共享的 value→domain 映射,再以薄包装把各族
/// DTO 转成领域实体。
class MedicineRiskCheckMapper {
  const MedicineRiskCheckMapper();

  MedicineRiskCheckRecords recordsDtoToDomain(
    MedicineRiskCheckRecordsResponse dto,
  ) {
    return MedicineRiskCheckRecords(
      staticRecord: dto.static_ == null
          ? null
          : _listRecordToDomain(dto.static_!),
      llmRecord: dto.llm == null ? null : _llmRecordToDomain(dto.llm!),
    );
  }

  MedicineRiskCheckRecord recordDtoToDomain(
    MedicineRiskCheckRecordResponse dto,
  ) {
    return _record(
      checkType: _mapCheckTypeValue(dto.checkType.value),
      result: recordResultDtoToDomain(dto.result),
      riskScore: dto.riskScore.toInt(),
      riskLevel: _mapRiskLevelValue(dto.riskLevel.value),
      stale: dto.stale,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }

  // ─── Static-family result mapping (list records `static` slot) ─────────

  MedicineRiskCheckResult resultDtoToDomain(
    MedicineRiskCheckRecordsResponseStaticResult dto,
  ) {
    return _resultFromValues(
      overallRiskLevelValue: dto.overallRiskLevel.value,
      overallRiskScore: dto.overallRiskScore,
      currentMedicineCount: dto.currentMedicineCount,
      checkedMedicineCount: dto.checkedMedicineCount,
      findings: dto.findings.map(findingDtoToDomain).toList(),
      coverageIssues: dto.coverageIssues.map(coverageIssueDtoToDomain).toList(),
      redFlags: dto.redFlags.map(redFlagDtoToDomain).toList(),
      overallRecommendation: dto.overallRecommendation,
    );
  }

  MedicineRiskFinding? findingDtoToDomain(
    MedicineRiskCheckRecordsResponseStaticResultFindings dto,
  ) {
    return _findingFromValues(
      typeValue: dto.type.value,
      severityValue: dto.severity.value,
      contextValue: dto.context.value,
      primaryMedicineName: dto.primaryMedicineName,
      secondaryMedicineName: dto.secondaryMedicineName,
      relatedLabel: dto.relatedLabel,
      evidence: dto.evidence,
      recommendation: dto.recommendation,
    );
  }

  MedicineRiskCoverageIssue coverageIssueDtoToDomain(
    MedicineRiskCheckRecordsResponseStaticResultCoverageIssues dto,
  ) {
    return MedicineRiskCoverageIssue(
      medicineName: dto.medicineName,
      reason: _mapCoverageReasonValue(dto.reason.value),
    );
  }

  RedFlagAlert redFlagDtoToDomain(
    MedicineRiskCheckRecordsResponseStaticResultRedFlags dto,
  ) {
    return RedFlagAlert(
      rule: _mapRedFlagRuleValue(dto.rule.value),
      primaryMedicineName: dto.primaryMedicineName,
      relatedLabel: dto.relatedLabel,
    );
  }

  // ─── LLM-family result mapping (list records `llm` slot) ───────────────

  MedicineRiskCheckResult llmResultDtoToDomain(
    MedicineRiskCheckRecordsResponseLlmResult dto,
  ) {
    return _resultFromValues(
      overallRiskLevelValue: dto.overallRiskLevel.value,
      overallRiskScore: dto.overallRiskScore,
      currentMedicineCount: dto.currentMedicineCount,
      checkedMedicineCount: dto.checkedMedicineCount,
      findings: dto.findings.map(llmFindingDtoToDomain).toList(),
      coverageIssues:
          dto.coverageIssues.map(llmCoverageIssueDtoToDomain).toList(),
      redFlags: dto.redFlags.map(llmRedFlagDtoToDomain).toList(),
      overallRecommendation: dto.overallRecommendation,
    );
  }

  MedicineRiskFinding? llmFindingDtoToDomain(
    MedicineRiskCheckRecordsResponseLlmResultFindings dto,
  ) {
    return _findingFromValues(
      typeValue: dto.type.value,
      severityValue: dto.severity.value,
      contextValue: dto.context.value,
      primaryMedicineName: dto.primaryMedicineName,
      secondaryMedicineName: dto.secondaryMedicineName,
      relatedLabel: dto.relatedLabel,
      evidence: dto.evidence,
      recommendation: dto.recommendation,
    );
  }

  MedicineRiskCoverageIssue llmCoverageIssueDtoToDomain(
    MedicineRiskCheckRecordsResponseLlmResultCoverageIssues dto,
  ) {
    return MedicineRiskCoverageIssue(
      medicineName: dto.medicineName,
      reason: _mapCoverageReasonValue(dto.reason.value),
    );
  }

  RedFlagAlert llmRedFlagDtoToDomain(
    MedicineRiskCheckRecordsResponseLlmResultRedFlags dto,
  ) {
    return RedFlagAlert(
      rule: _mapRedFlagRuleValue(dto.rule.value),
      primaryMedicineName: dto.primaryMedicineName,
      relatedLabel: dto.relatedLabel,
    );
  }

  // ─── Single-record result mapping (run-check / precheck) ─────────────────

  MedicineRiskCheckResult recordResultDtoToDomain(
    MedicineRiskCheckRecordResponseResult dto,
  ) {
    return _resultFromValues(
      overallRiskLevelValue: dto.overallRiskLevel.value,
      overallRiskScore: dto.overallRiskScore,
      currentMedicineCount: dto.currentMedicineCount,
      checkedMedicineCount: dto.checkedMedicineCount,
      findings: dto.findings.map(recordFindingDtoToDomain).toList(),
      coverageIssues:
          dto.coverageIssues.map(recordCoverageIssueDtoToDomain).toList(),
      redFlags: dto.redFlags.map(recordRedFlagDtoToDomain).toList(),
      overallRecommendation: dto.overallRecommendation,
    );
  }

  MedicineRiskFinding? recordFindingDtoToDomain(
    MedicineRiskCheckRecordResponseResultFindings dto,
  ) {
    return _findingFromValues(
      typeValue: dto.type.value,
      severityValue: dto.severity.value,
      contextValue: dto.context.value,
      primaryMedicineName: dto.primaryMedicineName,
      secondaryMedicineName: dto.secondaryMedicineName,
      relatedLabel: dto.relatedLabel,
      evidence: dto.evidence,
      recommendation: dto.recommendation,
    );
  }

  MedicineRiskCoverageIssue recordCoverageIssueDtoToDomain(
    MedicineRiskCheckRecordResponseResultCoverageIssues dto,
  ) {
    return MedicineRiskCoverageIssue(
      medicineName: dto.medicineName,
      reason: _mapCoverageReasonValue(dto.reason.value),
    );
  }

  RedFlagAlert recordRedFlagDtoToDomain(
    MedicineRiskCheckRecordResponseResultRedFlags dto,
  ) {
    return RedFlagAlert(
      rule: _mapRedFlagRuleValue(dto.rule.value),
      primaryMedicineName: dto.primaryMedicineName,
      relatedLabel: dto.relatedLabel,
    );
  }

  // ─── Request builders ────────────────────────────────────────────────────

  RunRiskCheckRequest checkTypeToDto(MedicineRiskCheckType type) {
    return RunRiskCheckRequest(
      type: switch (type) {
        MedicineRiskCheckType.static_ => RunRiskCheckRequestTypeEnum.static_,
        MedicineRiskCheckType.llm => RunRiskCheckRequestTypeEnum.llm,
      },
    );
  }

  /// Builds the static precheck request DTO for a candidate medicine from a
  /// trusted drug-library source ('cn' / 'drugbank'). The server checks the
  /// current box plus this candidate without persisting a record.
  RunRiskCheckRequest precheckToDto({
    required String source,
    required String sourceRefId,
  }) {
    return RunRiskCheckRequest(
      type: RunRiskCheckRequestTypeEnum.static_,
      candidate: RunRiskCheckRequestCandidate(
        source_: _mapCandidateSource(source),
        id: sourceRefId,
      ),
    );
  }

  // ─── Record builders ─────────────────────────────────────────────────────

  MedicineRiskCheckRecord _listRecordToDomain(
    MedicineRiskCheckRecordsResponseStatic dto,
  ) {
    return _record(
      checkType: _mapCheckTypeValue(dto.checkType.value),
      result: resultDtoToDomain(dto.result),
      riskScore: dto.riskScore.toInt(),
      riskLevel: _mapRiskLevelValue(dto.riskLevel.value),
      stale: dto.stale,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }

  MedicineRiskCheckRecord _llmRecordToDomain(
    MedicineRiskCheckRecordsResponseLlm dto,
  ) {
    return _record(
      checkType: _mapCheckTypeValue(dto.checkType.value),
      result: llmResultDtoToDomain(dto.result),
      riskScore: dto.riskScore.toInt(),
      riskLevel: _mapRiskLevelValue(dto.riskLevel.value),
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

  // ─── Shared family-neutral result/finding builders ───────────────────────

  MedicineRiskCheckResult _resultFromValues({
    required String overallRiskLevelValue,
    required num overallRiskScore,
    required num currentMedicineCount,
    required num checkedMedicineCount,
    required List<MedicineRiskFinding?> findings,
    required List<MedicineRiskCoverageIssue> coverageIssues,
    required List<RedFlagAlert> redFlags,
    String? overallRecommendation,
  }) {
    return MedicineRiskCheckResult(
      overallRiskLevel: _mapRiskLevelValue(overallRiskLevelValue),
      overallRiskScore: overallRiskScore.toInt(),
      currentMedicineCount: currentMedicineCount.toInt(),
      checkedMedicineCount: checkedMedicineCount.toInt(),
      findings: findings.whereType<MedicineRiskFinding>().toList(),
      coverageIssues: coverageIssues,
      redFlags: redFlags,
      overallRecommendation: overallRecommendation,
    );
  }

  MedicineRiskFinding? _findingFromValues({
    required String typeValue,
    required String severityValue,
    required String contextValue,
    required String primaryMedicineName,
    String? secondaryMedicineName,
    String? relatedLabel,
    String? evidence,
    String? recommendation,
  }) {
    final type = _mapFindingTypeValue(typeValue);
    if (type == null) {
      return null;
    }
    return MedicineRiskFinding(
      type: type,
      severity: _mapSeverityValue(severityValue),
      context: _mapFindingContextValue(contextValue),
      primaryMedicineName: primaryMedicineName,
      secondaryMedicineName: secondaryMedicineName,
      relatedLabel: relatedLabel,
      evidence: evidence,
      recommendation: recommendation,
    );
  }

  // ─── Enum value mappers (wire value → domain) ────────────────────────────

  MedicineRiskLevel _mapRiskLevelValue(String value) {
    return switch (value) {
      'safe' => MedicineRiskLevel.safe,
      'caution' => MedicineRiskLevel.caution,
      'risk' => MedicineRiskLevel.risk,
      'danger' => MedicineRiskLevel.danger,
      _ => MedicineRiskLevel.safe,
    };
  }

  MedicineRiskCheckType _mapCheckTypeValue(String value) {
    return switch (value) {
      'static' => MedicineRiskCheckType.static_,
      'llm' => MedicineRiskCheckType.llm,
      _ => MedicineRiskCheckType.static_,
    };
  }

  RunRiskCheckRequestCandidateSource_Enum _mapCandidateSource(String source) {
    return switch (source) {
      'cn' => RunRiskCheckRequestCandidateSource_Enum.cn,
      'drugbank' => RunRiskCheckRequestCandidateSource_Enum.drugbank,
      // Unknown sources are rejected by the server; the precheck failure path
      // is non-blocking by design.
      _ =>
        RunRiskCheckRequestCandidateSource_Enum.unknownDefaultOpenApi,
    };
  }

  MedicineRiskFindingType? _mapFindingTypeValue(String value) {
    return switch (value) {
      'interaction' => MedicineRiskFindingType.interaction,
      'duplicateIngredient' => MedicineRiskFindingType.duplicateIngredient,
      'allergy' => MedicineRiskFindingType.allergy,
      'foodInteraction' => MedicineRiskFindingType.foodInteraction,
      'longTermUse' => MedicineRiskFindingType.longTermUse,
      'schedulingConflict' => MedicineRiskFindingType.schedulingConflict,
      'specialGroup' => MedicineRiskFindingType.specialGroup,
      _ => null,
    };
  }

  MedicineRiskSeverity _mapSeverityValue(String value) {
    return switch (value) {
      'high' => MedicineRiskSeverity.high,
      'medium' => MedicineRiskSeverity.medium,
      'info' => MedicineRiskSeverity.info,
      _ => MedicineRiskSeverity.info,
    };
  }

  MedicineRiskFindingContext _mapFindingContextValue(String value) {
    return switch (value) {
      'none' => MedicineRiskFindingContext.none,
      'alcohol' => MedicineRiskFindingContext.alcohol,
      'caffeine' => MedicineRiskFindingContext.caffeine,
      _ => MedicineRiskFindingContext.none,
    };
  }

  MedicineRiskCoverageReason _mapCoverageReasonValue(String value) {
    return switch (value) {
      'manualEntry' => MedicineRiskCoverageReason.manualEntry,
      'missingSourceRef' => MedicineRiskCoverageReason.missingSourceRef,
      'detailUnavailable' => MedicineRiskCoverageReason.detailUnavailable,
      _ => MedicineRiskCoverageReason.detailUnavailable,
    };
  }

  RedFlagRule _mapRedFlagRuleValue(String value) {
    return switch (value) {
      'severeAllergy' => RedFlagRule.severeAllergy,
      'informationGap' => RedFlagRule.informationGap,
      _ => RedFlagRule.informationGap,
    };
  }
}
