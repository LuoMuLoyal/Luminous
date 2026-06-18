// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assistant_context_settings_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssistantContextSettingsDto _$AssistantContextSettingsDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AssistantContextSettingsDto', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const [
      'healthProfile',
      'dailyRecords',
      'sleepRecords',
      'currentMedicines',
    ],
  );
  final val = AssistantContextSettingsDto(
    healthProfile: $checkedConvert('healthProfile', (v) => v as bool),
    dailyRecords: $checkedConvert('dailyRecords', (v) => v as bool),
    sleepRecords: $checkedConvert('sleepRecords', (v) => v as bool),
    currentMedicines: $checkedConvert('currentMedicines', (v) => v as bool),
  );
  return val;
});

Map<String, dynamic> _$AssistantContextSettingsDtoToJson(
  AssistantContextSettingsDto instance,
) => <String, dynamic>{
  'healthProfile': instance.healthProfile,
  'dailyRecords': instance.dailyRecords,
  'sleepRecords': instance.sleepRecords,
  'currentMedicines': instance.currentMedicines,
};
