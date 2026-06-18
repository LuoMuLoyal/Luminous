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
    assistantEnabled: $checkedConvert('assistantEnabled', (v) => v as bool?),
    assistantMemoryEnabled: $checkedConvert(
      'assistantMemoryEnabled',
      (v) => v as bool?,
    ),
    assistantContext: $checkedConvert(
      'assistantContext',
      (v) => v == null
          ? null
          : UpdateAssistantContextSettingsDto.fromJson(
              v as Map<String, dynamic>,
            ),
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
  if (instance.assistantEnabled != null)
    'assistantEnabled': instance.assistantEnabled,
  if (instance.assistantMemoryEnabled != null)
    'assistantMemoryEnabled': instance.assistantMemoryEnabled,
  if (instance.assistantContext?.toJson() != null)
    'assistantContext': instance.assistantContext?.toJson(),
};
