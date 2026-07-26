//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/reminder_delivery_item_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'reminder_delivery_list_data_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReminderDeliveryListDataDto {
  /// Returns a new [ReminderDeliveryListDataDto] instance.
  ReminderDeliveryListDataDto({required this.items});

  @JsonKey(name: r'items', required: true, includeIfNull: false)
  final List<ReminderDeliveryItemDto> items;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReminderDeliveryListDataDto && other.items == items;

  @override
  int get hashCode => items.hashCode;

  factory ReminderDeliveryListDataDto.fromJson(Map<String, dynamic> json) =>
      _$ReminderDeliveryListDataDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ReminderDeliveryListDataDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
