// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_summary_bullet_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReportSummaryBulletDto _$ReportSummaryBulletDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ReportSummaryBulletDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['kind', 'text']);
  final val = ReportSummaryBulletDto(
    kind: $checkedConvert(
      'kind',
      (v) => $enumDecode(
        _$ReportSummaryBulletDtoKindEnumEnumMap,
        v,
        unknownValue: ReportSummaryBulletDtoKindEnum.unknownDefaultOpenApi,
      ),
    ),
    text: $checkedConvert('text', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$ReportSummaryBulletDtoToJson(
  ReportSummaryBulletDto instance,
) => <String, dynamic>{
  'kind': _$ReportSummaryBulletDtoKindEnumEnumMap[instance.kind]!,
  'text': instance.text,
};

const _$ReportSummaryBulletDtoKindEnumEnumMap = {
  ReportSummaryBulletDtoKindEnum.medication: 'medication',
  ReportSummaryBulletDtoKindEnum.hydration: 'hydration',
  ReportSummaryBulletDtoKindEnum.sleep: 'sleep',
  ReportSummaryBulletDtoKindEnum.general: 'general',
  ReportSummaryBulletDtoKindEnum.unknownDefaultOpenApi:
      'unknown_default_open_api',
};
