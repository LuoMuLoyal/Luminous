// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'daily_record_attachment_input_dto.dart';
import 'daily_record_kind.dart';

part 'update_daily_record_dto.g.dart';

@JsonSerializable()
class UpdateDailyRecordDto {
  const UpdateDailyRecordDto({
    required this.kind,
    required this.occurredAt,
    required this.occurredTime,
    required this.title,
    required this.value,
    required this.unit,
    required this.note,
    required this.payload,
    required this.attachments,
  });

  factory UpdateDailyRecordDto.fromJson(Map<String, Object?> json) =>
      _$UpdateDailyRecordDtoFromJson(json);

  final DailyRecordKind kind;

  /// Date in YYYY-MM-DD format.
  final String occurredAt;

  /// Time in HH:mm 24-hour format. Use null to clear.
  final String? occurredTime;

  /// Short label. Use null to clear.
  final String? title;

  /// Measured value. Use null to clear.
  final String? value;

  /// Unit label. Use null to clear.
  final String? unit;

  /// Free-text note. Use null to clear.
  final String? note;

  /// Structured payload for kind-specific data. Use null to clear.
  final dynamic payload;

  /// Replacement attachment metadata list. Omit to keep existing attachments; send [] to clear.
  final List<DailyRecordAttachmentInputDto> attachments;

  Map<String, Object?> toJson() => _$UpdateDailyRecordDtoToJson(this);
}
