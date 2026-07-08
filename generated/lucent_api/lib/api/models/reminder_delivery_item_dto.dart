// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'reminder_delivery_item_dto.g.dart';

@JsonSerializable()
class ReminderDeliveryItemDto {
  const ReminderDeliveryItemDto({
    required this.id,
    required this.channel,
    required this.status,
    required this.scheduledFor,
    required this.createdAt,
    this.reminderId,
    this.deviceId,
    this.deliveredAt,
    this.errorMessage,
  });

  factory ReminderDeliveryItemDto.fromJson(Map<String, Object?> json) =>
      _$ReminderDeliveryItemDtoFromJson(json);

  /// Delivery log id.
  final String id;

  /// Linked medicine reminder id.
  final dynamic reminderId;

  /// Target device id.
  final dynamic deviceId;

  /// Delivery channel.
  final String channel;

  /// Delivery status.
  final String status;

  /// Scheduled delivery time (ISO 8601).
  final String scheduledFor;

  /// Actual delivery time (ISO 8601).
  final dynamic deliveredAt;

  /// Failure reason, if any.
  final dynamic errorMessage;

  /// Created at (ISO 8601).
  final String createdAt;

  Map<String, Object?> toJson() => _$ReminderDeliveryItemDtoToJson(this);
}
