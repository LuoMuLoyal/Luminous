// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'user_notification_type.dart';

part 'notification_detail_dto.g.dart';

@JsonSerializable()
class NotificationDetailDto {
  const NotificationDetailDto({
    required this.id,
    required this.type,
    required this.title,
    required this.content,
    required this.isRead,
    required this.createdAt,
    this.action,
    this.actionPayload,
    this.readAt,
  });

  factory NotificationDetailDto.fromJson(Map<String, Object?> json) =>
      _$NotificationDetailDtoFromJson(json);

  /// Unique notification identifier.
  final String id;
  final UserNotificationType type;

  /// Notification title.
  final String title;

  /// Notification content body.
  final String content;

  /// Action route target for the frontend.
  final String? action;

  /// Extra payload for the action.
  final dynamic actionPayload;

  /// Whether the notification has been read.
  final bool isRead;

  /// ISO-8601 timestamp when the notification was created.
  final String createdAt;

  /// ISO-8601 timestamp when the notification was read.
  final String? readAt;

  Map<String, Object?> toJson() => _$NotificationDetailDtoToJson(this);
}
