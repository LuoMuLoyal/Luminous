// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_notification_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateNotificationDto _$CreateNotificationDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('CreateNotificationDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['type', 'title', 'content']);
  final val = CreateNotificationDto(
    type: $checkedConvert(
      'type',
      (v) => $enumDecode(
        _$UserNotificationTypeEnumMap,
        v,
        unknownValue: UserNotificationType.unknownDefaultOpenApi,
      ),
    ),
    title: $checkedConvert('title', (v) => v as String),
    content: $checkedConvert('content', (v) => v as String),
    action: $checkedConvert('action', (v) => v as String?),
    actionPayload: $checkedConvert('actionPayload', (v) => v),
  );
  return val;
});

Map<String, dynamic> _$CreateNotificationDtoToJson(
  CreateNotificationDto instance,
) => <String, dynamic>{
  'type': _$UserNotificationTypeEnumMap[instance.type]!,
  'title': instance.title,
  'content': instance.content,
  if (instance.action != null) 'action': instance.action,
  if (instance.actionPayload != null) 'actionPayload': instance.actionPayload,
};

const _$UserNotificationTypeEnumMap = {
  UserNotificationType.aiTodaySummary: 'ai_today_summary',
  UserNotificationType.aiProactiveSuggestion: 'ai_proactive_suggestion',
  UserNotificationType.medicineMissedDose: 'medicine_missed_dose',
  UserNotificationType.passwordChanged: 'password_changed',
  UserNotificationType.reportGenerated: 'report_generated',
  UserNotificationType.medicineReminder: 'medicine_reminder',
  UserNotificationType.systemAnnouncement: 'system_announcement',
  UserNotificationType.unknownDefaultOpenApi: 'unknown_default_open_api',
};
