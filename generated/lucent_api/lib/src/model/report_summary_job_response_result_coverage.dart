//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/report_summary_job_response_result_coverage_water.dart';
import 'package:lucent_api/src/model/report_summary_job_response_result_coverage_sleep.dart';
import 'package:lucent_api/src/model/report_summary_job_response_result_coverage_medication.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'report_summary_job_response_result_coverage.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReportSummaryJobResponseResultCoverage {
  /// Returns a new [ReportSummaryJobResponseResultCoverage] instance.
  ReportSummaryJobResponseResultCoverage({
    required this.medication,

    required this.water,

    required this.sleep,
  });

  @JsonKey(name: r'medication', required: true, includeIfNull: false)
  final ReportSummaryJobResponseResultCoverageMedication medication;

  @JsonKey(name: r'water', required: true, includeIfNull: false)
  final ReportSummaryJobResponseResultCoverageWater water;

  @JsonKey(name: r'sleep', required: true, includeIfNull: false)
  final ReportSummaryJobResponseResultCoverageSleep sleep;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportSummaryJobResponseResultCoverage &&
          other.medication == medication &&
          other.water == water &&
          other.sleep == sleep;

  @override
  int get hashCode => medication.hashCode + water.hashCode + sleep.hashCode;

  factory ReportSummaryJobResponseResultCoverage.fromJson(
    Map<String, dynamic> json,
  ) => _$ReportSummaryJobResponseResultCoverageFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ReportSummaryJobResponseResultCoverageToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
