// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_chat_context_settings_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AiChatContextSettingsDto _$AiChatContextSettingsDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AiChatContextSettingsDto', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const [
      'healthProfile',
      'dailyRecords',
      'sleepRecords',
      'currentMedicines',
    ],
  );
  final val = AiChatContextSettingsDto(
    healthProfile: $checkedConvert('healthProfile', (v) => v as bool),
    dailyRecords: $checkedConvert('dailyRecords', (v) => v as bool),
    sleepRecords: $checkedConvert('sleepRecords', (v) => v as bool),
    currentMedicines: $checkedConvert('currentMedicines', (v) => v as bool),
  );
  return val;
});

Map<String, dynamic> _$AiChatContextSettingsDtoToJson(
  AiChatContextSettingsDto instance,
) => <String, dynamic>{
  'healthProfile': instance.healthProfile,
  'dailyRecords': instance.dailyRecords,
  'sleepRecords': instance.sleepRecords,
  'currentMedicines': instance.currentMedicines,
};
