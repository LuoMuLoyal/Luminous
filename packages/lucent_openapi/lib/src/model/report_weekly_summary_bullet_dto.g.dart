// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_weekly_summary_bullet_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReportWeeklySummaryBulletDto _$ReportWeeklySummaryBulletDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ReportWeeklySummaryBulletDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['kind', 'text']);
  final val = ReportWeeklySummaryBulletDto(
    kind: $checkedConvert(
      'kind',
      (v) => $enumDecode(
        _$ReportWeeklySummaryBulletDtoKindEnumEnumMap,
        v,
        unknownValue:
            ReportWeeklySummaryBulletDtoKindEnum.unknownDefaultOpenApi,
      ),
    ),
    text: $checkedConvert('text', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$ReportWeeklySummaryBulletDtoToJson(
  ReportWeeklySummaryBulletDto instance,
) => <String, dynamic>{
  'kind': _$ReportWeeklySummaryBulletDtoKindEnumEnumMap[instance.kind]!,
  'text': instance.text,
};

const _$ReportWeeklySummaryBulletDtoKindEnumEnumMap = {
  ReportWeeklySummaryBulletDtoKindEnum.medication: 'medication',
  ReportWeeklySummaryBulletDtoKindEnum.hydration: 'hydration',
  ReportWeeklySummaryBulletDtoKindEnum.sleep: 'sleep',
  ReportWeeklySummaryBulletDtoKindEnum.general: 'general',
  ReportWeeklySummaryBulletDtoKindEnum.unknownDefaultOpenApi:
      'unknown_default_open_api',
};
