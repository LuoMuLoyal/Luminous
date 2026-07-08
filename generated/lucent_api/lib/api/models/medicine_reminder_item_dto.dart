// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'medicine_reminder_item_dto.g.dart';

@JsonSerializable()
class MedicineReminderItemDto {
  const MedicineReminderItemDto({
    required this.id,
    required this.scheduledHour,
    required this.scheduledMinute,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.currentMedicineId,
    this.label,
    this.daysOfWeek,
    this.startDate,
    this.endDate,
    this.note,
  });

  factory MedicineReminderItemDto.fromJson(Map<String, Object?> json) =>
      _$MedicineReminderItemDtoFromJson(json);

  /// Reminder id.
  final String id;

  /// Linked current medicine id.
  final String? currentMedicineId;

  /// Reminder label.
  final String? label;

  /// Scheduled local hour, 0-23.
  final num scheduledHour;

  /// Scheduled local minute, 0-59.
  final num scheduledMinute;

  /// Weekday numbers 0-6. Null means every day.
  final List<num>? daysOfWeek;

  /// Date in YYYY-MM-DD format when the reminder starts.
  final String? startDate;

  /// Date in YYYY-MM-DD format when the reminder ends.
  final String? endDate;

  /// Whether this reminder is active.
  final bool isActive;

  /// User note.
  final String? note;

  /// Created at (ISO 8601).
  final String createdAt;

  /// Updated at (ISO 8601).
  final String updatedAt;

  Map<String, Object?> toJson() => _$MedicineReminderItemDtoToJson(this);
}
