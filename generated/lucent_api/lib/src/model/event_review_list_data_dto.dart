//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/event_review_event_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'event_review_list_data_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EventReviewListDataDto {
  /// Returns a new [EventReviewListDataDto] instance.
  EventReviewListDataDto({
    required this.items,

    required this.total,

    required this.nextCursor,
  });

  @JsonKey(name: r'items', required: true, includeIfNull: false)
  final List<EventReviewEventDto> items;

  /// Total matching events for the filter.
  @JsonKey(name: r'total', required: true, includeIfNull: false)
  final num total;

  /// Cursor for the next page (last item startedAt in ISO 8601), or null on the last page.
  @JsonKey(name: r'nextCursor', required: true, includeIfNull: true)
  final String? nextCursor;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventReviewListDataDto &&
          other.items == items &&
          other.total == total &&
          other.nextCursor == nextCursor;

  @override
  int get hashCode =>
      items.hashCode +
      total.hashCode +
      (nextCursor == null ? 0 : nextCursor.hashCode);

  factory EventReviewListDataDto.fromJson(Map<String, dynamic> json) =>
      _$EventReviewListDataDtoFromJson(json);

  Map<String, dynamic> toJson() => _$EventReviewListDataDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
