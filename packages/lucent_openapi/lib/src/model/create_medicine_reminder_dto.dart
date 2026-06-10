//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'create_medicine_reminder_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateMedicineReminderDto {
  /// Returns a new [CreateMedicineReminderDto] instance.
  CreateMedicineReminderDto({
    this.currentMedicineId,

    this.label,

    required this.scheduledHour,

    required this.scheduledMinute,

    this.daysOfWeek,

    this.startDate,

    this.endDate,

    this.isActive = true,

    this.note,
  });

  /// Linked current medicine id.
  @JsonKey(name: r'currentMedicineId', required: false, includeIfNull: false)
  final String? currentMedicineId;

  /// Reminder label.
  @JsonKey(name: r'label', required: false, includeIfNull: false)
  final Object? label;

  /// Scheduled local hour, 0-23.
  @JsonKey(name: r'scheduledHour', required: true, includeIfNull: false)
  final num scheduledHour;

  /// Scheduled local minute, 0-59.
  @JsonKey(name: r'scheduledMinute', required: true, includeIfNull: false)
  final num scheduledMinute;

  /// Weekday numbers 0-6, where null means every day.
  @JsonKey(name: r'daysOfWeek', required: false, includeIfNull: false)
  final List<num>? daysOfWeek;

  /// Date in YYYY-MM-DD format when the reminder starts.
  @JsonKey(name: r'startDate', required: false, includeIfNull: false)
  final Object? startDate;

  /// Date in YYYY-MM-DD format when the reminder ends.
  @JsonKey(name: r'endDate', required: false, includeIfNull: false)
  final Object? endDate;

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
  final Object? note;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateMedicineReminderDto &&
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

  factory CreateMedicineReminderDto.fromJson(Map<String, dynamic> json) =>
      _$CreateMedicineReminderDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CreateMedicineReminderDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
