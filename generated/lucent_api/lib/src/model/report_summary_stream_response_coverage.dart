//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/report_summary_stream_response_coverage_sleep.dart';
import 'package:lucent_api/src/model/report_summary_stream_response_coverage_water.dart';
import 'package:lucent_api/src/model/report_summary_stream_response_coverage_medication.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'report_summary_stream_response_coverage.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReportSummaryStreamResponseCoverage {
  /// Returns a new [ReportSummaryStreamResponseCoverage] instance.
  ReportSummaryStreamResponseCoverage({
    required this.medication,

    required this.water,

    required this.sleep,
  });

  @JsonKey(name: r'medication', required: true, includeIfNull: false)
  final ReportSummaryStreamResponseCoverageMedication medication;

  @JsonKey(name: r'water', required: true, includeIfNull: false)
  final ReportSummaryStreamResponseCoverageWater water;

  @JsonKey(name: r'sleep', required: true, includeIfNull: false)
  final ReportSummaryStreamResponseCoverageSleep sleep;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportSummaryStreamResponseCoverage &&
          other.medication == medication &&
          other.water == water &&
          other.sleep == sleep;

  @override
  int get hashCode => medication.hashCode + water.hashCode + sleep.hashCode;

  factory ReportSummaryStreamResponseCoverage.fromJson(
    Map<String, dynamic> json,
  ) => _$ReportSummaryStreamResponseCoverageFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ReportSummaryStreamResponseCoverageToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
