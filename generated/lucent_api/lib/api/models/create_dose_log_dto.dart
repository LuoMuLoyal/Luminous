// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'dose_log_status.dart';

part 'create_dose_log_dto.g.dart';

@JsonSerializable()
class CreateDoseLogDto {
  const CreateDoseLogDto({
    required this.status,
    required this.scheduledFor,
    this.currentMedicineId,
    this.reminderId,
    this.scheduledTime,
    this.doseText,
    this.note,
  });

  factory CreateDoseLogDto.fromJson(Map<String, Object?> json) =>
      _$CreateDoseLogDtoFromJson(json);

  /// Linked current medicine id.
  final String? currentMedicineId;

  /// Linked reminder id for slot-aware logs.
  final String? reminderId;
  final DoseLogStatus status;

  /// Scheduled date YYYY-MM-DD.
  final String scheduledFor;

  /// Scheduled slot time in HH:mm.
  final String? scheduledTime;

  /// Dose text.
  final String? doseText;

  /// Free-text note.
  final String? note;

  Map<String, Object?> toJson() => _$CreateDoseLogDtoToJson(this);
}
