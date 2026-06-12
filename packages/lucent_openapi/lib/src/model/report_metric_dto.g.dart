// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_metric_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReportMetricDto _$ReportMetricDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ReportMetricDto', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'kind',
          'value',
          'unit',
          'status',
          'delta',
          'direction',
          'sparkline',
        ],
      );
      final val = ReportMetricDto(
        kind: $checkedConvert(
          'kind',
          (v) => $enumDecode(
            _$ReportMetricDtoKindEnumEnumMap,
            v,
            unknownValue: ReportMetricDtoKindEnum.unknownDefaultOpenApi,
          ),
        ),
        value: $checkedConvert('value', (v) => v as String),
        unit: $checkedConvert('unit', (v) => v as String),
        status: $checkedConvert(
          'status',
          (v) => $enumDecode(
            _$ReportMetricDtoStatusEnumEnumMap,
            v,
            unknownValue: ReportMetricDtoStatusEnum.unknownDefaultOpenApi,
          ),
        ),
        delta: $checkedConvert('delta', (v) => v as String),
        direction: $checkedConvert(
          'direction',
          (v) => $enumDecode(
            _$ReportMetricDtoDirectionEnumEnumMap,
            v,
            unknownValue: ReportMetricDtoDirectionEnum.unknownDefaultOpenApi,
          ),
        ),
        sparkline: $checkedConvert(
          'sparkline',
          (v) => (v as List<dynamic>).map((e) => e as num).toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$ReportMetricDtoToJson(ReportMetricDto instance) =>
    <String, dynamic>{
      'kind': _$ReportMetricDtoKindEnumEnumMap[instance.kind]!,
      'value': instance.value,
      'unit': instance.unit,
      'status': _$ReportMetricDtoStatusEnumEnumMap[instance.status]!,
      'delta': instance.delta,
      'direction': _$ReportMetricDtoDirectionEnumEnumMap[instance.direction]!,
      'sparkline': instance.sparkline,
    };

const _$ReportMetricDtoKindEnumEnumMap = {
  ReportMetricDtoKindEnum.medication: 'medication',
  ReportMetricDtoKindEnum.water: 'water',
  ReportMetricDtoKindEnum.sleep: 'sleep',
  ReportMetricDtoKindEnum.unknownDefaultOpenApi: 'unknown_default_open_api',
};

const _$ReportMetricDtoStatusEnumEnumMap = {
  ReportMetricDtoStatusEnum.good: 'good',
  ReportMetricDtoStatusEnum.stable: 'stable',
  ReportMetricDtoStatusEnum.needsAttention: 'needs_attention',
  ReportMetricDtoStatusEnum.insufficientData: 'insufficient_data',
  ReportMetricDtoStatusEnum.unknownDefaultOpenApi: 'unknown_default_open_api',
};

const _$ReportMetricDtoDirectionEnumEnumMap = {
  ReportMetricDtoDirectionEnum.up: 'up',
  ReportMetricDtoDirectionEnum.down: 'down',
  ReportMetricDtoDirectionEnum.flat: 'flat',
  ReportMetricDtoDirectionEnum.unknownDefaultOpenApi:
      'unknown_default_open_api',
};
