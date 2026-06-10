//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'medicine_reminder_item_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicineReminderItemDto {
  /// Returns a new [MedicineReminderItemDto] instance.
  MedicineReminderItemDto({
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
  final Object? currentMedicineId;

  /// Reminder label.
  @JsonKey(name: r'label', required: false, includeIfNull: false)
  final Object? label;

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
  final Object? startDate;

  /// Date in YYYY-MM-DD format when the reminder ends.
  @JsonKey(name: r'endDate', required: false, includeIfNull: false)
  final Object? endDate;

  /// Whether this reminder is active.
  @JsonKey(name: r'isActive', required: true, includeIfNull: false)
  final bool isActive;

  /// User note.
  @JsonKey(name: r'note', required: false, includeIfNull: false)
  final Object? note;

  /// Created at (ISO 8601).
  @JsonKey(name: r'createdAt', required: true, includeIfNull: false)
  final String createdAt;

  /// Updated at (ISO 8601).
  @JsonKey(name: r'updatedAt', required: true, includeIfNull: false)
  final String updatedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineReminderItemDto &&
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
      currentMedicineId.hashCode +
      label.hashCode +
      scheduledHour.hashCode +
      scheduledMinute.hashCode +
      (daysOfWeek == null ? 0 : daysOfWeek.hashCode) +
      (startDate == null ? 0 : startDate.hashCode) +
      (endDate == null ? 0 : endDate.hashCode) +
      isActive.hashCode +
      note.hashCode +
      createdAt.hashCode +
      updatedAt.hashCode;

  factory MedicineReminderItemDto.fromJson(Map<String, dynamic> json) =>
      _$MedicineReminderItemDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MedicineReminderItemDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
