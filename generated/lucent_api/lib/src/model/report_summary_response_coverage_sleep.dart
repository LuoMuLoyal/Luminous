//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'report_summary_response_coverage_sleep.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReportSummaryResponseCoverageSleep {
  /// Returns a new [ReportSummaryResponseCoverageSleep] instance.
  ReportSummaryResponseCoverageSleep({
    required this.trackedDays,

    required this.totalDays,
  });

  @JsonKey(name: r'trackedDays', required: true, includeIfNull: false)
  final num trackedDays;

  @JsonKey(name: r'totalDays', required: true, includeIfNull: false)
  final num totalDays;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportSummaryResponseCoverageSleep &&
          other.trackedDays == trackedDays &&
          other.totalDays == totalDays;

  @override
  int get hashCode => trackedDays.hashCode + totalDays.hashCode;

  factory ReportSummaryResponseCoverageSleep.fromJson(
    Map<String, dynamic> json,
  ) => _$ReportSummaryResponseCoverageSleepFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ReportSummaryResponseCoverageSleepToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
