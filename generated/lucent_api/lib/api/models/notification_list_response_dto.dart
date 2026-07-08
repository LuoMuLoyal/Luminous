// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'notification_list_item_dto.dart';

part 'notification_list_response_dto.g.dart';

@JsonSerializable()
class NotificationListResponseDto {
  const NotificationListResponseDto({
    required this.code,
    required this.message,
    required this.items,
    required this.total,
  });

  factory NotificationListResponseDto.fromJson(Map<String, Object?> json) =>
      _$NotificationListResponseDtoFromJson(json);

  /// Result code.
  final num code;

  /// Message.
  final String message;
  final List<NotificationListItemDto> items;

  /// Total count of notifications for the user.
  final num total;

  Map<String, Object?> toJson() => _$NotificationListResponseDtoToJson(this);
}
