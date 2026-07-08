// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'generate_daily_record_candidates_dto.g.dart';

@JsonSerializable()
class GenerateDailyRecordCandidatesDto {
  const GenerateDailyRecordCandidatesDto({
    required this.text,
    required this.occurredAt,
    this.timezone,
  });

  factory GenerateDailyRecordCandidatesDto.fromJson(
    Map<String, Object?> json,
  ) => _$GenerateDailyRecordCandidatesDtoFromJson(json);

  /// Natural-language note to be parsed into candidate daily records.
  final String text;

  /// Wake date in YYYY-MM-DD format used as the candidate record date baseline.
  final String occurredAt;

  /// Optional user timezone hint used only for interpretation wording. No server timezone conversion is persisted.
  final String? timezone;

  Map<String, Object?> toJson() =>
      _$GenerateDailyRecordCandidatesDtoToJson(this);
}
