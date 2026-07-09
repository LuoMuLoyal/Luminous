// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'suggestion_item_dto.dart';

part 'today_suggestions_data_dto.g.dart';

@JsonSerializable()
class TodaySuggestionsDataDto {
  const TodaySuggestionsDataDto({
    required this.generatedAt,
    this.primary,
    this.secondary,
    this.observations,
  });

  factory TodaySuggestionsDataDto.fromJson(Map<String, Object?> json) =>
      _$TodaySuggestionsDataDtoFromJson(json);

  /// When the suggestions were generated
  final String generatedAt;

  /// Primary suggestion card (highest priority)
  final SuggestionItemDto? primary;

  /// Secondary suggestion cards (max 2)
  final List<SuggestionItemDto>? secondary;

  /// Low-confidence observations
  final List<SuggestionItemDto>? observations;

  Map<String, Object?> toJson() => _$TodaySuggestionsDataDtoToJson(this);
}
