// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_user_settings_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateUserSettingsDto _$UpdateUserSettingsDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('UpdateUserSettingsDto', json, ($checkedConvert) {
  final val = UpdateUserSettingsDto(
    aiSummariesEnabled: $checkedConvert(
      'aiSummariesEnabled',
      (v) => v as bool?,
    ),
    dataSharingConsent: $checkedConvert(
      'dataSharingConsent',
      (v) => v as bool?,
    ),
    aiChatEnabled: $checkedConvert('aiChatEnabled', (v) => v as bool?),
    aiChatMemoryEnabled: $checkedConvert(
      'aiChatMemoryEnabled',
      (v) => v as bool?,
    ),
    aiChatContext: $checkedConvert(
      'aiChatContext',
      (v) => v == null
          ? null
          : UpdateAiChatContextSettingsDto.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$UpdateUserSettingsDtoToJson(
  UpdateUserSettingsDto instance,
) => <String, dynamic>{
  if (instance.aiSummariesEnabled != null)
    'aiSummariesEnabled': instance.aiSummariesEnabled,
  if (instance.dataSharingConsent != null)
    'dataSharingConsent': instance.dataSharingConsent,
  if (instance.aiChatEnabled != null) 'aiChatEnabled': instance.aiChatEnabled,
  if (instance.aiChatMemoryEnabled != null)
    'aiChatMemoryEnabled': instance.aiChatMemoryEnabled,
  if (instance.aiChatContext?.toJson() != null)
    'aiChatContext': instance.aiChatContext?.toJson(),
};
