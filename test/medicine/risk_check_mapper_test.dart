import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/features/medicine/data/mappers/risk_check.dart';
import 'package:luminous/features/medicine/domain/entities/risk_check.dart';

MedicineRiskCheckResponseDto _response({
  MedicineRiskCheckResponseDtoOverallRiskLevelEnum level =
      MedicineRiskCheckResponseDtoOverallRiskLevelEnum.safe,
  int score = 0,
  List<MedicineRiskFindingDto> findings = const [],
  List<MedicineRiskCoverageIssueDto> coverageIssues = const [],
  List<MedicineRedFlagDto> redFlags = const [],
  String? recommendation,
}) {
  return MedicineRiskCheckResponseDto(
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

MedicineRiskCheckRecordDto _record({
  MedicineRiskCheckRecordDtoCheckTypeEnum checkType =
      MedicineRiskCheckRecordDtoCheckTypeEnum.static_,
  MedicineRiskCheckRecordDtoRiskLevelEnum riskLevel =
      MedicineRiskCheckRecordDtoRiskLevelEnum.safe,
  MedicineRiskCheckResponseDto? result,
  int score = 10,
  bool stale = false,
}) {
  return MedicineRiskCheckRecordDto(
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
        MedicineRiskCheckRecordsDto(
          static_: _record(
            checkType: MedicineRiskCheckRecordDtoCheckTypeEnum.static_,
          ),
          llm: _record(checkType: MedicineRiskCheckRecordDtoCheckTypeEnum.llm),
        ),
      );

      expect(records.staticRecord, isNotNull);
      expect(records.llmRecord, isNotNull);
      expect(records.bestRecord?.checkType, MedicineRiskCheckType.llm);
      expect(records.isEmpty, isFalse);
    });

    test('handles null records', () {
      final records = mapper.recordsDtoToDomain(
        MedicineRiskCheckRecordsDto(static_: null, llm: null),
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
          checkType: MedicineRiskCheckRecordDtoCheckTypeEnum.llm,
          riskLevel: MedicineRiskCheckRecordDtoRiskLevelEnum.danger,
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
          checkType:
              MedicineRiskCheckRecordDtoCheckTypeEnum.unknownDefaultOpenApi,
        ),
      );
      expect(record.checkType, MedicineRiskCheckType.static_);
    });

    test('maps unknown risk level to safe', () {
      final record = mapper.recordDtoToDomain(
        _record(
          riskLevel:
              MedicineRiskCheckRecordDtoRiskLevelEnum.unknownDefaultOpenApi,
        ),
      );
      expect(record.riskLevel, MedicineRiskLevel.safe);
    });
  });

  group('responseDtoToDomain', () {
    test('maps all risk levels and fields', () {
      final result = mapper.responseDtoToDomain(
        _response(
          level: MedicineRiskCheckResponseDtoOverallRiskLevelEnum.caution,
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
      final result = mapper.responseDtoToDomain(
        _response(
          level: MedicineRiskCheckResponseDtoOverallRiskLevelEnum
              .unknownDefaultOpenApi,
        ),
      );
      expect(result.overallRiskLevel, MedicineRiskLevel.safe);
    });

    test('drops unknown finding types from findings list', () {
      final result = mapper.responseDtoToDomain(
        _response(
          findings: [
            MedicineRiskFindingDto(
              type: MedicineRiskFindingDtoTypeEnum.interaction,
              severity: MedicineRiskFindingDtoSeverityEnum.high,
              context: MedicineRiskFindingDtoContextEnum.none,
              primaryMedicineName: '合法药',
            ),
            MedicineRiskFindingDto(
              type: MedicineRiskFindingDtoTypeEnum.unknownDefaultOpenApi,
              severity: MedicineRiskFindingDtoSeverityEnum.medium,
              context: MedicineRiskFindingDtoContextEnum.alcohol,
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
      final cases = <(MedicineRiskFindingDtoTypeEnum, MedicineRiskFindingType)>[
        (
          MedicineRiskFindingDtoTypeEnum.interaction,
          MedicineRiskFindingType.interaction,
        ),
        (
          MedicineRiskFindingDtoTypeEnum.duplicateIngredient,
          MedicineRiskFindingType.duplicateIngredient,
        ),
        (
          MedicineRiskFindingDtoTypeEnum.allergy,
          MedicineRiskFindingType.allergy,
        ),
        (
          MedicineRiskFindingDtoTypeEnum.foodInteraction,
          MedicineRiskFindingType.foodInteraction,
        ),
        (
          MedicineRiskFindingDtoTypeEnum.longTermUse,
          MedicineRiskFindingType.longTermUse,
        ),
        (
          MedicineRiskFindingDtoTypeEnum.schedulingConflict,
          MedicineRiskFindingType.schedulingConflict,
        ),
        (
          MedicineRiskFindingDtoTypeEnum.specialGroup,
          MedicineRiskFindingType.specialGroup,
        ),
      ];

      for (final (dtoEnum, expected) in cases) {
        final finding = mapper.findingDtoToDomain(
          MedicineRiskFindingDto(
            type: dtoEnum,
            severity: MedicineRiskFindingDtoSeverityEnum.high,
            context: MedicineRiskFindingDtoContextEnum.none,
            primaryMedicineName: '阿莫西林',
          ),
        );
        expect(finding!.type, expected, reason: 'for $dtoEnum');
      }
    });

    test('findingDtoToDomain returns null for unknown finding type', () {
      final finding = mapper.findingDtoToDomain(
        MedicineRiskFindingDto(
          type: MedicineRiskFindingDtoTypeEnum.unknownDefaultOpenApi,
          severity: MedicineRiskFindingDtoSeverityEnum.medium,
          context: MedicineRiskFindingDtoContextEnum.alcohol,
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
              MedicineRiskFindingDto(
                type: MedicineRiskFindingDtoTypeEnum.allergy,
                severity: MedicineRiskFindingDtoSeverityEnum.high,
                context: MedicineRiskFindingDtoContextEnum.none,
                primaryMedicineName: '药',
              ),
            )!
            .severity,
        MedicineRiskSeverity.high,
      );
      expect(
        mapper
            .findingDtoToDomain(
              MedicineRiskFindingDto(
                type: MedicineRiskFindingDtoTypeEnum.allergy,
                severity: MedicineRiskFindingDtoSeverityEnum.medium,
                context: MedicineRiskFindingDtoContextEnum.none,
                primaryMedicineName: '药',
              ),
            )!
            .severity,
        MedicineRiskSeverity.medium,
      );
      expect(
        mapper
            .findingDtoToDomain(
              MedicineRiskFindingDto(
                type: MedicineRiskFindingDtoTypeEnum.allergy,
                severity: MedicineRiskFindingDtoSeverityEnum.info,
                context: MedicineRiskFindingDtoContextEnum.none,
                primaryMedicineName: '药',
              ),
            )!
            .severity,
        MedicineRiskSeverity.info,
      );
      expect(
        mapper
            .findingDtoToDomain(
              MedicineRiskFindingDto(
                type: MedicineRiskFindingDtoTypeEnum.allergy,
                severity:
                    MedicineRiskFindingDtoSeverityEnum.unknownDefaultOpenApi,
                context: MedicineRiskFindingDtoContextEnum.none,
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
          MedicineRiskFindingDtoContextEnum.none,
          MedicineRiskFindingContext.none,
        ),
        (
          MedicineRiskFindingDtoContextEnum.alcohol,
          MedicineRiskFindingContext.alcohol,
        ),
        (
          MedicineRiskFindingDtoContextEnum.caffeine,
          MedicineRiskFindingContext.caffeine,
        ),
      ]) {
        final finding = mapper.findingDtoToDomain(
          MedicineRiskFindingDto(
            type: MedicineRiskFindingDtoTypeEnum.allergy,
            severity: MedicineRiskFindingDtoSeverityEnum.high,
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
          MedicineRiskCoverageIssueDtoReasonEnum.manualEntry,
          MedicineRiskCoverageReason.manualEntry,
        ),
        (
          MedicineRiskCoverageIssueDtoReasonEnum.missingSourceRef,
          MedicineRiskCoverageReason.missingSourceRef,
        ),
        (
          MedicineRiskCoverageIssueDtoReasonEnum.detailUnavailable,
          MedicineRiskCoverageReason.detailUnavailable,
        ),
        (
          MedicineRiskCoverageIssueDtoReasonEnum.unknownDefaultOpenApi,
          MedicineRiskCoverageReason.detailUnavailable,
        ),
      ]) {
        final issue = mapper.coverageIssueDtoToDomain(
          MedicineRiskCoverageIssueDto(medicineName: '药X', reason: dtoEnum),
        );
        expect(issue.medicineName, '药X');
        expect(issue.reason, expected, reason: 'for $dtoEnum');
      }
    });
  });

  group('redFlagDtoToDomain', () {
    test('maps all rules', () {
      for (final (dtoEnum, expected) in [
        (MedicineRedFlagDtoRuleEnum.severeAllergy, RedFlagRule.severeAllergy),
        (MedicineRedFlagDtoRuleEnum.informationGap, RedFlagRule.informationGap),
        (
          MedicineRedFlagDtoRuleEnum.unknownDefaultOpenApi,
          RedFlagRule.informationGap,
        ),
      ]) {
        final alert = mapper.redFlagDtoToDomain(
          MedicineRedFlagDto(
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
        RunRiskCheckDtoTypeEnum.static_,
      );
      expect(
        mapper.checkTypeToDto(MedicineRiskCheckType.llm).type,
        RunRiskCheckDtoTypeEnum.llm,
      );
    });
  });

  group('full result mapping', () {
    test('maps finding, coverage and red flag lists', () {
      final result = mapper.responseDtoToDomain(
        _response(
          level: MedicineRiskCheckResponseDtoOverallRiskLevelEnum.risk,
          findings: [
            MedicineRiskFindingDto(
              type: MedicineRiskFindingDtoTypeEnum.interaction,
              severity: MedicineRiskFindingDtoSeverityEnum.high,
              context: MedicineRiskFindingDtoContextEnum.none,
              primaryMedicineName: 'A',
            ),
          ],
          coverageIssues: [
            MedicineRiskCoverageIssueDto(
              medicineName: 'B',
              reason: MedicineRiskCoverageIssueDtoReasonEnum.manualEntry,
            ),
          ],
          redFlags: [
            MedicineRedFlagDto(
              rule: MedicineRedFlagDtoRuleEnum.severeAllergy,
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
