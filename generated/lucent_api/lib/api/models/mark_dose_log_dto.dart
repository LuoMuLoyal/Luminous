// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'dose_log_status.dart';

part 'mark_dose_log_dto.g.dart';

@JsonSerializable()
class MarkDoseLogDto {
  const MarkDoseLogDto({
    required this.status,
    required this.scheduledFor,
    this.currentMedicineId,
    this.reminderId,
    this.scheduledTime,
    this.doseText,
    this.note,
  });

  factory MarkDoseLogDto.fromJson(Map<String, Object?> json) =>
      _$MarkDoseLogDtoFromJson(json);

  /// Linked current medicine id.
  final String? currentMedicineId;

  /// Linked reminder id for slot-aware marks.
  final String? reminderId;
  final DoseLogStatus status;

  /// Scheduled date YYYY-MM-DD.
  final String scheduledFor;

  /// Scheduled slot time in HH:mm for slot-aware marks.
  final String? scheduledTime;

  /// Dose text.
  final dynamic doseText;

  /// Free-text note.
  final dynamic note;

  Map<String, Object?> toJson() => _$MarkDoseLogDtoToJson(this);
}
