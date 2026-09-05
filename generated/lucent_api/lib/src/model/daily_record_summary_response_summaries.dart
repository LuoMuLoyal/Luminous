//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/daily_record_summary_response_summaries_latest.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'daily_record_summary_response_summaries.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DailyRecordSummaryResponseSummaries {
  /// Returns a new [DailyRecordSummaryResponseSummaries] instance.
  DailyRecordSummaryResponseSummaries({
    required this.kind,

    required this.count,

    required this.latest,
  });

  @JsonKey(
    name: r'kind',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        DailyRecordSummaryResponseSummariesKindEnum.unknownDefaultOpenApi,
  )
  final DailyRecordSummaryResponseSummariesKindEnum kind;

  /// Count of records for this kind on the given date.
  // minimum: -9007199254740991
  // maximum: 9007199254740991
  @JsonKey(name: r'count', required: true, includeIfNull: false)
  final int count;

  @JsonKey(name: r'latest', required: true, includeIfNull: true)
  final DailyRecordSummaryResponseSummariesLatest? latest;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyRecordSummaryResponseSummaries &&
          other.kind == kind &&
          other.count == count &&
          other.latest == latest;

  @override
  int get hashCode =>
      kind.hashCode + count.hashCode + (latest == null ? 0 : latest.hashCode);

  factory DailyRecordSummaryResponseSummaries.fromJson(
    Map<String, dynamic> json,
  ) => _$DailyRecordSummaryResponseSummariesFromJson(json);

  Map<String, dynamic> toJson() =>
      _$DailyRecordSummaryResponseSummariesToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum DailyRecordSummaryResponseSummariesKindEnum {
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

  const DailyRecordSummaryResponseSummariesKindEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
