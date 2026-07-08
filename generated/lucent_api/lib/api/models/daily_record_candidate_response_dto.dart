// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'daily_record_candidate_data_dto.dart';

part 'daily_record_candidate_response_dto.g.dart';

@JsonSerializable()
class DailyRecordCandidateResponseDto {
  const DailyRecordCandidateResponseDto({
    required this.code,
    required this.message,
    required this.data,
  });

  factory DailyRecordCandidateResponseDto.fromJson(Map<String, Object?> json) =>
      _$DailyRecordCandidateResponseDtoFromJson(json);

  final num code;
  final String message;
  final DailyRecordCandidateDataDto data;

  Map<String, Object?> toJson() =>
      _$DailyRecordCandidateResponseDtoToJson(this);
}
