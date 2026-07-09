// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'suggestion_history_data_dto.dart';

part 'suggestion_history_response_dto.g.dart';

@JsonSerializable()
class SuggestionHistoryResponseDto {
  const SuggestionHistoryResponseDto({
    required this.code,
    required this.message,
    required this.data,
  });

  factory SuggestionHistoryResponseDto.fromJson(Map<String, Object?> json) =>
      _$SuggestionHistoryResponseDtoFromJson(json);

  final num code;
  final String message;
  final SuggestionHistoryDataDto data;

  Map<String, Object?> toJson() => _$SuggestionHistoryResponseDtoToJson(this);
}
