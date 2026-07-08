// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'update_medicine_reminder_dto.g.dart';

@JsonSerializable()
class UpdateMedicineReminderDto {
  const UpdateMedicineReminderDto({
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

  factory UpdateMedicineReminderDto.fromJson(Map<String, Object?> json) =>
      _$UpdateMedicineReminderDtoFromJson(json);

  /// Linked current medicine id.
  final String? currentMedicineId;

  /// Reminder label.
  final String? label;

  /// Scheduled local hour, 0-23.
  final num? scheduledHour;

  /// Scheduled local minute, 0-59.
  final num? scheduledMinute;

  /// Weekday numbers 0-6, where null means every day.
  final List<num>? daysOfWeek;

  /// Date in YYYY-MM-DD format when the reminder starts. Use null to clear.
  final String? startDate;

  /// Date in YYYY-MM-DD format when the reminder ends. Use null to clear.
  final String? endDate;

  /// Whether this reminder is active.
  final bool? isActive;

  /// User note.
  final String? note;

  Map<String, Object?> toJson() => _$UpdateMedicineReminderDtoToJson(this);
}
