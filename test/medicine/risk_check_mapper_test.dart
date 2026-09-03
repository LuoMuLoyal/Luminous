import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/features/medicine/data/mappers/risk_check.dart';
import 'package:luminous/features/medicine/domain/entities/risk_check.dart';

MedicineRiskCheckRecordsResponseDtoStaticResult _response({
  MedicineRiskCheckRecordsResponseDtoStaticResultOverallRiskLevelEnum level =
      MedicineRiskCheckRecordsResponseDtoStaticResultOverallRiskLevelEnum.safe,
  int score = 0,
  List<MedicineRiskCheckRecordsResponseDtoStaticResultFindingsInner> findings =
      const [],
  List<MedicineRiskCheckRecordsResponseDtoStaticResultCoverageIssuesInner>
      coverageIssues =
      const [],
  List<MedicineRiskCheckRecordsResponseDtoStaticResultRedFlagsInner> redFlags =
      const [],
  String? recommendation,
}) {
  return MedicineRiskCheckRecordsResponseDtoStaticResult(
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

MedicineRiskCheckRecordResponseDto _record({
  MedicineRiskCheckRecordResponseDtoCheckTypeEnum checkType =
      MedicineRiskCheckRecordResponseDtoCheckTypeEnum.static_,
  MedicineRiskCheckRecordResponseDtoRiskLevelEnum riskLevel =
      MedicineRiskCheckRecordResponseDtoRiskLevelEnum.safe,
  MedicineRiskCheckRecordsResponseDtoStaticResult? result,
  int score = 10,
  bool stale = false,
}) {
  return MedicineRiskCheckRecordResponseDto(
    checkType: checkType,
    result: result ?? _response(score: score),
    riskScore: score,
    riskLevel: riskLevel,
    stale: stale,
    createdAt: DateTime(2026, 7, 1),
    updatedAt: DateTime(2026, 7, 2),
  );
}

MedicineRiskCheckRecordsResponseDtoStatic _listRecord({
  MedicineRiskCheckRecordsResponseDtoStaticCheckTypeEnum checkType =
      MedicineRiskCheckRecordsResponseDtoStaticCheckTypeEnum.static_,
  MedicineRiskCheckRecordsResponseDtoStaticRiskLevelEnum riskLevel =
      MedicineRiskCheckRecordsResponseDtoStaticRiskLevelEnum.safe,
  MedicineRiskCheckRecordsResponseDtoStaticResult? result,
  int score = 10,
  bool stale = false,
}) {
  return MedicineRiskCheckRecordsResponseDtoStatic(
    checkType: checkType,
    result: result ?? _response(score: score),
    riskScore: score,
    riskLevel: riskLevel,
    stale: stale,
    createdAt: DateTime(2026, 7, 1),
    updatedAt: DateTime(2026, 7, 2),
  );
}

void main() {
  const mapper = MedicineRiskCheckMapper();

  group('recordsDtoToDomain', () {
    test('maps static + llm records', () {
      final records = mapper.recordsDtoToDomain(
        MedicineRiskCheckRecordsResponseDto(
          static_: _listRecord(
            checkType:
                MedicineRiskCheckRecordsResponseDtoStaticCheckTypeEnum.static_,
          ),
          llm: _listRecord(
            checkType:
                MedicineRiskCheckRecordsResponseDtoStaticCheckTypeEnum.llm,
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
        MedicineRiskCheckRecordsResponseDto(static_: null, llm: null),
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
          checkType: MedicineRiskCheckRecordResponseDtoCheckTypeEnum.llm,
          riskLevel: MedicineRiskCheckRecordResponseDtoRiskLevelEnum.danger,
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
          checkType: MedicineRiskCheckRecordResponseDtoCheckTypeEnum
              .unknownDefaultOpenApi,
        ),
      );
      expect(record.checkType, MedicineRiskCheckType.static_);
    });

    test('maps unknown risk level to safe', () {
      final record = mapper.recordDtoToDomain(
        _record(
          riskLevel: MedicineRiskCheckRecordResponseDtoRiskLevelEnum
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
              MedicineRiskCheckRecordsResponseDtoStaticResultOverallRiskLevelEnum
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
              MedicineRiskCheckRecordsResponseDtoStaticResultOverallRiskLevelEnum
                  .unknownDefaultOpenApi,
        ),
      );
      expect(result.overallRiskLevel, MedicineRiskLevel.safe);
    });

    test('drops unknown finding types from findings list', () {
      final result = mapper.resultDtoToDomain(
        _response(
          findings: [
            MedicineRiskCheckRecordsResponseDtoStaticResultFindingsInner(
              type:
                  MedicineRiskCheckRecordsResponseDtoStaticResultFindingsInnerTypeEnum
                      .interaction,
              severity:
                  MedicineRiskCheckRecordsResponseDtoStaticResultFindingsInnerSeverityEnum
                      .high,
              context:
                  MedicineRiskCheckRecordsResponseDtoStaticResultFindingsInnerContextEnum
                      .none,
              primaryMedicineName: '合法药',
            ),
            MedicineRiskCheckRecordsResponseDtoStaticResultFindingsInner(
              type:
                  MedicineRiskCheckRecordsResponseDtoStaticResultFindingsInnerTypeEnum
                      .unknownDefaultOpenApi,
              severity:
                  MedicineRiskCheckRecordsResponseDtoStaticResultFindingsInnerSeverityEnum
                      .medium,
              context:
                  MedicineRiskCheckRecordsResponseDtoStaticResultFindingsInnerContextEnum
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
            MedicineRiskCheckRecordsResponseDtoStaticResultFindingsInnerTypeEnum,
            MedicineRiskFindingType
          >{
            MedicineRiskCheckRecordsResponseDtoStaticResultFindingsInnerTypeEnum
                    .interaction:
                MedicineRiskFindingType.interaction,
            MedicineRiskCheckRecordsResponseDtoStaticResultFindingsInnerTypeEnum
                    .duplicateIngredient:
                MedicineRiskFindingType.duplicateIngredient,
            MedicineRiskCheckRecordsResponseDtoStaticResultFindingsInnerTypeEnum
                    .allergy:
                MedicineRiskFindingType.allergy,
            MedicineRiskCheckRecordsResponseDtoStaticResultFindingsInnerTypeEnum
                    .foodInteraction:
                MedicineRiskFindingType.foodInteraction,
            MedicineRiskCheckRecordsResponseDtoStaticResultFindingsInnerTypeEnum
                    .longTermUse:
                MedicineRiskFindingType.longTermUse,
            MedicineRiskCheckRecordsResponseDtoStaticResultFindingsInnerTypeEnum
                    .schedulingConflict:
                MedicineRiskFindingType.schedulingConflict,
            MedicineRiskCheckRecordsResponseDtoStaticResultFindingsInnerTypeEnum
                    .specialGroup:
                MedicineRiskFindingType.specialGroup,
          };

      expectedByType.forEach((dtoEnum, expected) {
        final finding = mapper.findingDtoToDomain(
          MedicineRiskCheckRecordsResponseDtoStaticResultFindingsInner(
            type: dtoEnum,
            severity:
                MedicineRiskCheckRecordsResponseDtoStaticResultFindingsInnerSeverityEnum
                    .high,
            context:
                MedicineRiskCheckRecordsResponseDtoStaticResultFindingsInnerContextEnum
                    .none,
            primaryMedicineName: '阿莫西林',
          ),
        );
        expect(finding!.type, expected, reason: 'for $dtoEnum');
      });
    });

    test('findingDtoToDomain returns null for unknown finding type', () {
      final finding = mapper.findingDtoToDomain(
        MedicineRiskCheckRecordsResponseDtoStaticResultFindingsInner(
          type:
              MedicineRiskCheckRecordsResponseDtoStaticResultFindingsInnerTypeEnum
                  .unknownDefaultOpenApi,
          severity:
              MedicineRiskCheckRecordsResponseDtoStaticResultFindingsInnerSeverityEnum
                  .medium,
          context:
              MedicineRiskCheckRecordsResponseDtoStaticResultFindingsInnerContextEnum
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
              MedicineRiskCheckRecordsResponseDtoStaticResultFindingsInner(
                type:
                    MedicineRiskCheckRecordsResponseDtoStaticResultFindingsInnerTypeEnum
                        .allergy,
                severity:
                    MedicineRiskCheckRecordsResponseDtoStaticResultFindingsInnerSeverityEnum
                        .high,
                context:
                    MedicineRiskCheckRecordsResponseDtoStaticResultFindingsInnerContextEnum
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
              MedicineRiskCheckRecordsResponseDtoStaticResultFindingsInner(
                type:
                    MedicineRiskCheckRecordsResponseDtoStaticResultFindingsInnerTypeEnum
                        .allergy,
                severity:
                    MedicineRiskCheckRecordsResponseDtoStaticResultFindingsInnerSeverityEnum
                        .medium,
                context:
                    MedicineRiskCheckRecordsResponseDtoStaticResultFindingsInnerContextEnum
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
              MedicineRiskCheckRecordsResponseDtoStaticResultFindingsInner(
                type:
                    MedicineRiskCheckRecordsResponseDtoStaticResultFindingsInnerTypeEnum
                        .allergy,
                severity:
                    MedicineRiskCheckRecordsResponseDtoStaticResultFindingsInnerSeverityEnum
                        .info,
                context:
                    MedicineRiskCheckRecordsResponseDtoStaticResultFindingsInnerContextEnum
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
              MedicineRiskCheckRecordsResponseDtoStaticResultFindingsInner(
                type:
                    MedicineRiskCheckRecordsResponseDtoStaticResultFindingsInnerTypeEnum
                        .allergy,
                severity:
                    MedicineRiskCheckRecordsResponseDtoStaticResultFindingsInnerSeverityEnum
                        .unknownDefaultOpenApi,
                context:
                    MedicineRiskCheckRecordsResponseDtoStaticResultFindingsInnerContextEnum
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
          MedicineRiskCheckRecordsResponseDtoStaticResultFindingsInnerContextEnum
              .none,
          MedicineRiskFindingContext.none,
        ),
        (
          MedicineRiskCheckRecordsResponseDtoStaticResultFindingsInnerContextEnum
              .alcohol,
          MedicineRiskFindingContext.alcohol,
        ),
        (
          MedicineRiskCheckRecordsResponseDtoStaticResultFindingsInnerContextEnum
              .caffeine,
          MedicineRiskFindingContext.caffeine,
        ),
      ]) {
        final finding = mapper.findingDtoToDomain(
          MedicineRiskCheckRecordsResponseDtoStaticResultFindingsInner(
            type:
                MedicineRiskCheckRecordsResponseDtoStaticResultFindingsInnerTypeEnum
                    .allergy,
            severity:
                MedicineRiskCheckRecordsResponseDtoStaticResultFindingsInnerSeverityEnum
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
          MedicineRiskCheckRecordsResponseDtoStaticResultCoverageIssuesInnerReasonEnum
              .manualEntry,
          MedicineRiskCoverageReason.manualEntry,
        ),
        (
          MedicineRiskCheckRecordsResponseDtoStaticResultCoverageIssuesInnerReasonEnum
              .missingSourceRef,
          MedicineRiskCoverageReason.missingSourceRef,
        ),
        (
          MedicineRiskCheckRecordsResponseDtoStaticResultCoverageIssuesInnerReasonEnum
              .detailUnavailable,
          MedicineRiskCoverageReason.detailUnavailable,
        ),
        (
          MedicineRiskCheckRecordsResponseDtoStaticResultCoverageIssuesInnerReasonEnum
              .unknownDefaultOpenApi,
          MedicineRiskCoverageReason.detailUnavailable,
        ),
      ]) {
        final issue = mapper.coverageIssueDtoToDomain(
          MedicineRiskCheckRecordsResponseDtoStaticResultCoverageIssuesInner(
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
          MedicineRiskCheckRecordsResponseDtoStaticResultRedFlagsInnerRuleEnum
              .severeAllergy,
          RedFlagRule.severeAllergy,
        ),
        (
          MedicineRiskCheckRecordsResponseDtoStaticResultRedFlagsInnerRuleEnum
              .informationGap,
          RedFlagRule.informationGap,
        ),
        (
          MedicineRiskCheckRecordsResponseDtoStaticResultRedFlagsInnerRuleEnum
              .unknownDefaultOpenApi,
          RedFlagRule.informationGap,
        ),
      ]) {
        final alert = mapper.redFlagDtoToDomain(
          MedicineRiskCheckRecordsResponseDtoStaticResultRedFlagsInner(
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
        MedicinesControllerRunRiskCheckV1RequestTypeEnum.static_,
      );
      expect(
        mapper.checkTypeToDto(MedicineRiskCheckType.llm).type,
        MedicinesControllerRunRiskCheckV1RequestTypeEnum.llm,
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
        MedicinesControllerRunRiskCheckV1RequestTypeEnum.static_,
      );
      expect(dto.candidate, isNotNull);
      expect(
        dto.candidate!.source_,
        MedicinesControllerRunRiskCheckV1RequestCandidateSource_Enum.cn,
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
        MedicinesControllerRunRiskCheckV1RequestTypeEnum.static_,
      );
      expect(
        dto.candidate!.source_,
        MedicinesControllerRunRiskCheckV1RequestCandidateSource_Enum.drugbank,
      );
      expect(dto.candidate!.id, 'DB01050');
    });

    test('falls back to unknown source enum for unsupported sources', () {
      final dto = mapper.precheckToDto(source: 'other', sourceRefId: 'x');

      expect(
        dto.candidate!.source_,
        MedicinesControllerRunRiskCheckV1RequestCandidateSource_Enum
            .unknownDefaultOpenApi,
      );
    });
  });

  group('full result mapping', () {
    test('maps finding, coverage and red flag lists', () {
      final result = mapper.resultDtoToDomain(
        _response(
          level:
              MedicineRiskCheckRecordsResponseDtoStaticResultOverallRiskLevelEnum
                  .risk,
          findings: [
            MedicineRiskCheckRecordsResponseDtoStaticResultFindingsInner(
              type:
                  MedicineRiskCheckRecordsResponseDtoStaticResultFindingsInnerTypeEnum
                      .interaction,
              severity:
                  MedicineRiskCheckRecordsResponseDtoStaticResultFindingsInnerSeverityEnum
                      .high,
              context:
                  MedicineRiskCheckRecordsResponseDtoStaticResultFindingsInnerContextEnum
                      .none,
              primaryMedicineName: 'A',
            ),
          ],
          coverageIssues: [
            MedicineRiskCheckRecordsResponseDtoStaticResultCoverageIssuesInner(
              medicineName: 'B',
              reason:
                  MedicineRiskCheckRecordsResponseDtoStaticResultCoverageIssuesInnerReasonEnum
                      .manualEntry,
            ),
          ],
          redFlags: [
            MedicineRiskCheckRecordsResponseDtoStaticResultRedFlagsInner(
              rule:
                  MedicineRiskCheckRecordsResponseDtoStaticResultRedFlagsInnerRuleEnum
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
