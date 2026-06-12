// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_dashboard_data_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReportDashboardDataDto _$ReportDashboardDataDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ReportDashboardDataDto', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const [
      'range',
      'startDate',
      'endDate',
      'generatedAt',
      'score',
      'metrics',
      'trends',
      'findings',
      'patterns',
      'aiSummaryEnabled',
    ],
  );
  final val = ReportDashboardDataDto(
    range: $checkedConvert(
      'range',
      (v) => $enumDecode(
        _$ReportDashboardDataDtoRangeEnumEnumMap,
        v,
        unknownValue: ReportDashboardDataDtoRangeEnum.unknownDefaultOpenApi,
      ),
    ),
    startDate: $checkedConvert('startDate', (v) => v as String),
    endDate: $checkedConvert('endDate', (v) => v as String),
    generatedAt: $checkedConvert('generatedAt', (v) => v as String),
    score: $checkedConvert(
      'score',
      (v) => ReportDashboardScoreDto.fromJson(v as Map<String, dynamic>),
    ),
    metrics: $checkedConvert(
      'metrics',
      (v) => (v as List<dynamic>)
          .map((e) => ReportMetricDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    trends: $checkedConvert(
      'trends',
      (v) => (v as List<dynamic>)
          .map((e) => ReportTrendDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    findings: $checkedConvert(
      'findings',
      (v) => (v as List<dynamic>)
          .map((e) => ReportFindingDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    patterns: $checkedConvert(
      'patterns',
      (v) => (v as List<dynamic>)
          .map((e) => ReportPatternDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    aiSummaryEnabled: $checkedConvert('aiSummaryEnabled', (v) => v as bool),
  );
  return val;
});

Map<String, dynamic> _$ReportDashboardDataDtoToJson(
  ReportDashboardDataDto instance,
) => <String, dynamic>{
  'range': _$ReportDashboardDataDtoRangeEnumEnumMap[instance.range]!,
  'startDate': instance.startDate,
  'endDate': instance.endDate,
  'generatedAt': instance.generatedAt,
  'score': instance.score.toJson(),
  'metrics': instance.metrics.map((e) => e.toJson()).toList(),
  'trends': instance.trends.map((e) => e.toJson()).toList(),
  'findings': instance.findings.map((e) => e.toJson()).toList(),
  'patterns': instance.patterns.map((e) => e.toJson()).toList(),
  'aiSummaryEnabled': instance.aiSummaryEnabled,
};

const _$ReportDashboardDataDtoRangeEnumEnumMap = {
  ReportDashboardDataDtoRangeEnum.last7Days: 'last_7_days',
  ReportDashboardDataDtoRangeEnum.unknownDefaultOpenApi:
      'unknown_default_open_api',
};
