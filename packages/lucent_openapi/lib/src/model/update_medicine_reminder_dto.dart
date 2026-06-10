//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'update_medicine_reminder_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UpdateMedicineReminderDto {
  /// Returns a new [UpdateMedicineReminderDto] instance.
  UpdateMedicineReminderDto({
    this.currentMedicineId,

    this.label,

    this.scheduledHour,

    this.scheduledMinute,

    this.daysOfWeek,

    this.startDate,

    this.endDate,

    this.isActive,

    this.note,
  });

  /// Linked current medicine id.
  @JsonKey(name: r'currentMedicineId', required: false, includeIfNull: false)
  final Object? currentMedicineId;

  /// Reminder label.
  @JsonKey(name: r'label', required: false, includeIfNull: false)
  final Object? label;

  /// Scheduled local hour, 0-23.
  @JsonKey(name: r'scheduledHour', required: false, includeIfNull: false)
  final num? scheduledHour;

  /// Scheduled local minute, 0-59.
  @JsonKey(name: r'scheduledMinute', required: false, includeIfNull: false)
  final num? scheduledMinute;

  /// Weekday numbers 0-6, where null means every day.
  @JsonKey(name: r'daysOfWeek', required: false, includeIfNull: false)
  final List<num>? daysOfWeek;

  /// Date in YYYY-MM-DD format when the reminder starts. Use null to clear.
  @JsonKey(name: r'startDate', required: false, includeIfNull: false)
  final Object? startDate;

  /// Date in YYYY-MM-DD format when the reminder ends. Use null to clear.
  @JsonKey(name: r'endDate', required: false, includeIfNull: false)
  final Object? endDate;

  /// Whether this reminder is active.
  @JsonKey(name: r'isActive', required: false, includeIfNull: false)
  final bool? isActive;

  /// User note.
  @JsonKey(name: r'note', required: false, includeIfNull: false)
  final Object? note;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateMedicineReminderDto &&
          other.currentMedicineId == currentMedicineId &&
          other.label == label &&
          other.scheduledHour == scheduledHour &&
          other.scheduledMinute == scheduledMinute &&
          other.daysOfWeek == daysOfWeek &&
          other.startDate == startDate &&
          other.endDate == endDate &&
          other.isActive == isActive &&
          other.note == note;

  @override
  int get hashCode =>
      currentMedicineId.hashCode +
      label.hashCode +
      scheduledHour.hashCode +
      scheduledMinute.hashCode +
      (daysOfWeek == null ? 0 : daysOfWeek.hashCode) +
      (startDate == null ? 0 : startDate.hashCode) +
      (endDate == null ? 0 : endDate.hashCode) +
      isActive.hashCode +
      note.hashCode;

  factory UpdateMedicineReminderDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateMedicineReminderDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateMedicineReminderDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
