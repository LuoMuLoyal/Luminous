//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'daily_record_candidate_response_items.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DailyRecordCandidateResponseItems {
  /// Returns a new [DailyRecordCandidateResponseItems] instance.
  DailyRecordCandidateResponseItems({
    required this.kind,

    required this.occurredAt,

    required this.title,

    required this.value,

    required this.unit,

    required this.note,

    required this.payload,

    required this.rationale,
  });

  @JsonKey(
    name: r'kind',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        DailyRecordCandidateResponseItemsKindEnum.unknownDefaultOpenApi,
  )
  final DailyRecordCandidateResponseItemsKindEnum kind;

  /// Candidate occurred date in YYYY-MM-DD format.
  @JsonKey(name: r'occurredAt', required: true, includeIfNull: false)
  final String occurredAt;

  /// Short candidate title.
  @JsonKey(name: r'title', required: true, includeIfNull: true)
  final String? title;

  /// Candidate measured value.
  @JsonKey(name: r'value', required: true, includeIfNull: true)
  final String? value;

  /// Candidate unit.
  @JsonKey(name: r'unit', required: true, includeIfNull: true)
  final String? unit;

  /// Candidate free-text note.
  @JsonKey(name: r'note', required: true, includeIfNull: true)
  final String? note;

  /// Structured candidate payload. For sleep, this may include durationMinutes and optional timing hints.
  @JsonKey(name: r'payload', required: true, includeIfNull: true)
  final Map<String, Object>? payload;

  /// Human-readable reason showing which phrase or fact led to this candidate.
  @JsonKey(name: r'rationale', required: true, includeIfNull: false)
  final String rationale;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyRecordCandidateResponseItems &&
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

  factory DailyRecordCandidateResponseItems.fromJson(
    Map<String, dynamic> json,
  ) => _$DailyRecordCandidateResponseItemsFromJson(json);

  Map<String, dynamic> toJson() =>
      _$DailyRecordCandidateResponseItemsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum DailyRecordCandidateResponseItemsKindEnum {
  @JsonValue(r'water')
  water(r'water'),
  @JsonValue(r'meal')
  meal(r'meal'),
  @JsonValue(r'symptom')
  symptom(r'symptom'),
  @JsonValue(r'note')
  note(r'note'),
  @JsonValue(r'sleep')
  sleep(r'sleep'),
  @JsonValue(r'vital')
  vital(r'vital'),
  @JsonValue(r'activity')
  activity(r'activity'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const DailyRecordCandidateResponseItemsKindEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
