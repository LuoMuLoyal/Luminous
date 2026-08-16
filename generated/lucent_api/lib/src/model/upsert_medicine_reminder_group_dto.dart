//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/upsert_reminder_slot_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'upsert_medicine_reminder_group_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UpsertMedicineReminderGroupDto {
  /// Returns a new [UpsertMedicineReminderGroupDto] instance.
  UpsertMedicineReminderGroupDto({
    required this.currentMedicineId,

    this.label,

    this.daysOfWeek,

    this.startDate,

    this.endDate,

    this.isActive = true,

    this.note,

    required this.slots,
  });

  /// Linked current medicine id.
  @JsonKey(name: r'currentMedicineId', required: true, includeIfNull: false)
  final String currentMedicineId;

  /// Reminder label.
  @JsonKey(name: r'label', required: false, includeIfNull: false)
  final String? label;

  /// Weekday numbers 0-6, where null means every day.
  @JsonKey(name: r'daysOfWeek', required: false, includeIfNull: false)
  final List<num>? daysOfWeek;

  /// Date in YYYY-MM-DD format when the reminder starts.
  @JsonKey(name: r'startDate', required: false, includeIfNull: false)
  final String? startDate;

  /// Date in YYYY-MM-DD format when the reminder ends.
  @JsonKey(name: r'endDate', required: false, includeIfNull: false)
  final String? endDate;

  /// Whether this reminder is active.
  @JsonKey(
    defaultValue: true,
    name: r'isActive',
    required: false,
    includeIfNull: false,
  )
  final bool? isActive;

  /// User note.
  @JsonKey(name: r'note', required: false, includeIfNull: false)
  final String? note;

  /// Reminder slots for this medicine. Replaces the whole group.
  @JsonKey(name: r'slots', required: true, includeIfNull: false)
  final List<UpsertReminderSlotDto> slots;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpsertMedicineReminderGroupDto &&
          other.currentMedicineId == currentMedicineId &&
          other.label == label &&
          other.daysOfWeek == daysOfWeek &&
          other.startDate == startDate &&
          other.endDate == endDate &&
          other.isActive == isActive &&
          other.note == note &&
          other.slots == slots;

  @override
  int get hashCode =>
      currentMedicineId.hashCode +
      (label == null ? 0 : label.hashCode) +
      (daysOfWeek == null ? 0 : daysOfWeek.hashCode) +
      (startDate == null ? 0 : startDate.hashCode) +
      (endDate == null ? 0 : endDate.hashCode) +
      isActive.hashCode +
      (note == null ? 0 : note.hashCode) +
      slots.hashCode;

  factory UpsertMedicineReminderGroupDto.fromJson(Map<String, dynamic> json) =>
      _$UpsertMedicineReminderGroupDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UpsertMedicineReminderGroupDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
