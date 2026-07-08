// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'daily_record_attachment_dto.dart';
import 'daily_record_kind.dart';

part 'daily_record_item_dto.g.dart';

@JsonSerializable()
class DailyRecordItemDto {
  const DailyRecordItemDto({
    required this.id,
    required this.kind,
    required this.occurredAt,
    required this.attachments,
    required this.createdAt,
    required this.updatedAt,
    this.occurredTime,
    this.title,
    this.value,
    this.unit,
    this.note,
    this.source,
    this.payload,
    this.mealAnalysisStatus,
    this.mealAnalysisCoverage,
    this.mealAnalysisUpdatedAt,
    this.mealAnalysisFailureReason,
    this.mealShortDescription,
    this.mealTopFoods,
  });

  factory DailyRecordItemDto.fromJson(Map<String, Object?> json) =>
      _$DailyRecordItemDtoFromJson(json);

  /// Record id.
  final String id;
  final DailyRecordKind kind;

  /// Date in YYYY-MM-DD format.
  final String occurredAt;

  /// Time in HH:mm 24-hour format when available.
  final String? occurredTime;

  /// Short label.
  final String? title;

  /// Measured value.
  final String? value;

  /// Unit label.
  final String? unit;

  /// Free-text note.
  final String? note;

  /// Source.
  final String? source;

  /// Structured payload for kind-specific data. For sleep: { startAt, endAt, durationMinutes, quality?, deepMinutes?, lightMinutes?, remMinutes? }.
  final dynamic payload;

  /// Meal analysis status for meal records.
  final String? mealAnalysisStatus;

  /// Meal analysis coverage for meal records.
  final String? mealAnalysisCoverage;

  /// Meal analysis updated timestamp (ISO 8601).
  final String? mealAnalysisUpdatedAt;

  /// Display-safe meal analysis failure reason.
  final String? mealAnalysisFailureReason;

  /// Short meal description for list reads.
  final String? mealShortDescription;

  /// Top recognized foods for list reads.
  final List<String>? mealTopFoods;
  final List<DailyRecordAttachmentDto> attachments;

  /// Created at (ISO 8601).
  final String createdAt;

  /// Updated at (ISO 8601).
  final String updatedAt;

  Map<String, Object?> toJson() => _$DailyRecordItemDtoToJson(this);
}
