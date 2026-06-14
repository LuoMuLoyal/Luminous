//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_openapi/src/model/daily_record_candidate_kind.dart';
import 'package:json_annotation/json_annotation.dart';

part 'daily_record_candidate_item_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DailyRecordCandidateItemDto {
  /// Returns a new [DailyRecordCandidateItemDto] instance.
  DailyRecordCandidateItemDto({
    required this.kind,

    required this.occurredAt,

    this.title,

    this.value,

    this.unit,

    this.note,

    this.payload,

    required this.rationale,
  });

  @JsonKey(
    name: r'kind',
    required: true,
    includeIfNull: false,
    unknownEnumValue: DailyRecordCandidateKind.unknownDefaultOpenApi,
  )
  final DailyRecordCandidateKind kind;

  /// Candidate occurred date in YYYY-MM-DD format.
  @JsonKey(name: r'occurredAt', required: true, includeIfNull: false)
  final String occurredAt;

  /// Short candidate title.
  @JsonKey(name: r'title', required: false, includeIfNull: false)
  final Object? title;

  /// Candidate measured value.
  @JsonKey(name: r'value', required: false, includeIfNull: false)
  final Object? value;

  /// Candidate unit.
  @JsonKey(name: r'unit', required: false, includeIfNull: false)
  final Object? unit;

  /// Candidate free-text note.
  @JsonKey(name: r'note', required: false, includeIfNull: false)
  final Object? note;

  /// Structured candidate payload. For sleep, this may include durationMinutes and optional timing hints.
  @JsonKey(name: r'payload', required: false, includeIfNull: false)
  final Map<String, Object>? payload;

  /// Human-readable reason showing which phrase or fact led to this candidate.
  @JsonKey(name: r'rationale', required: true, includeIfNull: false)
  final String rationale;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyRecordCandidateItemDto &&
          other.kind == kind &&
          other.occurredAt == occurredAt &&
          other.title == title &&
          other.value == value &&
          other.unit == unit &&
          other.note == note &&
          other.payload == payload &&
          other.rationale == rationale;

  @override
  int get hashCode =>
      kind.hashCode +
      occurredAt.hashCode +
      (title == null ? 0 : title.hashCode) +
      (value == null ? 0 : value.hashCode) +
      (unit == null ? 0 : unit.hashCode) +
      (note == null ? 0 : note.hashCode) +
      (payload == null ? 0 : payload.hashCode) +
      rationale.hashCode;

  factory DailyRecordCandidateItemDto.fromJson(Map<String, dynamic> json) =>
      _$DailyRecordCandidateItemDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DailyRecordCandidateItemDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
