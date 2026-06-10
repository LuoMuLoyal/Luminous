//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'reminder_delivery_item_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReminderDeliveryItemDto {
  /// Returns a new [ReminderDeliveryItemDto] instance.
  ReminderDeliveryItemDto({
    required this.id,

    this.reminderId,

    this.deviceId,

    required this.channel,

    required this.status,

    required this.scheduledFor,

    this.deliveredAt,

    this.errorMessage,

    required this.createdAt,
  });

  /// Delivery log id.
  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  /// Linked medicine reminder id.
  @JsonKey(name: r'reminderId', required: false, includeIfNull: false)
  final Object? reminderId;

  /// Target device id.
  @JsonKey(name: r'deviceId', required: false, includeIfNull: false)
  final Object? deviceId;

  /// Delivery channel.
  @JsonKey(name: r'channel', required: true, includeIfNull: false)
  final String channel;

  /// Delivery status.
  @JsonKey(name: r'status', required: true, includeIfNull: false)
  final String status;

  /// Scheduled delivery time (ISO 8601).
  @JsonKey(name: r'scheduledFor', required: true, includeIfNull: false)
  final String scheduledFor;

  /// Actual delivery time (ISO 8601).
  @JsonKey(name: r'deliveredAt', required: false, includeIfNull: false)
  final Object? deliveredAt;

  /// Failure reason, if any.
  @JsonKey(name: r'errorMessage', required: false, includeIfNull: false)
  final Object? errorMessage;

  /// Created at (ISO 8601).
  @JsonKey(name: r'createdAt', required: true, includeIfNull: false)
  final String createdAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReminderDeliveryItemDto &&
          other.id == id &&
          other.reminderId == reminderId &&
          other.deviceId == deviceId &&
          other.channel == channel &&
          other.status == status &&
          other.scheduledFor == scheduledFor &&
          other.deliveredAt == deliveredAt &&
          other.errorMessage == errorMessage &&
          other.createdAt == createdAt;

  @override
  int get hashCode =>
      id.hashCode +
      reminderId.hashCode +
      deviceId.hashCode +
      channel.hashCode +
      status.hashCode +
      scheduledFor.hashCode +
      deliveredAt.hashCode +
      errorMessage.hashCode +
      createdAt.hashCode;

  factory ReminderDeliveryItemDto.fromJson(Map<String, dynamic> json) =>
      _$ReminderDeliveryItemDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ReminderDeliveryItemDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
