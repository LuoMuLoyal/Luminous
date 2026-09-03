//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/event_review_data_dto_coverage_check_ins.dart';
import 'package:lucent_api/src/model/event_review_data_dto_coverage_daily_records.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'event_review_data_dto_coverage.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EventReviewDataDtoCoverage {
  /// Returns a new [EventReviewDataDtoCoverage] instance.
  EventReviewDataDtoCoverage({
    required this.checkIns,

    required this.dailyRecords,

    required this.doseLogs,
  });

  @JsonKey(name: r'checkIns', required: true, includeIfNull: false)
  final EventReviewDataDtoCoverageCheckIns checkIns;

  @JsonKey(name: r'dailyRecords', required: true, includeIfNull: false)
  final EventReviewDataDtoCoverageDailyRecords dailyRecords;

  @JsonKey(name: r'doseLogs', required: true, includeIfNull: false)
  final EventReviewDataDtoCoverageDailyRecords doseLogs;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventReviewDataDtoCoverage &&
          other.checkIns == checkIns &&
          other.dailyRecords == dailyRecords &&
          other.doseLogs == doseLogs;

  @override
  int get hashCode =>
      checkIns.hashCode + dailyRecords.hashCode + doseLogs.hashCode;

  factory EventReviewDataDtoCoverage.fromJson(Map<String, dynamic> json) =>
      _$EventReviewDataDtoCoverageFromJson(json);

  Map<String, dynamic> toJson() => _$EventReviewDataDtoCoverageToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
