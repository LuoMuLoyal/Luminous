//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/suggestion_history_response_items.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'suggestion_history_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SuggestionHistoryResponse {
  /// Returns a new [SuggestionHistoryResponse] instance.
  SuggestionHistoryResponse({
    required this.items,

    required this.total,

    required this.startDate,

    required this.endDate,
  });

  /// Suggestion history items
  @JsonKey(name: r'items', required: true, includeIfNull: false)
  final List<SuggestionHistoryResponseItems> items;

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
      other is SuggestionHistoryResponse &&
          other.items == items &&
          other.total == total &&
          other.startDate == startDate &&
          other.endDate == endDate;

  @override
  int get hashCode =>
      items.hashCode + total.hashCode + startDate.hashCode + endDate.hashCode;

  factory SuggestionHistoryResponse.fromJson(Map<String, dynamic> json) =>
      _$SuggestionHistoryResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SuggestionHistoryResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
