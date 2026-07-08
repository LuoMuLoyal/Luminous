// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'daily_record_candidate_kind.dart';

part 'daily_record_candidate_item_dto.g.dart';

@JsonSerializable()
class DailyRecordCandidateItemDto {
  const DailyRecordCandidateItemDto({
    required this.kind,
    required this.occurredAt,
    required this.rationale,
    this.title,
    this.value,
    this.unit,
    this.note,
    this.payload,
  });

  factory DailyRecordCandidateItemDto.fromJson(Map<String, Object?> json) =>
      _$DailyRecordCandidateItemDtoFromJson(json);

  final DailyRecordCandidateKind kind;

  /// Candidate occurred date in YYYY-MM-DD format.
  final String occurredAt;

  /// Short candidate title.
  final String? title;

  /// Candidate measured value.
  final String? value;

  /// Candidate unit.
  final String? unit;

  /// Candidate free-text note.
  final String? note;

  /// Structured candidate payload. For sleep, this may include durationMinutes and optional timing hints.
  final dynamic payload;

  /// Human-readable reason showing which phrase or fact led to this candidate.
  final String rationale;

  Map<String, Object?> toJson() => _$DailyRecordCandidateItemDtoToJson(this);
}
