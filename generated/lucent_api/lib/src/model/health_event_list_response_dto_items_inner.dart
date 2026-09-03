//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/health_event_response_dto_coverage.dart';
import 'package:lucent_api/src/model/health_event_response_dto_check_in.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'health_event_list_response_dto_items_inner.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class HealthEventListResponseDtoItemsInner {
  /// Returns a new [HealthEventListResponseDtoItemsInner] instance.
  HealthEventListResponseDtoItemsInner({
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
        HealthEventListResponseDtoItemsInnerKindEnum.unknownDefaultOpenApi,
  )
  final HealthEventListResponseDtoItemsInnerKindEnum kind;

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'title', required: true, includeIfNull: false)
  final String title;

  @JsonKey(
    name: r'status',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        HealthEventListResponseDtoItemsInnerStatusEnum.unknownDefaultOpenApi,
  )
  final HealthEventListResponseDtoItemsInnerStatusEnum status;

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
        HealthEventListResponseDtoItemsInnerOutcomeEnum.unknownDefaultOpenApi,
  )
  final HealthEventListResponseDtoItemsInnerOutcomeEnum? outcome;

  @JsonKey(name: r'reasonRecordId', required: true, includeIfNull: true)
  final String? reasonRecordId;

  @JsonKey(name: r'currentMedicineIds', required: true, includeIfNull: false)
  final List<String> currentMedicineIds;

  @JsonKey(name: r'checkIn', required: true, includeIfNull: true)
  final HealthEventResponseDtoCheckIn? checkIn;

  @JsonKey(name: r'coverage', required: true, includeIfNull: false)
  final HealthEventResponseDtoCoverage coverage;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthEventListResponseDtoItemsInner &&
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

  factory HealthEventListResponseDtoItemsInner.fromJson(
    Map<String, dynamic> json,
  ) => _$HealthEventListResponseDtoItemsInnerFromJson(json);

  Map<String, dynamic> toJson() =>
      _$HealthEventListResponseDtoItemsInnerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum HealthEventListResponseDtoItemsInnerKindEnum {
  @JsonValue(r'symptom')
  symptom(r'symptom'),
  @JsonValue(r'other')
  other(r'other'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const HealthEventListResponseDtoItemsInnerKindEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum HealthEventListResponseDtoItemsInnerStatusEnum {
  @JsonValue(r'active')
  active(r'active'),
  @JsonValue(r'ended')
  ended(r'ended'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const HealthEventListResponseDtoItemsInnerStatusEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum HealthEventListResponseDtoItemsInnerOutcomeEnum {
  @JsonValue(r'improved')
  improved(r'improved'),
  @JsonValue(r'unchanged')
  unchanged(r'unchanged'),
  @JsonValue(r'worsened')
  worsened(r'worsened'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const HealthEventListResponseDtoItemsInnerOutcomeEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
