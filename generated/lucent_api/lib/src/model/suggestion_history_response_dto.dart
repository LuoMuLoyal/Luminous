//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/suggestion_history_response_dto_items_inner.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'suggestion_history_response_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SuggestionHistoryResponseDto {
  /// Returns a new [SuggestionHistoryResponseDto] instance.
  SuggestionHistoryResponseDto({
    required this.items,

    required this.total,

    required this.startDate,

    required this.endDate,
  });

  /// Suggestion history items
  @JsonKey(name: r'items', required: true, includeIfNull: false)
  final List<SuggestionHistoryResponseDtoItemsInner> items;

  /// Total count of matching items
  @JsonKey(name: r'total', required: true, includeIfNull: false)
  final num total;

  /// Start date used for the query
  @JsonKey(name: r'startDate', required: true, includeIfNull: false)
  final String startDate;

  /// End date used for the query
  @JsonKey(name: r'endDate', required: true, includeIfNull: false)
  final String endDate;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SuggestionHistoryResponseDto &&
          other.items == items &&
          other.total == total &&
          other.startDate == startDate &&
          other.endDate == endDate;

  @override
  int get hashCode =>
      items.hashCode + total.hashCode + startDate.hashCode + endDate.hashCode;

  factory SuggestionHistoryResponseDto.fromJson(Map<String, dynamic> json) =>
      _$SuggestionHistoryResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SuggestionHistoryResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
