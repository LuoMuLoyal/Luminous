//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/reminder_delivery_item_dto.dart';
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
  ReminderDeliveryListResponseDto({required this.items});

  @JsonKey(name: r'items', required: true, includeIfNull: false)
  final List<ReminderDeliveryItemDto> items;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReminderDeliveryListResponseDto && other.items == items;

  @override
  int get hashCode => items.hashCode;

  factory ReminderDeliveryListResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ReminderDeliveryListResponseDtoFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ReminderDeliveryListResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
