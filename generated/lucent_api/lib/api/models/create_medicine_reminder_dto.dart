// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'create_medicine_reminder_dto.g.dart';

@JsonSerializable()
class CreateMedicineReminderDto {
  const CreateMedicineReminderDto({
    required this.scheduledHour,
    required this.scheduledMinute,
    this.isActive = true,
    this.currentMedicineId,
    this.label,
    this.daysOfWeek,
    this.startDate,
    this.endDate,
    this.note,
  });

  factory CreateMedicineReminderDto.fromJson(Map<String, Object?> json) =>
      _$CreateMedicineReminderDtoFromJson(json);

  /// Linked current medicine id.
  final String? currentMedicineId;

  /// Reminder label.
  final String? label;

  /// Scheduled local hour, 0-23.
  final num scheduledHour;

  /// Scheduled local minute, 0-59.
  final num scheduledMinute;

  /// Weekday numbers 0-6, where null means every day.
  final List<num>? daysOfWeek;

  /// Date in YYYY-MM-DD format when the reminder starts.
  final String? startDate;

  /// Date in YYYY-MM-DD format when the reminder ends.
  final String? endDate;

  /// Whether this reminder is active.
  final bool isActive;

  /// User note.
  final String? note;

  Map<String, Object?> toJson() => _$CreateMedicineReminderDtoToJson(this);
}
