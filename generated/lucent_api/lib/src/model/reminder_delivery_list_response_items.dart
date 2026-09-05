//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'reminder_delivery_list_response_items.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReminderDeliveryListResponseItems {
  /// Returns a new [ReminderDeliveryListResponseItems] instance.
  ReminderDeliveryListResponseItems({
    required this.id,

    required this.reminderId,

    required this.deviceId,

    required this.channel,

    required this.status,

    required this.scheduledFor,

    required this.deliveredAt,

    required this.errorMessage,

    required this.createdAt,
  });

  /// Delivery log id.
  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'reminderId', required: true, includeIfNull: true)
  final String? reminderId;

  @JsonKey(name: r'deviceId', required: true, includeIfNull: true)
  final String? deviceId;

  /// Delivery channel.
  @JsonKey(name: r'channel', required: true, includeIfNull: false)
  final String channel;

  /// Delivery status.
  @JsonKey(name: r'status', required: true, includeIfNull: false)
  final String status;

  /// Scheduled delivery time (ISO 8601).
  @JsonKey(name: r'scheduledFor', required: true, includeIfNull: false)
  final String scheduledFor;

  @JsonKey(name: r'deliveredAt', required: true, includeIfNull: true)
  final String? deliveredAt;

  @JsonKey(name: r'errorMessage', required: true, includeIfNull: true)
  final String? errorMessage;

  /// Created at (ISO 8601).
  @JsonKey(name: r'createdAt', required: true, includeIfNull: false)
  final String createdAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReminderDeliveryListResponseItems &&
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
      (reminderId == null ? 0 : reminderId.hashCode) +
      (deviceId == null ? 0 : deviceId.hashCode) +
      channel.hashCode +
      status.hashCode +
      scheduledFor.hashCode +
      (deliveredAt == null ? 0 : deliveredAt.hashCode) +
      (errorMessage == null ? 0 : errorMessage.hashCode) +
      createdAt.hashCode;

  factory ReminderDeliveryListResponseItems.fromJson(
    Map<String, dynamic> json,
  ) => _$ReminderDeliveryListResponseItemsFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ReminderDeliveryListResponseItemsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
