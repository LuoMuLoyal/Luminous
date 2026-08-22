//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medicine_reminder_response_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicineReminderResponseDto {
  /// Returns a new [MedicineReminderResponseDto] instance.
  MedicineReminderResponseDto({
    required this.id,

    this.currentMedicineId,

    this.label,

    required this.scheduledHour,

    required this.scheduledMinute,

    this.daysOfWeek,

    this.startDate,

    this.endDate,

    required this.isActive,

    this.note,

    required this.createdAt,

    required this.updatedAt,
  });

  /// Reminder id.
  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  /// Linked current medicine id.
  @JsonKey(name: r'currentMedicineId', required: false, includeIfNull: false)
  final String? currentMedicineId;

  /// Reminder label.
  @JsonKey(name: r'label', required: false, includeIfNull: false)
  final String? label;

  /// Scheduled local hour, 0-23.
  @JsonKey(name: r'scheduledHour', required: true, includeIfNull: false)
  final num scheduledHour;

  /// Scheduled local minute, 0-59.
  @JsonKey(name: r'scheduledMinute', required: true, includeIfNull: false)
  final num scheduledMinute;

  /// Weekday numbers 0-6. Null means every day.
  @JsonKey(name: r'daysOfWeek', required: false, includeIfNull: false)
  final List<num>? daysOfWeek;

  /// Date in YYYY-MM-DD format when the reminder starts.
  @JsonKey(name: r'startDate', required: false, includeIfNull: false)
  final String? startDate;

  /// Date in YYYY-MM-DD format when the reminder ends.
  @JsonKey(name: r'endDate', required: false, includeIfNull: false)
  final String? endDate;

  /// Whether this reminder is active.
  @JsonKey(name: r'isActive', required: true, includeIfNull: false)
  final bool isActive;

  /// User note.
  @JsonKey(name: r'note', required: false, includeIfNull: false)
  final String? note;

  /// Created at (ISO 8601).
  @JsonKey(name: r'createdAt', required: true, includeIfNull: false)
  final String createdAt;

  /// Updated at (ISO 8601).
  @JsonKey(name: r'updatedAt', required: true, includeIfNull: false)
  final String updatedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineReminderResponseDto &&
          other.id == id &&
          other.currentMedicineId == currentMedicineId &&
          other.label == label &&
          other.scheduledHour == scheduledHour &&
          other.scheduledMinute == scheduledMinute &&
          other.daysOfWeek == daysOfWeek &&
          other.startDate == startDate &&
          other.endDate == endDate &&
          other.isActive == isActive &&
          other.note == note &&
          other.createdAt == createdAt &&
          other.updatedAt == updatedAt;

  @override
  int get hashCode =>
      id.hashCode +
      (currentMedicineId == null ? 0 : currentMedicineId.hashCode) +
      (label == null ? 0 : label.hashCode) +
      scheduledHour.hashCode +
      scheduledMinute.hashCode +
      (daysOfWeek == null ? 0 : daysOfWeek.hashCode) +
      (startDate == null ? 0 : startDate.hashCode) +
      (endDate == null ? 0 : endDate.hashCode) +
      isActive.hashCode +
      (note == null ? 0 : note.hashCode) +
      createdAt.hashCode +
      updatedAt.hashCode;

  factory MedicineReminderResponseDto.fromJson(Map<String, dynamic> json) =>
      _$MedicineReminderResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MedicineReminderResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
