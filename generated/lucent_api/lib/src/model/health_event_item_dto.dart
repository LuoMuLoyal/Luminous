//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/health_event_outcome.dart';
import 'package:lucent_api/src/model/health_event_status.dart';
import 'package:lucent_api/src/model/health_event_kind.dart';
import 'package:lucent_api/src/model/health_event_check_in_response_dto.dart';
import 'package:lucent_api/src/model/health_event_coverage_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'health_event_item_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class HealthEventItemDto {
  /// Returns a new [HealthEventItemDto] instance.
  HealthEventItemDto({
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
    unknownEnumValue: HealthEventKind.unknownDefaultOpenApi,
  )
  final HealthEventKind kind;

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'title', required: true, includeIfNull: false)
  final String title;

  @JsonKey(
    name: r'status',
    required: true,
    includeIfNull: false,
    unknownEnumValue: HealthEventStatus.unknownDefaultOpenApi,
  )
  final HealthEventStatus status;

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
    unknownEnumValue: HealthEventOutcome.unknownDefaultOpenApi,
  )
  final HealthEventOutcome? outcome;

  @JsonKey(name: r'reasonRecordId', required: true, includeIfNull: true)
  final String? reasonRecordId;

  @JsonKey(name: r'currentMedicineIds', required: true, includeIfNull: false)
  final List<String> currentMedicineIds;

  @JsonKey(name: r'checkIn', required: true, includeIfNull: true)
  final HealthEventCheckInResponseDto? checkIn;

  @JsonKey(name: r'coverage', required: true, includeIfNull: false)
  final HealthEventCoverageDto coverage;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthEventItemDto &&
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

  factory HealthEventItemDto.fromJson(Map<String, dynamic> json) =>
      _$HealthEventItemDtoFromJson(json);

  Map<String, dynamic> toJson() => _$HealthEventItemDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
