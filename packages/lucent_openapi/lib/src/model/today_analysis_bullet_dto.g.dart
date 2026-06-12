// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'today_analysis_bullet_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TodayAnalysisBulletDto _$TodayAnalysisBulletDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('TodayAnalysisBulletDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['kind', 'text']);
  final val = TodayAnalysisBulletDto(
    kind: $checkedConvert(
      'kind',
      (v) => $enumDecode(
        _$TodayAnalysisBulletDtoKindEnumEnumMap,
        v,
        unknownValue: TodayAnalysisBulletDtoKindEnum.unknownDefaultOpenApi,
      ),
    ),
    text: $checkedConvert('text', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$TodayAnalysisBulletDtoToJson(
  TodayAnalysisBulletDto instance,
) => <String, dynamic>{
  'kind': _$TodayAnalysisBulletDtoKindEnumEnumMap[instance.kind]!,
  'text': instance.text,
};

const _$TodayAnalysisBulletDtoKindEnumEnumMap = {
  TodayAnalysisBulletDtoKindEnum.medication: 'medication',
  TodayAnalysisBulletDtoKindEnum.hydration: 'hydration',
  TodayAnalysisBulletDtoKindEnum.sleep: 'sleep',
  TodayAnalysisBulletDtoKindEnum.general: 'general',
  TodayAnalysisBulletDtoKindEnum.unknownDefaultOpenApi:
      'unknown_default_open_api',
};
