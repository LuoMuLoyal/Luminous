//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/reminder_delivery_list_data_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'reminder_delivery_list_response_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReminderDeliveryListResponseDto {
  /// Returns a new [ReminderDeliveryListResponseDto] instance.
  ReminderDeliveryListResponseDto({
    required this.code,
    required this.message,
    required this.data,
  });

  @JsonKey(name: r'code', required: true, includeIfNull: false)
  final num code;

  @JsonKey(name: r'message', required: true, includeIfNull: false)
  final String message;

  @JsonKey(name: r'data', required: true, includeIfNull: false)
  final ReminderDeliveryListDataDto data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReminderDeliveryListResponseDto &&
          other.code == code &&
          other.message == message &&
          other.data == data;

  @override
  int get hashCode => code.hashCode + message.hashCode + data.hashCode;

  factory ReminderDeliveryListResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ReminderDeliveryListResponseDtoFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ReminderDeliveryListResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
