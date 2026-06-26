//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_openapi/src/model/user_notification_type.dart';
import 'package:json_annotation/json_annotation.dart';

part 'notification_detail_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class NotificationDetailDto {
  /// Returns a new [NotificationDetailDto] instance.
  NotificationDetailDto({
    required this.id,

    required this.type,

    required this.title,

    required this.content,

    this.action,

    this.actionPayload,

    required this.isRead,

    required this.createdAt,

    this.readAt,
  });

  /// Unique notification identifier.
  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(
    name: r'type',
    required: true,
    includeIfNull: false,
    unknownEnumValue: UserNotificationType.unknownDefaultOpenApi,
  )
  final UserNotificationType type;

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

  /// Whether the notification has been read.
  @JsonKey(name: r'isRead', required: true, includeIfNull: false)
  final bool isRead;

  /// ISO-8601 timestamp when the notification was created.
  @JsonKey(name: r'createdAt', required: true, includeIfNull: false)
  final String createdAt;

  /// ISO-8601 timestamp when the notification was read.
  @JsonKey(name: r'readAt', required: false, includeIfNull: false)
  final String? readAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationDetailDto &&
          other.id == id &&
          other.type == type &&
          other.title == title &&
          other.content == content &&
          other.action == action &&
          other.actionPayload == actionPayload &&
          other.isRead == isRead &&
          other.createdAt == createdAt &&
          other.readAt == readAt;

  @override
  int get hashCode =>
      id.hashCode +
      type.hashCode +
      title.hashCode +
      content.hashCode +
      (action == null ? 0 : action.hashCode) +
      (actionPayload == null ? 0 : actionPayload.hashCode) +
      isRead.hashCode +
      createdAt.hashCode +
      (readAt == null ? 0 : readAt.hashCode);

  factory NotificationDetailDto.fromJson(Map<String, dynamic> json) =>
      _$NotificationDetailDtoFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationDetailDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
