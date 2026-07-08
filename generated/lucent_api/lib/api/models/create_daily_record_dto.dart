// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'daily_record_attachment_input_dto.dart';
import 'daily_record_kind.dart';

part 'create_daily_record_dto.g.dart';

@JsonSerializable()
class CreateDailyRecordDto {
  const CreateDailyRecordDto({
    required this.kind,
    required this.occurredAt,
    this.occurredTime,
    this.title,
    this.value,
    this.unit,
    this.note,
    this.payload,
    this.attachments,
  });

  factory CreateDailyRecordDto.fromJson(Map<String, Object?> json) =>
      _$CreateDailyRecordDtoFromJson(json);

  final DailyRecordKind kind;

  /// Date in YYYY-MM-DD format. For sleep records this is the wake date (the morning the user wakes up from that sleep).
  final String occurredAt;

  /// Time in HH:mm 24-hour format. When omitted, UI flows may treat the record as date-only.
  final String? occurredTime;

  /// Short label.
  final String? title;

  /// Measured value.
  final String? value;

  /// Unit label.
  final String? unit;

  /// Free-text note.
  final String? note;

  /// Structured payload for kind-specific data. For sleep: { startAt, endAt, durationMinutes, quality?, deepMinutes?, lightMinutes?, remMinutes? }. endAt is an ISO 8601 timestamp whose date component matches occurredAt (wake date). startAt is the bedtime ISO 8601 timestamp and may fall on the day before occurredAt for cross-midnight sleep.
  final dynamic payload;

  /// Attachment metadata. File upload itself is handled separately.
  final List<DailyRecordAttachmentInputDto>? attachments;

  Map<String, Object?> toJson() => _$CreateDailyRecordDtoToJson(this);
}
