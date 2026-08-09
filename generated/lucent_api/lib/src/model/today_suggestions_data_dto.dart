//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/suggestion_item_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'today_suggestions_data_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TodaySuggestionsDataDto {
  /// Returns a new [TodaySuggestionsDataDto] instance.
  TodaySuggestionsDataDto({
    required this.generatedAt,
    this.primary,
    this.secondary,
    this.observations,
    this.degraded,
  });

  /// When the suggestions were generated
  @JsonKey(name: r'generatedAt', required: true, includeIfNull: false)
  final String generatedAt;

  /// Primary suggestion card (highest priority)
  @JsonKey(name: r'primary', required: false, includeIfNull: false)
  final SuggestionItemDto? primary;

  /// Secondary suggestion cards (max 2)
  @JsonKey(name: r'secondary', required: false, includeIfNull: false)
  final List<SuggestionItemDto>? secondary;

  /// Low-confidence observations
  @JsonKey(name: r'observations', required: false, includeIfNull: false)
  final List<SuggestionItemDto>? observations;

  /// When true, one or more suggestion rules threw an error during evaluation — the returned list may be incomplete.
  @JsonKey(name: r'degraded', required: false, includeIfNull: false)
  final Object? degraded;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodaySuggestionsDataDto &&
          other.generatedAt == generatedAt &&
          other.primary == primary &&
          other.secondary == secondary &&
          other.observations == observations &&
          other.degraded == degraded;

  @override
  int get hashCode =>
      generatedAt.hashCode +
      primary.hashCode +
      secondary.hashCode +
      observations.hashCode +
      degraded.hashCode;

  factory TodaySuggestionsDataDto.fromJson(Map<String, dynamic> json) =>
      _$TodaySuggestionsDataDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TodaySuggestionsDataDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
