//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/reminder_entry_list_response_items.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'reminder_entry_list_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReminderEntryListResponse {
  /// Returns a new [ReminderEntryListResponse] instance.
  ReminderEntryListResponse({required this.items});

  /// Medicine reminders.
  @JsonKey(name: r'items', required: true, includeIfNull: false)
  final List<ReminderEntryListResponseItems> items;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReminderEntryListResponse && other.items == items;

  @override
  int get hashCode => items.hashCode;

  factory ReminderEntryListResponse.fromJson(Map<String, dynamic> json) =>
      _$ReminderEntryListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ReminderEntryListResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
