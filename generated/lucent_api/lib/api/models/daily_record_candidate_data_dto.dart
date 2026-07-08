// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'daily_record_candidate_item_dto.dart';

part 'daily_record_candidate_data_dto.g.dart';

@JsonSerializable()
class DailyRecordCandidateDataDto {
  const DailyRecordCandidateDataDto({
    required this.locale,
    required this.generatedAt,
    required this.confirmationHint,
    required this.items,
  });

  factory DailyRecordCandidateDataDto.fromJson(Map<String, Object?> json) =>
      _$DailyRecordCandidateDataDtoFromJson(json);

  /// Normalized parse locale.
  final String locale;

  /// ISO-8601 timestamp when candidates were generated.
  final String generatedAt;

  /// Short UI hint telling the client that these are candidates, not saved records.
  final String confirmationHint;
  final List<DailyRecordCandidateItemDto> items;

  Map<String, Object?> toJson() => _$DailyRecordCandidateDataDtoToJson(this);
}
