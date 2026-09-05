//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/reminder_delivery_list_response_items.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'reminder_delivery_list_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReminderDeliveryListResponse {
  /// Returns a new [ReminderDeliveryListResponse] instance.
  ReminderDeliveryListResponse({required this.items});

  /// Delivery audit rows.
  @JsonKey(name: r'items', required: true, includeIfNull: false)
  final List<ReminderDeliveryListResponseItems> items;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReminderDeliveryListResponse && other.items == items;

  @override
  int get hashCode => items.hashCode;

  factory ReminderDeliveryListResponse.fromJson(Map<String, dynamic> json) =>
      _$ReminderDeliveryListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ReminderDeliveryListResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
