//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'notifications_controller_create_v1_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class NotificationsControllerCreateV1Request {
  /// Returns a new [NotificationsControllerCreateV1Request] instance.
  NotificationsControllerCreateV1Request({
    required this.type,

    required this.title,

    required this.content,

    this.action,

    this.actionPayload,
  });

  /// Notification type. System-level types (e.g. system_announcement) are not allowed for user-created notifications.
  @JsonKey(
    name: r'type',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        NotificationsControllerCreateV1RequestTypeEnum.unknownDefaultOpenApi,
  )
  final NotificationsControllerCreateV1RequestTypeEnum type;

  /// Notification title.
  @JsonKey(name: r'title', required: true, includeIfNull: false)
  final String title;

  /// Notification content body.
  @JsonKey(name: r'content', required: true, includeIfNull: false)
  final String content;

  /// Action route target for the frontend.
  @JsonKey(name: r'action', required: false, includeIfNull: false)
  final String? action;

  /// Extra payload for the action.
  @JsonKey(name: r'actionPayload', required: false, includeIfNull: false)
  final Object? actionPayload;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationsControllerCreateV1Request &&
          other.type == type &&
          other.title == title &&
          other.content == content &&
          other.action == action &&
          other.actionPayload == actionPayload;

  @override
  int get hashCode =>
      type.hashCode +
      title.hashCode +
      content.hashCode +
      (action == null ? 0 : action.hashCode) +
      (actionPayload == null ? 0 : actionPayload.hashCode);

  factory NotificationsControllerCreateV1Request.fromJson(
    Map<String, dynamic> json,
  ) => _$NotificationsControllerCreateV1RequestFromJson(json);

  Map<String, dynamic> toJson() =>
      _$NotificationsControllerCreateV1RequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// Notification type. System-level types (e.g. system_announcement) are not allowed for user-created notifications.
enum NotificationsControllerCreateV1RequestTypeEnum {
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
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const NotificationsControllerCreateV1RequestTypeEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
