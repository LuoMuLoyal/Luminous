//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/event_review_list_response_items.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'event_review_list_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EventReviewListResponse {
  /// Returns a new [EventReviewListResponse] instance.
  EventReviewListResponse({
    required this.items,

    required this.total,

    required this.nextCursor,
  });

  @JsonKey(name: r'items', required: true, includeIfNull: false)
  final List<EventReviewListResponseItems> items;

  /// Total matching events for the filter.
  @JsonKey(name: r'total', required: true, includeIfNull: false)
  final num total;

  @JsonKey(name: r'nextCursor', required: true, includeIfNull: true)
  final String? nextCursor;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventReviewListResponse &&
          other.items == items &&
          other.total == total &&
          other.nextCursor == nextCursor;

  @override
  int get hashCode =>
      items.hashCode +
      total.hashCode +
      (nextCursor == null ? 0 : nextCursor.hashCode);

  factory EventReviewListResponse.fromJson(Map<String, dynamic> json) =>
      _$EventReviewListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$EventReviewListResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
