// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_settings_data_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserSettingsDataDto _$UserSettingsDataDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('UserSettingsDataDto', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const [
      'aiSummariesEnabled',
      'dataSharingConsent',
      'aiChatEnabled',
      'aiChatMemoryEnabled',
      'aiChatContext',
      'updatedAt',
    ],
  );
  final val = UserSettingsDataDto(
    aiSummariesEnabled: $checkedConvert('aiSummariesEnabled', (v) => v as bool),
    dataSharingConsent: $checkedConvert('dataSharingConsent', (v) => v as bool),
    aiChatEnabled: $checkedConvert('aiChatEnabled', (v) => v as bool),
    aiChatMemoryEnabled: $checkedConvert(
      'aiChatMemoryEnabled',
      (v) => v as bool,
    ),
    aiChatContext: $checkedConvert(
      'aiChatContext',
      (v) => AiChatContextSettingsDto.fromJson(v as Map<String, dynamic>),
    ),
    updatedAt: $checkedConvert('updatedAt', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$UserSettingsDataDtoToJson(
  UserSettingsDataDto instance,
) => <String, dynamic>{
  'aiSummariesEnabled': instance.aiSummariesEnabled,
  'dataSharingConsent': instance.dataSharingConsent,
  'aiChatEnabled': instance.aiChatEnabled,
  'aiChatMemoryEnabled': instance.aiChatMemoryEnabled,
  'aiChatContext': instance.aiChatContext.toJson(),
  'updatedAt': instance.updatedAt,
};
