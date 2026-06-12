// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_trend_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReportTrendDto _$ReportTrendDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ReportTrendDto', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['kind', 'unit', 'currentValue', 'values'],
      );
      final val = ReportTrendDto(
        kind: $checkedConvert(
          'kind',
          (v) => $enumDecode(
            _$ReportTrendDtoKindEnumEnumMap,
            v,
            unknownValue: ReportTrendDtoKindEnum.unknownDefaultOpenApi,
          ),
        ),
        unit: $checkedConvert('unit', (v) => v as String),
        currentValue: $checkedConvert('currentValue', (v) => v as String),
        values: $checkedConvert(
          'values',
          (v) => (v as List<dynamic>).map((e) => e as num).toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$ReportTrendDtoToJson(ReportTrendDto instance) =>
    <String, dynamic>{
      'kind': _$ReportTrendDtoKindEnumEnumMap[instance.kind]!,
      'unit': instance.unit,
      'currentValue': instance.currentValue,
      'values': instance.values,
    };

const _$ReportTrendDtoKindEnumEnumMap = {
  ReportTrendDtoKindEnum.medication: 'medication',
  ReportTrendDtoKindEnum.water: 'water',
  ReportTrendDtoKindEnum.sleep: 'sleep',
  ReportTrendDtoKindEnum.unknownDefaultOpenApi: 'unknown_default_open_api',
};
