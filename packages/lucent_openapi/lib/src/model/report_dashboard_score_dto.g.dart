// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_dashboard_score_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReportDashboardScoreDto _$ReportDashboardScoreDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ReportDashboardScoreDto', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const ['value', 'maxValue', 'status', 'summary'],
  );
  final val = ReportDashboardScoreDto(
    value: $checkedConvert('value', (v) => v as num),
    maxValue: $checkedConvert('maxValue', (v) => v as num),
    status: $checkedConvert(
      'status',
      (v) => $enumDecode(
        _$ReportDashboardScoreDtoStatusEnumEnumMap,
        v,
        unknownValue: ReportDashboardScoreDtoStatusEnum.unknownDefaultOpenApi,
      ),
    ),
    summary: $checkedConvert('summary', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$ReportDashboardScoreDtoToJson(
  ReportDashboardScoreDto instance,
) => <String, dynamic>{
  'value': instance.value,
  'maxValue': instance.maxValue,
  'status': _$ReportDashboardScoreDtoStatusEnumEnumMap[instance.status]!,
  'summary': instance.summary,
};

const _$ReportDashboardScoreDtoStatusEnumEnumMap = {
  ReportDashboardScoreDtoStatusEnum.good: 'good',
  ReportDashboardScoreDtoStatusEnum.stable: 'stable',
  ReportDashboardScoreDtoStatusEnum.needsAttention: 'needs_attention',
  ReportDashboardScoreDtoStatusEnum.insufficientData: 'insufficient_data',
  ReportDashboardScoreDtoStatusEnum.unknownDefaultOpenApi:
      'unknown_default_open_api',
};
