//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_openapi/src/model/medicine_reminder_item_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medicine_reminder_list_data_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicineReminderListDataDto {
  /// Returns a new [MedicineReminderListDataDto] instance.
  MedicineReminderListDataDto({required this.items});

  @JsonKey(name: r'items', required: true, includeIfNull: false)
  final List<MedicineReminderItemDto> items;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineReminderListDataDto && other.items == items;

  @override
  int get hashCode => items.hashCode;

  factory MedicineReminderListDataDto.fromJson(Map<String, dynamic> json) =>
      _$MedicineReminderListDataDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MedicineReminderListDataDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
