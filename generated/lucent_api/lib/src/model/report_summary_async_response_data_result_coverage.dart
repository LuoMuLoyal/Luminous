//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/report_summary_async_response_data_result_coverage_medication.dart';
import 'package:lucent_api/src/model/report_summary_async_response_data_result_coverage_sleep.dart';
import 'package:lucent_api/src/model/report_summary_async_response_data_result_coverage_water.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'report_summary_async_response_data_result_coverage.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReportSummaryAsyncResponseDataResultCoverage {
  /// Returns a new [ReportSummaryAsyncResponseDataResultCoverage] instance.
  ReportSummaryAsyncResponseDataResultCoverage({
    required this.medication,

    required this.water,

    required this.sleep,
  });

  @JsonKey(name: r'medication', required: true, includeIfNull: false)
  final ReportSummaryAsyncResponseDataResultCoverageMedication medication;

  @JsonKey(name: r'water', required: true, includeIfNull: false)
  final ReportSummaryAsyncResponseDataResultCoverageWater water;

  @JsonKey(name: r'sleep', required: true, includeIfNull: false)
  final ReportSummaryAsyncResponseDataResultCoverageSleep sleep;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportSummaryAsyncResponseDataResultCoverage &&
          other.medication == medication &&
          other.water == water &&
          other.sleep == sleep;

  @override
  int get hashCode => medication.hashCode + water.hashCode + sleep.hashCode;

  factory ReportSummaryAsyncResponseDataResultCoverage.fromJson(
    Map<String, dynamic> json,
  ) => _$ReportSummaryAsyncResponseDataResultCoverageFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ReportSummaryAsyncResponseDataResultCoverageToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
