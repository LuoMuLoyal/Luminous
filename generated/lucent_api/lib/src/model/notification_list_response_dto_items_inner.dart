//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'notification_list_response_dto_items_inner.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class NotificationListResponseDtoItemsInner {
  /// Returns a new [NotificationListResponseDtoItemsInner] instance.
  NotificationListResponseDtoItemsInner({
    required this.id,

    required this.type,

    required this.title,

    required this.content,

    required this.action,

    required this.actionPayload,

    required this.isRead,

    required this.createdAt,
  });

  /// Unique notification identifier.
  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(
    name: r'type',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        NotificationListResponseDtoItemsInnerTypeEnum.unknownDefaultOpenApi,
  )
  final NotificationListResponseDtoItemsInnerTypeEnum type;

  /// Notification title.
  @JsonKey(name: r'title', required: true, includeIfNull: false)
  final String title;

  /// Notification content body.
  @JsonKey(name: r'content', required: true, includeIfNull: false)
  final String content;

  @JsonKey(name: r'action', required: true, includeIfNull: true)
  final String? action;

  @JsonKey(name: r'actionPayload', required: true, includeIfNull: true)
  final Object? actionPayload;

  /// Whether the notification has been read.
  @JsonKey(name: r'isRead', required: true, includeIfNull: false)
  final bool isRead;

  /// ISO-8601 timestamp when the notification was created.
  @JsonKey(name: r'createdAt', required: true, includeIfNull: false)
  final String createdAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationListResponseDtoItemsInner &&
          other.id == id &&
          other.type == type &&
          other.title == title &&
          other.content == content &&
          other.action == action &&
          other.actionPayload == actionPayload &&
          other.isRead == isRead &&
          other.createdAt == createdAt;

  @override
  int get hashCode =>
      id.hashCode +
      type.hashCode +
      title.hashCode +
      content.hashCode +
      (action == null ? 0 : action.hashCode) +
      (actionPayload == null ? 0 : actionPayload.hashCode) +
      isRead.hashCode +
      createdAt.hashCode;

  factory NotificationListResponseDtoItemsInner.fromJson(
    Map<String, dynamic> json,
  ) => _$NotificationListResponseDtoItemsInnerFromJson(json);

  Map<String, dynamic> toJson() =>
      _$NotificationListResponseDtoItemsInnerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum NotificationListResponseDtoItemsInnerTypeEnum {
  @JsonValue(r'ai_today_summary')
  aiTodaySummary(r'ai_today_summary'),
  @JsonValue(r'ai_weekly_insight')
  aiWeeklyInsight(r'ai_weekly_insight'),
  @JsonValue(r'ai_proactive_suggestion')
  aiProactiveSuggestion(r'ai_proactive_suggestion'),
  @JsonValue(r'medicine_missed_dose')
  medicineMissedDose(r'medicine_missed_dose'),
  @JsonValue(r'password_changed')
  passwordChanged(r'password_changed'),
  @JsonValue(r'report_generated')
  reportGenerated(r'report_generated'),
  @JsonValue(r'medicine_reminder')
  medicineReminder(r'medicine_reminder'),
  @JsonValue(r'system_announcement')
  systemAnnouncement(r'system_announcement'),
  @JsonValue(r'oauth_login')
  oauthLogin(r'oauth_login'),
  @JsonValue(r'identity_linked')
  identityLinked(r'identity_linked'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const NotificationListResponseDtoItemsInnerTypeEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
