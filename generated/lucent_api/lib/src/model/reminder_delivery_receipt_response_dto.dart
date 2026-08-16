//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/reminder_delivery_receipt_data_dto.dart';
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
  ReminderDeliveryReceiptResponseDto({
    required this.code,

    required this.message,

    required this.data,
  });

  @JsonKey(name: r'code', required: true, includeIfNull: false)
  final num code;

  @JsonKey(name: r'message', required: true, includeIfNull: false)
  final String message;

  @JsonKey(name: r'data', required: true, includeIfNull: false)
  final ReminderDeliveryReceiptDataDto data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReminderDeliveryReceiptResponseDto &&
          other.code == code &&
          other.message == message &&
          other.data == data;

  @override
  int get hashCode => code.hashCode + message.hashCode + data.hashCode;

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
