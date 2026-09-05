import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/features/medicine/data/mappers/risk_check.dart';
import 'package:luminous/features/medicine/domain/entities/risk_check.dart';

MedicineRiskCheckRecordsResponseStaticResult _response({
  MedicineRiskCheckRecordsResponseStaticResultOverallRiskLevelEnum level =
      MedicineRiskCheckRecordsResponseStaticResultOverallRiskLevelEnum.safe,
  int score = 0,
  List<MedicineRiskCheckRecordsResponseStaticResultFindings> findings =
      const [],
  List<MedicineRiskCheckRecordsResponseStaticResultCoverageIssues>
      coverageIssues =
      const [],
  List<MedicineRiskCheckRecordsResponseStaticResultRedFlags> redFlags =
      const [],
  String? recommendation,
}) {
  return MedicineRiskCheckRecordsResponseStaticResult(
    overallRiskLevel: level,
    overallRiskScore: score,
    currentMedicineCount: 3,
    checkedMedicineCount: 2,
    findings: findings,
    coverageIssues: coverageIssues,
    redFlags: redFlags,
    overallRecommendation: recommendation,
  );
}

MedicineRiskCheckRecordResponse _record({
  MedicineRiskCheckRecordResponseCheckTypeEnum checkType =
      MedicineRiskCheckRecordResponseCheckTypeEnum.static_,
  MedicineRiskCheckRecordResponseRiskLevelEnum riskLevel =
      MedicineRiskCheckRecordResponseRiskLevelEnum.safe,
  MedicineRiskCheckRecordResponseResult? result,
  int score = 10,
  bool stale = false,
}) {
  return MedicineRiskCheckRecordResponse(
    checkType: checkType,
    result: result ?? _recordResult(score: score),
    riskScore: score,
    riskLevel: riskLevel,
    stale: stale,
    createdAt: DateTime(2026, 7, 1),
    updatedAt: DateTime(2026, 7, 2),
  );
}

MedicineRiskCheckRecordResponseResult _recordResult({
  MedicineRiskCheckRecordResponseResultOverallRiskLevelEnum level =
      MedicineRiskCheckRecordResponseResultOverallRiskLevelEnum.safe,
  int score = 0,
  List<MedicineRiskCheckRecordResponseResultFindings> findings = const [],
  List<MedicineRiskCheckRecordResponseResultCoverageIssues> coverageIssues =
      const [],
  List<MedicineRiskCheckRecordResponseResultRedFlags> redFlags = const [],
  String? recommendation,
}) {
  return MedicineRiskCheckRecordResponseResult(
    overallRiskLevel: level,
    overallRiskScore: score,
    currentMedicineCount: 3,
    checkedMedicineCount: 2,
    findings: findings,
    coverageIssues: coverageIssues,
    redFlags: redFlags,
    overallRecommendation: recommendation,
  );
}

MedicineRiskCheckRecordsResponseStatic _listRecord({
  MedicineRiskCheckRecordsResponseStaticCheckTypeEnum checkType =
      MedicineRiskCheckRecordsResponseStaticCheckTypeEnum.static_,
  MedicineRiskCheckRecordsResponseStaticRiskLevelEnum riskLevel =
      MedicineRiskCheckRecordsResponseStaticRiskLevelEnum.safe,
  MedicineRiskCheckRecordsResponseStaticResult? result,
  int score = 10,
  bool stale = false,
}) {
  return MedicineRiskCheckRecordsResponseStatic(
    checkType: checkType,
    result: result ?? _response(score: score),
    riskScore: score,
    riskLevel: riskLevel,
    stale: stale,
    createdAt: DateTime(2026, 7, 1),
    updatedAt: DateTime(2026, 7, 2),
  );
}

MedicineRiskCheckRecordsResponseLlm _listLlmRecord({
  MedicineRiskCheckRecordsResponseLlmCheckTypeEnum checkType =
      MedicineRiskCheckRecordsResponseLlmCheckTypeEnum.static_,
  MedicineRiskCheckRecordsResponseLlmRiskLevelEnum riskLevel =
      MedicineRiskCheckRecordsResponseLlmRiskLevelEnum.safe,
  MedicineRiskCheckRecordsResponseLlmResult? result,
  int score = 10,
  bool stale = false,
}) {
  return MedicineRiskCheckRecordsResponseLlm(
    checkType: checkType,
    result: result ?? _llmResult(score: score),
    riskScore: score,
    riskLevel: riskLevel,
    stale: stale,
    createdAt: DateTime(2026, 7, 1),
    updatedAt: DateTime(2026, 7, 2),
  );
}

MedicineRiskCheckRecordsResponseLlmResult _llmResult({
  MedicineRiskCheckRecordsResponseLlmResultOverallRiskLevelEnum level =
      MedicineRiskCheckRecordsResponseLlmResultOverallRiskLevelEnum.safe,
  int score = 0,
  List<MedicineRiskCheckRecordsResponseLlmResultFindings> findings = const [],
  List<MedicineRiskCheckRecordsResponseLlmResultCoverageIssues>
      coverageIssues = const [],
  List<MedicineRiskCheckRecordsResponseLlmResultRedFlags> redFlags = const [],
  String? recommendation,
}) {
  return MedicineRiskCheckRecordsResponseLlmResult(
    overallRiskLevel: level,
    overallRiskScore: score,
    currentMedicineCount: 3,
    checkedMedicineCount: 2,
    findings: findings,
    coverageIssues: coverageIssues,
    redFlags: redFlags,
    overallRecommendation: recommendation,
  );
}

void main() {
  const mapper = MedicineRiskCheckMapper();

  group('recordsDtoToDomain', () {
    test('maps static + llm records', () {
      final records = mapper.recordsDtoToDomain(
        MedicineRiskCheckRecordsResponse(
          static_: _listRecord(
            checkType:
                MedicineRiskCheckRecordsResponseStaticCheckTypeEnum.static_,
          ),
          llm: _listLlmRecord(
            checkType:
                MedicineRiskCheckRecordsResponseLlmCheckTypeEnum.llm,
          ),
        ),
      );

      expect(records.staticRecord, isNotNull);
      expect(records.llmRecord, isNotNull);
      expect(records.bestRecord?.checkType, MedicineRiskCheckType.llm);
      expect(records.isEmpty, isFalse);
    });

    test('handles null records', () {
      final records = mapper.recordsDtoToDomain(
        MedicineRiskCheckRecordsResponse(static_: null, llm: null),
      );

      expect(records.staticRecord, isNull);
      expect(records.llmRecord, isNull);
      expect(records.isEmpty, isTrue);
      expect(records.bestRecord, isNull);
      expect(records.isStale, isFalse);
    });
  });

  group('recordDtoToDomain', () {
    test('maps record fields', () {
      final record = mapper.recordDtoToDomain(
        _record(
          checkType: MedicineRiskCheckRecordResponseCheckTypeEnum.llm,
          riskLevel: MedicineRiskCheckRecordResponseRiskLevelEnum.danger,
          score: 88,
          stale: true,
        ),
      );

      expect(record.checkType, MedicineRiskCheckType.llm);
      expect(record.riskScore, 88);
      expect(record.riskLevel, MedicineRiskLevel.danger);
      expect(record.stale, isTrue);
      expect(record.createdAt, DateTime(2026, 7, 1));
      expect(record.updatedAt, DateTime(2026, 7, 2));
    });

    test('maps unknown check type to static', () {
      final record = mapper.recordDtoToDomain(
        _record(
          checkType: MedicineRiskCheckRecordResponseCheckTypeEnum
              .unknownDefaultOpenApi,
        ),
      );
      expect(record.checkType, MedicineRiskCheckType.static_);
    });

    test('maps unknown risk level to safe', () {
      final record = mapper.recordDtoToDomain(
        _record(
          riskLevel: MedicineRiskCheckRecordResponseRiskLevelEnum
              .unknownDefaultOpenApi,
        ),
      );
      expect(record.riskLevel, MedicineRiskLevel.safe);
    });
  });

  group('resultDtoToDomain', () {
    test('maps all risk levels and fields', () {
      final result = mapper.resultDtoToDomain(
        _response(
          level:
              MedicineRiskCheckRecordsResponseStaticResultOverallRiskLevelEnum
                  .caution,
          score: 45,
          recommendation: '多喝水',
        ),
      );

      expect(result.overallRiskLevel, MedicineRiskLevel.caution);
      expect(result.overallRiskScore, 45);
      expect(result.currentMedicineCount, 3);
      expect(result.checkedMedicineCount, 2);
      expect(result.overallRecommendation, '多喝水');
    });

    test('maps unknown risk level to safe', () {
      final result = mapper.resultDtoToDomain(
        _response(
          level:
              MedicineRiskCheckRecordsResponseStaticResultOverallRiskLevelEnum
                  .unknownDefaultOpenApi,
        ),
      );
      expect(result.overallRiskLevel, MedicineRiskLevel.safe);
    });

    test('drops unknown finding types from findings list', () {
      final result = mapper.resultDtoToDomain(
        _response(
          findings: [
            MedicineRiskCheckRecordsResponseStaticResultFindings(
              type:
                  MedicineRiskCheckRecordsResponseStaticResultFindingsTypeEnum
                      .interaction,
              severity:
                  MedicineRiskCheckRecordsResponseStaticResultFindingsSeverityEnum
                      .high,
              context:
                  MedicineRiskCheckRecordsResponseStaticResultFindingsContextEnum
                      .none,
              primaryMedicineName: '合法药',
            ),
            MedicineRiskCheckRecordsResponseStaticResultFindings(
              type:
                  MedicineRiskCheckRecordsResponseStaticResultFindingsTypeEnum
                      .unknownDefaultOpenApi,
              severity:
                  MedicineRiskCheckRecordsResponseStaticResultFindingsSeverityEnum
                      .medium,
              context:
                  MedicineRiskCheckRecordsResponseStaticResultFindingsContextEnum
                      .alcohol,
              primaryMedicineName: '未知药',
            ),
          ],
        ),
      );

      expect(result.findingCount, 1);
      expect(result.hasFindings, isTrue);
      expect(result.findings.single.primaryMedicineName, '合法药');
    });
  });

  group('findingDtoToDomain', () {
    test('maps all finding types', () {
      const expectedByType =
          <
            MedicineRiskCheckRecordsResponseStaticResultFindingsTypeEnum,
            MedicineRiskFindingType
          >{
            MedicineRiskCheckRecordsResponseStaticResultFindingsTypeEnum
                    .interaction:
                MedicineRiskFindingType.interaction,
            MedicineRiskCheckRecordsResponseStaticResultFindingsTypeEnum
                    .duplicateIngredient:
                MedicineRiskFindingType.duplicateIngredient,
            MedicineRiskCheckRecordsResponseStaticResultFindingsTypeEnum
                    .allergy:
                MedicineRiskFindingType.allergy,
            MedicineRiskCheckRecordsResponseStaticResultFindingsTypeEnum
                    .foodInteraction:
                MedicineRiskFindingType.foodInteraction,
            MedicineRiskCheckRecordsResponseStaticResultFindingsTypeEnum
                    .longTermUse:
                MedicineRiskFindingType.longTermUse,
            MedicineRiskCheckRecordsResponseStaticResultFindingsTypeEnum
                    .schedulingConflict:
                MedicineRiskFindingType.schedulingConflict,
            MedicineRiskCheckRecordsResponseStaticResultFindingsTypeEnum
                    .specialGroup:
                MedicineRiskFindingType.specialGroup,
          };

      expectedByType.forEach((dtoEnum, expected) {
        final finding = mapper.findingDtoToDomain(
          MedicineRiskCheckRecordsResponseStaticResultFindings(
            type: dtoEnum,
            severity:
                MedicineRiskCheckRecordsResponseStaticResultFindingsSeverityEnum
                    .high,
            context:
                MedicineRiskCheckRecordsResponseStaticResultFindingsContextEnum
                    .none,
            primaryMedicineName: '阿莫西林',
          ),
        );
        expect(finding!.type, expected, reason: 'for $dtoEnum');
      });
    });

    test('findingDtoToDomain returns null for unknown finding type', () {
      final finding = mapper.findingDtoToDomain(
        MedicineRiskCheckRecordsResponseStaticResultFindings(
          type:
              MedicineRiskCheckRecordsResponseStaticResultFindingsTypeEnum
                  .unknownDefaultOpenApi,
          severity:
              MedicineRiskCheckRecordsResponseStaticResultFindingsSeverityEnum
                  .medium,
          context:
              MedicineRiskCheckRecordsResponseStaticResultFindingsContextEnum
                  .alcohol,
          primaryMedicineName: '药A',
          secondaryMedicineName: '药B',
          relatedLabel: '酒精',
          evidence: '证据',
          recommendation: '建议',
        ),
      );

      expect(finding, isNull);
    });

    test('maps all severities', () {
      expect(
        mapper
            .findingDtoToDomain(
              MedicineRiskCheckRecordsResponseStaticResultFindings(
                type:
                    MedicineRiskCheckRecordsResponseStaticResultFindingsTypeEnum
                        .allergy,
                severity:
                    MedicineRiskCheckRecordsResponseStaticResultFindingsSeverityEnum
                        .high,
                context:
                    MedicineRiskCheckRecordsResponseStaticResultFindingsContextEnum
                        .none,
                primaryMedicineName: '药',
              ),
            )!
            .severity,
        MedicineRiskSeverity.high,
      );
      expect(
        mapper
            .findingDtoToDomain(
              MedicineRiskCheckRecordsResponseStaticResultFindings(
                type:
                    MedicineRiskCheckRecordsResponseStaticResultFindingsTypeEnum
                        .allergy,
                severity:
                    MedicineRiskCheckRecordsResponseStaticResultFindingsSeverityEnum
                        .medium,
                context:
                    MedicineRiskCheckRecordsResponseStaticResultFindingsContextEnum
                        .none,
                primaryMedicineName: '药',
              ),
            )!
            .severity,
        MedicineRiskSeverity.medium,
      );
      expect(
        mapper
            .findingDtoToDomain(
              MedicineRiskCheckRecordsResponseStaticResultFindings(
                type:
                    MedicineRiskCheckRecordsResponseStaticResultFindingsTypeEnum
                        .allergy,
                severity:
                    MedicineRiskCheckRecordsResponseStaticResultFindingsSeverityEnum
                        .info,
                context:
                    MedicineRiskCheckRecordsResponseStaticResultFindingsContextEnum
                        .none,
                primaryMedicineName: '药',
              ),
            )!
            .severity,
        MedicineRiskSeverity.info,
      );
      expect(
        mapper
            .findingDtoToDomain(
              MedicineRiskCheckRecordsResponseStaticResultFindings(
                type:
                    MedicineRiskCheckRecordsResponseStaticResultFindingsTypeEnum
                        .allergy,
                severity:
                    MedicineRiskCheckRecordsResponseStaticResultFindingsSeverityEnum
                        .unknownDefaultOpenApi,
                context:
                    MedicineRiskCheckRecordsResponseStaticResultFindingsContextEnum
                        .none,
                primaryMedicineName: '药',
              ),
            )!
            .severity,
        MedicineRiskSeverity.info,
      );
    });

    test('maps all contexts', () {
      for (final (dtoEnum, expected) in [
        (
          MedicineRiskCheckRecordsResponseStaticResultFindingsContextEnum
              .none,
          MedicineRiskFindingContext.none,
        ),
        (
          MedicineRiskCheckRecordsResponseStaticResultFindingsContextEnum
              .alcohol,
          MedicineRiskFindingContext.alcohol,
        ),
        (
          MedicineRiskCheckRecordsResponseStaticResultFindingsContextEnum
              .caffeine,
          MedicineRiskFindingContext.caffeine,
        ),
      ]) {
        final finding = mapper.findingDtoToDomain(
          MedicineRiskCheckRecordsResponseStaticResultFindings(
            type:
                MedicineRiskCheckRecordsResponseStaticResultFindingsTypeEnum
                    .allergy,
            severity:
                MedicineRiskCheckRecordsResponseStaticResultFindingsSeverityEnum
                    .high,
            context: dtoEnum,
            primaryMedicineName: '药',
          ),
        );
        expect(finding!.context, expected, reason: 'for $dtoEnum');
      }
    });
  });

  group('coverageIssueDtoToDomain', () {
    test('maps all reasons', () {
      for (final (dtoEnum, expected) in [
        (
          MedicineRiskCheckRecordsResponseStaticResultCoverageIssuesReasonEnum
              .manualEntry,
          MedicineRiskCoverageReason.manualEntry,
        ),
        (
          MedicineRiskCheckRecordsResponseStaticResultCoverageIssuesReasonEnum
              .missingSourceRef,
          MedicineRiskCoverageReason.missingSourceRef,
        ),
        (
          MedicineRiskCheckRecordsResponseStaticResultCoverageIssuesReasonEnum
              .detailUnavailable,
          MedicineRiskCoverageReason.detailUnavailable,
        ),
        (
          MedicineRiskCheckRecordsResponseStaticResultCoverageIssuesReasonEnum
              .unknownDefaultOpenApi,
          MedicineRiskCoverageReason.detailUnavailable,
        ),
      ]) {
        final issue = mapper.coverageIssueDtoToDomain(
          MedicineRiskCheckRecordsResponseStaticResultCoverageIssues(
            medicineName: '药X',
            reason: dtoEnum,
          ),
        );
        expect(issue.medicineName, '药X');
        expect(issue.reason, expected, reason: 'for $dtoEnum');
      }
    });
  });

  group('redFlagDtoToDomain', () {
    test('maps all rules', () {
      for (final (dtoEnum, expected) in [
        (
          MedicineRiskCheckRecordsResponseStaticResultRedFlagsRuleEnum
              .severeAllergy,
          RedFlagRule.severeAllergy,
        ),
        (
          MedicineRiskCheckRecordsResponseStaticResultRedFlagsRuleEnum
              .informationGap,
          RedFlagRule.informationGap,
        ),
        (
          MedicineRiskCheckRecordsResponseStaticResultRedFlagsRuleEnum
              .unknownDefaultOpenApi,
          RedFlagRule.informationGap,
        ),
      ]) {
        final alert = mapper.redFlagDtoToDomain(
          MedicineRiskCheckRecordsResponseStaticResultRedFlags(
            rule: dtoEnum,
            primaryMedicineName: '青霉素',
            relatedLabel: '阿莫西林',
          ),
        );
        expect(alert.rule, expected, reason: 'for $dtoEnum');
        expect(alert.primaryMedicineName, '青霉素');
        expect(alert.relatedLabel, '阿莫西林');
      }
    });
  });

  group('checkTypeToDto', () {
    test('maps static and llm', () {
      expect(
        mapper.checkTypeToDto(MedicineRiskCheckType.static_).type,
        RunRiskCheckRequestTypeEnum.static_,
      );
      expect(
        mapper.checkTypeToDto(MedicineRiskCheckType.llm).type,
        RunRiskCheckRequestTypeEnum.llm,
      );
    });
  });

  group('precheckToDto', () {
    test('builds static request with cn candidate', () {
      final dto = mapper.precheckToDto(
        source: 'cn',
        sourceRefId: '__mock_cn_ibuprofen__',
      );

      expect(
        dto.type,
        RunRiskCheckRequestTypeEnum.static_,
      );
      expect(dto.candidate, isNotNull);
      expect(
        dto.candidate!.source_,
        RunRiskCheckRequestCandidateSource_Enum.cn,
      );
      expect(dto.candidate!.id, '__mock_cn_ibuprofen__');
    });

    test('maps drugbank candidate source', () {
      final dto = mapper.precheckToDto(
        source: 'drugbank',
        sourceRefId: 'DB01050',
      );

      expect(
        dto.type,
        RunRiskCheckRequestTypeEnum.static_,
      );
      expect(
        dto.candidate!.source_,
        RunRiskCheckRequestCandidateSource_Enum.drugbank,
      );
      expect(dto.candidate!.id, 'DB01050');
    });

    test('falls back to unknown source enum for unsupported sources', () {
      final dto = mapper.precheckToDto(source: 'other', sourceRefId: 'x');

      expect(
        dto.candidate!.source_,
        RunRiskCheckRequestCandidateSource_Enum
            .unknownDefaultOpenApi,
      );
    });
  });

  group('full result mapping', () {
    test('maps finding, coverage and red flag lists', () {
      final result = mapper.resultDtoToDomain(
        _response(
          level:
              MedicineRiskCheckRecordsResponseStaticResultOverallRiskLevelEnum
                  .risk,
          findings: [
            MedicineRiskCheckRecordsResponseStaticResultFindings(
              type:
                  MedicineRiskCheckRecordsResponseStaticResultFindingsTypeEnum
                      .interaction,
              severity:
                  MedicineRiskCheckRecordsResponseStaticResultFindingsSeverityEnum
                      .high,
              context:
                  MedicineRiskCheckRecordsResponseStaticResultFindingsContextEnum
                      .none,
              primaryMedicineName: 'A',
            ),
          ],
          coverageIssues: [
            MedicineRiskCheckRecordsResponseStaticResultCoverageIssues(
              medicineName: 'B',
              reason:
                  MedicineRiskCheckRecordsResponseStaticResultCoverageIssuesReasonEnum
                      .manualEntry,
            ),
          ],
          redFlags: [
            MedicineRiskCheckRecordsResponseStaticResultRedFlags(
              rule:
                  MedicineRiskCheckRecordsResponseStaticResultRedFlagsRuleEnum
                      .severeAllergy,
              primaryMedicineName: 'C',
            ),
          ],
        ),
      );

      expect(result.hasFindings, isTrue);
      expect(result.hasCoverageGaps, isTrue);
      expect(result.hasRedFlags, isTrue);
      expect(result.findingCount, 1);
      expect(result.coverageCount, 1);
      expect(result.findings.single.primaryMedicineName, 'A');
      expect(result.coverageIssues.single.medicineName, 'B');
      expect(result.redFlags.single.primaryMedicineName, 'C');
    });
  });
}
