//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medicine_reminder_list_response_dto_items_inner.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicineReminderListResponseDtoItemsInner {
  /// Returns a new [MedicineReminderListResponseDtoItemsInner] instance.
  MedicineReminderListResponseDtoItemsInner({
    required this.id,

    required this.currentMedicineId,

    required this.label,

    required this.scheduledHour,

    required this.scheduledMinute,

    required this.daysOfWeek,

    required this.startDate,

    required this.endDate,

    required this.isActive,

    required this.note,

    required this.createdAt,

    required this.updatedAt,
  });

  /// Reminder id.
  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'currentMedicineId', required: true, includeIfNull: true)
  final String? currentMedicineId;

  @JsonKey(name: r'label', required: true, includeIfNull: true)
  final String? label;

  /// Scheduled local hour, 0-23.
  @JsonKey(name: r'scheduledHour', required: true, includeIfNull: false)
  final num scheduledHour;

  /// Scheduled local minute, 0-59.
  @JsonKey(name: r'scheduledMinute', required: true, includeIfNull: false)
  final num scheduledMinute;

  @JsonKey(name: r'daysOfWeek', required: true, includeIfNull: true)
  final List<num>? daysOfWeek;

  @JsonKey(name: r'startDate', required: true, includeIfNull: true)
  final String? startDate;

  @JsonKey(name: r'endDate', required: true, includeIfNull: true)
  final String? endDate;

  /// Whether this reminder is active.
  @JsonKey(name: r'isActive', required: true, includeIfNull: false)
  final bool isActive;

  @JsonKey(name: r'note', required: true, includeIfNull: true)
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
      other is MedicineReminderListResponseDtoItemsInner &&
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

  factory MedicineReminderListResponseDtoItemsInner.fromJson(
    Map<String, dynamic> json,
  ) => _$MedicineReminderListResponseDtoItemsInnerFromJson(json);

  Map<String, dynamic> toJson() =>
      _$MedicineReminderListResponseDtoItemsInnerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
