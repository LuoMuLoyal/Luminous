//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/reminder_delivery_receipt_response_dto_item.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'reminder_delivery_receipt_response_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReminderDeliveryReceiptResponseDto {
  /// Returns a new [ReminderDeliveryReceiptResponseDto] instance.
  ReminderDeliveryReceiptResponseDto({required this.item});

  @JsonKey(name: r'item', required: true, includeIfNull: false)
  final ReminderDeliveryReceiptResponseDtoItem item;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReminderDeliveryReceiptResponseDto && other.item == item;

  @override
  int get hashCode => item.hashCode;

  factory ReminderDeliveryReceiptResponseDto.fromJson(
    Map<String, dynamic> json,
  ) => _$ReminderDeliveryReceiptResponseDtoFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ReminderDeliveryReceiptResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
