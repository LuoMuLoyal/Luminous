// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_finding_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReportFindingDto _$ReportFindingDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ReportFindingDto', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['kind', 'title', 'body']);
      final val = ReportFindingDto(
        kind: $checkedConvert(
          'kind',
          (v) => $enumDecode(
            _$ReportFindingDtoKindEnumEnumMap,
            v,
            unknownValue: ReportFindingDtoKindEnum.unknownDefaultOpenApi,
          ),
        ),
        title: $checkedConvert('title', (v) => v as String),
        body: $checkedConvert('body', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$ReportFindingDtoToJson(ReportFindingDto instance) =>
    <String, dynamic>{
      'kind': _$ReportFindingDtoKindEnumEnumMap[instance.kind]!,
      'title': instance.title,
      'body': instance.body,
    };

const _$ReportFindingDtoKindEnumEnumMap = {
  ReportFindingDtoKindEnum.medication: 'medication',
  ReportFindingDtoKindEnum.hydration: 'hydration',
  ReportFindingDtoKindEnum.sleep: 'sleep',
  ReportFindingDtoKindEnum.general: 'general',
  ReportFindingDtoKindEnum.unknownDefaultOpenApi: 'unknown_default_open_api',
};
