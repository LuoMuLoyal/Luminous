// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'today_suggestions_data_dto.dart';

part 'today_suggestions_response_dto.g.dart';

@JsonSerializable()
class TodaySuggestionsResponseDto {
  const TodaySuggestionsResponseDto({
    required this.code,
    required this.message,
    required this.data,
  });

  factory TodaySuggestionsResponseDto.fromJson(Map<String, Object?> json) =>
      _$TodaySuggestionsResponseDtoFromJson(json);

  final num code;
  final String message;
  final TodaySuggestionsDataDto data;

  Map<String, Object?> toJson() => _$TodaySuggestionsResponseDtoToJson(this);
}
