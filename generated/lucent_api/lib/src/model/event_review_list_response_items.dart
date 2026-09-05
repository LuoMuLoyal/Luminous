//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'event_review_list_response_items.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EventReviewListResponseItems {
  /// Returns a new [EventReviewListResponseItems] instance.
  EventReviewListResponseItems({
    required this.id,

    required this.kind,

    required this.title,

    required this.status,

    required this.startedAt,

    required this.endedAt,

    required this.outcome,

    required this.currentMedicineIds,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(
    name: r'kind',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        EventReviewListResponseItemsKindEnum.unknownDefaultOpenApi,
  )
  final EventReviewListResponseItemsKindEnum kind;

  @JsonKey(name: r'title', required: true, includeIfNull: false)
  final String title;

  @JsonKey(
    name: r'status',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        EventReviewListResponseItemsStatusEnum.unknownDefaultOpenApi,
  )
  final EventReviewListResponseItemsStatusEnum status;

  /// Start time in ISO 8601 format.
  @JsonKey(name: r'startedAt', required: true, includeIfNull: false)
  final String startedAt;

  @JsonKey(name: r'endedAt', required: true, includeIfNull: true)
  final String? endedAt;

  @JsonKey(
    name: r'outcome',
    required: true,
    includeIfNull: true,
    unknownEnumValue:
        EventReviewListResponseItemsOutcomeEnum.unknownDefaultOpenApi,
  )
  final EventReviewListResponseItemsOutcomeEnum? outcome;

  @JsonKey(name: r'currentMedicineIds', required: true, includeIfNull: false)
  final List<String> currentMedicineIds;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventReviewListResponseItems &&
          other.id == id &&
          other.kind == kind &&
          other.title == title &&
          other.status == status &&
          other.startedAt == startedAt &&
          other.endedAt == endedAt &&
          other.outcome == outcome &&
          other.currentMedicineIds == currentMedicineIds;

  @override
  int get hashCode =>
      id.hashCode +
      kind.hashCode +
      title.hashCode +
      status.hashCode +
      startedAt.hashCode +
      (endedAt == null ? 0 : endedAt.hashCode) +
      (outcome == null ? 0 : outcome.hashCode) +
      currentMedicineIds.hashCode;

  factory EventReviewListResponseItems.fromJson(Map<String, dynamic> json) =>
      _$EventReviewListResponseItemsFromJson(json);

  Map<String, dynamic> toJson() => _$EventReviewListResponseItemsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum EventReviewListResponseItemsKindEnum {
  @JsonValue(r'symptom')
  symptom(r'symptom'),
  @JsonValue(r'other')
  other(r'other'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const EventReviewListResponseItemsKindEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum EventReviewListResponseItemsStatusEnum {
  @JsonValue(r'active')
  active(r'active'),
  @JsonValue(r'ended')
  ended(r'ended'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const EventReviewListResponseItemsStatusEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum EventReviewListResponseItemsOutcomeEnum {
  @JsonValue(r'improved')
  improved(r'improved'),
  @JsonValue(r'unchanged')
  unchanged(r'unchanged'),
  @JsonValue(r'worsened')
  worsened(r'worsened'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const EventReviewListResponseItemsOutcomeEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
