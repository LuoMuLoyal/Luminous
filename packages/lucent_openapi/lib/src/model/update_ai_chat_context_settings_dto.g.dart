// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_ai_chat_context_settings_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateAiChatContextSettingsDto _$UpdateAiChatContextSettingsDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('UpdateAiChatContextSettingsDto', json, ($checkedConvert) {
  final val = UpdateAiChatContextSettingsDto(
    healthProfile: $checkedConvert('healthProfile', (v) => v as bool?),
    dailyRecords: $checkedConvert('dailyRecords', (v) => v as bool?),
    sleepRecords: $checkedConvert('sleepRecords', (v) => v as bool?),
    currentMedicines: $checkedConvert('currentMedicines', (v) => v as bool?),
  );
  return val;
});

Map<String, dynamic> _$UpdateAiChatContextSettingsDtoToJson(
  UpdateAiChatContextSettingsDto instance,
) => <String, dynamic>{
  if (instance.healthProfile != null) 'healthProfile': instance.healthProfile,
  if (instance.dailyRecords != null) 'dailyRecords': instance.dailyRecords,
  if (instance.sleepRecords != null) 'sleepRecords': instance.sleepRecords,
  if (instance.currentMedicines != null)
    'currentMedicines': instance.currentMedicines,
};
