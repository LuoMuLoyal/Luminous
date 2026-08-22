//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/medicine_reminder_item_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medicine_reminder_list_response_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicineReminderListResponseDto {
  /// Returns a new [MedicineReminderListResponseDto] instance.
  MedicineReminderListResponseDto({required this.items});

  @JsonKey(name: r'items', required: true, includeIfNull: false)
  final List<MedicineReminderItemDto> items;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineReminderListResponseDto && other.items == items;

  @override
  int get hashCode => items.hashCode;

  factory MedicineReminderListResponseDto.fromJson(Map<String, dynamic> json) =>
      _$MedicineReminderListResponseDtoFromJson(json);

  Map<String, dynamic> toJson() =>
      _$MedicineReminderListResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
