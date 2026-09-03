//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/daily_record_summary_response_dto_summaries_inner_latest.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'daily_record_summary_response_dto_summaries_inner.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DailyRecordSummaryResponseDtoSummariesInner {
  /// Returns a new [DailyRecordSummaryResponseDtoSummariesInner] instance.
  DailyRecordSummaryResponseDtoSummariesInner({
    required this.kind,

    required this.count,

    required this.latest,
  });

  @JsonKey(
    name: r'kind',
    required: true,
    includeIfNull: false,
    unknownEnumValue: DailyRecordSummaryResponseDtoSummariesInnerKindEnum
        .unknownDefaultOpenApi,
  )
  final DailyRecordSummaryResponseDtoSummariesInnerKindEnum kind;

  /// Count of records for this kind on the given date.
  // minimum: -9007199254740991
  // maximum: 9007199254740991
  @JsonKey(name: r'count', required: true, includeIfNull: false)
  final int count;

  @JsonKey(name: r'latest', required: true, includeIfNull: true)
  final DailyRecordSummaryResponseDtoSummariesInnerLatest? latest;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyRecordSummaryResponseDtoSummariesInner &&
          other.kind == kind &&
          other.count == count &&
          other.latest == latest;

  @override
  int get hashCode =>
      kind.hashCode + count.hashCode + (latest == null ? 0 : latest.hashCode);

  factory DailyRecordSummaryResponseDtoSummariesInner.fromJson(
    Map<String, dynamic> json,
  ) => _$DailyRecordSummaryResponseDtoSummariesInnerFromJson(json);

  Map<String, dynamic> toJson() =>
      _$DailyRecordSummaryResponseDtoSummariesInnerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum DailyRecordSummaryResponseDtoSummariesInnerKindEnum {
  @JsonValue(r'water')
  water(r'water'),
  @JsonValue(r'meal')
  meal(r'meal'),
  @JsonValue(r'vital')
  vital(r'vital'),
  @JsonValue(r'mood')
  mood(r'mood'),
  @JsonValue(r'symptom')
  symptom(r'symptom'),
  @JsonValue(r'activity')
  activity(r'activity'),
  @JsonValue(r'note')
  note(r'note'),
  @JsonValue(r'sleep')
  sleep(r'sleep'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const DailyRecordSummaryResponseDtoSummariesInnerKindEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
