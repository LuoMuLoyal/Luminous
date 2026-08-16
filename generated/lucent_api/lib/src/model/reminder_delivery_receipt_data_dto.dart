//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/reminder_delivery_item_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'reminder_delivery_receipt_data_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReminderDeliveryReceiptDataDto {
  /// Returns a new [ReminderDeliveryReceiptDataDto] instance.
  ReminderDeliveryReceiptDataDto({required this.item});

  @JsonKey(name: r'item', required: true, includeIfNull: false)
  final ReminderDeliveryItemDto item;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReminderDeliveryReceiptDataDto && other.item == item;

  @override
  int get hashCode => item.hashCode;

  factory ReminderDeliveryReceiptDataDto.fromJson(Map<String, dynamic> json) =>
      _$ReminderDeliveryReceiptDataDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ReminderDeliveryReceiptDataDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
