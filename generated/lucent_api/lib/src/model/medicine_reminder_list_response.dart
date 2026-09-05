//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/medicine_reminder_list_response_items.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medicine_reminder_list_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicineReminderListResponse {
  /// Returns a new [MedicineReminderListResponse] instance.
  MedicineReminderListResponse({required this.items});

  /// Medicine reminders.
  @JsonKey(name: r'items', required: true, includeIfNull: false)
  final List<MedicineReminderListResponseItems> items;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineReminderListResponse && other.items == items;

  @override
  int get hashCode => items.hashCode;

  factory MedicineReminderListResponse.fromJson(Map<String, dynamic> json) =>
      _$MedicineReminderListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MedicineReminderListResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
