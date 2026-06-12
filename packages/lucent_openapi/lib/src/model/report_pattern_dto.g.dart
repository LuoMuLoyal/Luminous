// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_pattern_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReportPatternDto _$ReportPatternDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ReportPatternDto', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['kind', 'title', 'status', 'body', 'sparkline'],
      );
      final val = ReportPatternDto(
        kind: $checkedConvert(
          'kind',
          (v) => $enumDecode(
            _$ReportPatternDtoKindEnumEnumMap,
            v,
            unknownValue: ReportPatternDtoKindEnum.unknownDefaultOpenApi,
          ),
        ),
        title: $checkedConvert('title', (v) => v as String),
        status: $checkedConvert(
          'status',
          (v) => $enumDecode(
            _$ReportPatternDtoStatusEnumEnumMap,
            v,
            unknownValue: ReportPatternDtoStatusEnum.unknownDefaultOpenApi,
          ),
        ),
        body: $checkedConvert('body', (v) => v as String),
        sparkline: $checkedConvert(
          'sparkline',
          (v) => (v as List<dynamic>).map((e) => e as num).toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$ReportPatternDtoToJson(ReportPatternDto instance) =>
    <String, dynamic>{
      'kind': _$ReportPatternDtoKindEnumEnumMap[instance.kind]!,
      'title': instance.title,
      'status': _$ReportPatternDtoStatusEnumEnumMap[instance.status]!,
      'body': instance.body,
      'sparkline': instance.sparkline,
    };

const _$ReportPatternDtoKindEnumEnumMap = {
  ReportPatternDtoKindEnum.medication: 'medication',
  ReportPatternDtoKindEnum.hydration: 'hydration',
  ReportPatternDtoKindEnum.sleep: 'sleep',
  ReportPatternDtoKindEnum.general: 'general',
  ReportPatternDtoKindEnum.unknownDefaultOpenApi: 'unknown_default_open_api',
};

const _$ReportPatternDtoStatusEnumEnumMap = {
  ReportPatternDtoStatusEnum.good: 'good',
  ReportPatternDtoStatusEnum.stable: 'stable',
  ReportPatternDtoStatusEnum.needsAttention: 'needs_attention',
  ReportPatternDtoStatusEnum.insufficientData: 'insufficient_data',
  ReportPatternDtoStatusEnum.unknownDefaultOpenApi: 'unknown_default_open_api',
};
