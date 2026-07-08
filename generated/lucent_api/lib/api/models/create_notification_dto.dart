// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'user_notification_type.dart';

part 'create_notification_dto.g.dart';

@JsonSerializable()
class CreateNotificationDto {
  const CreateNotificationDto({
    required this.type,
    required this.title,
    required this.content,
    this.action,
    this.actionPayload,
  });

  factory CreateNotificationDto.fromJson(Map<String, Object?> json) =>
      _$CreateNotificationDtoFromJson(json);

  final UserNotificationType type;

  /// Notification title.
  final String title;

  /// Notification content body.
  final String content;

  /// Action route target for the frontend.
  final String? action;

  /// Extra payload for the action.
  final dynamic actionPayload;

  Map<String, Object?> toJson() => _$CreateNotificationDtoToJson(this);
}
