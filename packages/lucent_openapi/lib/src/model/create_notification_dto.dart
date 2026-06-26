//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_openapi/src/model/user_notification_type.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_notification_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateNotificationDto {
  /// Returns a new [CreateNotificationDto] instance.
  CreateNotificationDto({
    required this.type,

    required this.title,

    required this.content,

    this.action,

    this.actionPayload,
  });

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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateNotificationDto &&
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

  factory CreateNotificationDto.fromJson(Map<String, dynamic> json) =>
      _$CreateNotificationDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CreateNotificationDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
