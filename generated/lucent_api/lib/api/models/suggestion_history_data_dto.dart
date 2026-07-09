// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'suggestion_history_item_dto.dart';

part 'suggestion_history_data_dto.g.dart';

@JsonSerializable()
class SuggestionHistoryDataDto {
  const SuggestionHistoryDataDto({
    required this.items,
    required this.total,
    required this.startDate,
    required this.endDate,
  });

  factory SuggestionHistoryDataDto.fromJson(Map<String, Object?> json) =>
      _$SuggestionHistoryDataDtoFromJson(json);

  /// Suggestion history items
  final List<SuggestionHistoryItemDto> items;

  /// Total count of matching items
  final num total;

  /// Start date used for the query
  final String startDate;

  /// End date used for the query
  final String endDate;

  Map<String, Object?> toJson() => _$SuggestionHistoryDataDtoToJson(this);
}
