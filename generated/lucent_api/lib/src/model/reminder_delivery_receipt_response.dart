//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/reminder_delivery_receipt_response_item.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'reminder_delivery_receipt_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReminderDeliveryReceiptResponse {
  /// Returns a new [ReminderDeliveryReceiptResponse] instance.
  ReminderDeliveryReceiptResponse({required this.item});

  @JsonKey(name: r'item', required: true, includeIfNull: false)
  final ReminderDeliveryReceiptResponseItem item;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReminderDeliveryReceiptResponse && other.item == item;

  @override
  int get hashCode => item.hashCode;

  factory ReminderDeliveryReceiptResponse.fromJson(Map<String, dynamic> json) =>
      _$ReminderDeliveryReceiptResponseFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ReminderDeliveryReceiptResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
