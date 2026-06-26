// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_detail_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationDetailDto _$NotificationDetailDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('NotificationDetailDto', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const [
      'id',
      'type',
      'title',
      'content',
      'isRead',
      'createdAt',
    ],
  );
  final val = NotificationDetailDto(
    id: $checkedConvert('id', (v) => v as String),
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
    isRead: $checkedConvert('isRead', (v) => v as bool),
    createdAt: $checkedConvert('createdAt', (v) => v as String),
    readAt: $checkedConvert('readAt', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$NotificationDetailDtoToJson(
  NotificationDetailDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'type': _$UserNotificationTypeEnumMap[instance.type]!,
  'title': instance.title,
  'content': instance.content,
  if (instance.action != null) 'action': instance.action,
  if (instance.actionPayload != null) 'actionPayload': instance.actionPayload,
  'isRead': instance.isRead,
  'createdAt': instance.createdAt,
  if (instance.readAt != null) 'readAt': instance.readAt,
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
