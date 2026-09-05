//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/health_event_list_response_items_check_in.dart';
import 'package:lucent_api/src/model/health_event_list_response_items_coverage.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'health_event_list_response_items.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class HealthEventListResponseItems {
  /// Returns a new [HealthEventListResponseItems] instance.
  HealthEventListResponseItems({
    required this.kind,

    required this.id,

    required this.title,

    required this.status,

    required this.startedAt,

    required this.endedAt,

    required this.outcome,

    required this.reasonRecordId,

    required this.currentMedicineIds,

    required this.checkIn,

    required this.coverage,
  });

  @JsonKey(
    name: r'kind',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        HealthEventListResponseItemsKindEnum.unknownDefaultOpenApi,
  )
  final HealthEventListResponseItemsKindEnum kind;

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'title', required: true, includeIfNull: false)
  final String title;

  @JsonKey(
    name: r'status',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        HealthEventListResponseItemsStatusEnum.unknownDefaultOpenApi,
  )
  final HealthEventListResponseItemsStatusEnum status;

  /// Start time in ISO 8601 format.
  @JsonKey(name: r'startedAt', required: true, includeIfNull: false)
  final String startedAt;

  /// End time in ISO 8601 format, or null while active.
  @JsonKey(name: r'endedAt', required: true, includeIfNull: true)
  final String? endedAt;

  @JsonKey(
    name: r'outcome',
    required: true,
    includeIfNull: true,
    unknownEnumValue:
        HealthEventListResponseItemsOutcomeEnum.unknownDefaultOpenApi,
  )
  final HealthEventListResponseItemsOutcomeEnum? outcome;

  @JsonKey(name: r'reasonRecordId', required: true, includeIfNull: true)
  final String? reasonRecordId;

  @JsonKey(name: r'currentMedicineIds', required: true, includeIfNull: false)
  final List<String> currentMedicineIds;

  @JsonKey(name: r'checkIn', required: true, includeIfNull: true)
  final HealthEventListResponseItemsCheckIn? checkIn;

  @JsonKey(name: r'coverage', required: true, includeIfNull: false)
  final HealthEventListResponseItemsCoverage coverage;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthEventListResponseItems &&
          other.kind == kind &&
          other.id == id &&
          other.title == title &&
          other.status == status &&
          other.startedAt == startedAt &&
          other.endedAt == endedAt &&
          other.outcome == outcome &&
          other.reasonRecordId == reasonRecordId &&
          other.currentMedicineIds == currentMedicineIds &&
          other.checkIn == checkIn &&
          other.coverage == coverage;

  @override
  int get hashCode =>
      kind.hashCode +
      id.hashCode +
      title.hashCode +
      status.hashCode +
      startedAt.hashCode +
      (endedAt == null ? 0 : endedAt.hashCode) +
      (outcome == null ? 0 : outcome.hashCode) +
      (reasonRecordId == null ? 0 : reasonRecordId.hashCode) +
      currentMedicineIds.hashCode +
      (checkIn == null ? 0 : checkIn.hashCode) +
      coverage.hashCode;

  factory HealthEventListResponseItems.fromJson(Map<String, dynamic> json) =>
      _$HealthEventListResponseItemsFromJson(json);

  Map<String, dynamic> toJson() => _$HealthEventListResponseItemsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum HealthEventListResponseItemsKindEnum {
  @JsonValue(r'symptom')
  symptom(r'symptom'),
  @JsonValue(r'other')
  other(r'other'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const HealthEventListResponseItemsKindEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum HealthEventListResponseItemsStatusEnum {
  @JsonValue(r'active')
  active(r'active'),
  @JsonValue(r'ended')
  ended(r'ended'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const HealthEventListResponseItemsStatusEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum HealthEventListResponseItemsOutcomeEnum {
  @JsonValue(r'improved')
  improved(r'improved'),
  @JsonValue(r'unchanged')
  unchanged(r'unchanged'),
  @JsonValue(r'worsened')
  worsened(r'worsened'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const HealthEventListResponseItemsOutcomeEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
