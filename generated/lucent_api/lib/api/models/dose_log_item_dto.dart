// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'dose_log_status.dart';

part 'dose_log_item_dto.g.dart';

@JsonSerializable()
class DoseLogItemDto {
  const DoseLogItemDto({
    required this.id,
    required this.status,
    required this.scheduledFor,
    required this.createdAt,
    required this.updatedAt,
    this.currentMedicineId,
    this.reminderId,
    this.scheduledTime,
    this.doseText,
    this.note,
    this.source,
  });

  factory DoseLogItemDto.fromJson(Map<String, Object?> json) =>
      _$DoseLogItemDtoFromJson(json);

  /// Dose log id.
  final String id;

  /// Linked current medicine id.
  final dynamic currentMedicineId;

  /// Linked reminder id for slot-aware logs.
  final dynamic reminderId;
  final DoseLogStatus status;

  /// Scheduled date in YYYY-MM-DD format.
  final String scheduledFor;

  /// Scheduled slot time in HH:mm format.
  final dynamic scheduledTime;

  /// Dose text.
  final dynamic doseText;

  /// Free-text note.
  final dynamic note;

  /// Source.
  final dynamic source;

  /// Created at (ISO 8601).
  final String createdAt;

  /// Updated at (ISO 8601).
  final String updatedAt;

  Map<String, Object?> toJson() => _$DoseLogItemDtoToJson(this);
}
