//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/event_review_data_coverage_check_ins.dart';
import 'package:lucent_api/src/model/event_review_data_coverage_dose_logs.dart';
import 'package:lucent_api/src/model/event_review_data_coverage_records.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'event_review_data_coverage.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EventReviewDataCoverage {
  /// Returns a new [EventReviewDataCoverage] instance.
  EventReviewDataCoverage({
    required this.checkIns,

    required this.records,

    required this.doseLogs,
  });

  @JsonKey(name: r'checkIns', required: true, includeIfNull: false)
  final EventReviewDataCoverageCheckIns checkIns;

  @JsonKey(name: r'records', required: true, includeIfNull: false)
  final EventReviewDataCoverageRecords records;

  @JsonKey(name: r'doseLogs', required: true, includeIfNull: false)
  final EventReviewDataCoverageDoseLogs doseLogs;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventReviewDataCoverage &&
          other.checkIns == checkIns &&
          other.records == records &&
          other.doseLogs == doseLogs;

  @override
  int get hashCode => checkIns.hashCode + records.hashCode + doseLogs.hashCode;

  factory EventReviewDataCoverage.fromJson(Map<String, dynamic> json) =>
      _$EventReviewDataCoverageFromJson(json);

  Map<String, dynamic> toJson() => _$EventReviewDataCoverageToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
