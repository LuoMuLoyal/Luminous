//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'report_summary_async_response_data_result_coverage_medication.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReportSummaryAsyncResponseDataResultCoverageMedication {
  /// Returns a new [ReportSummaryAsyncResponseDataResultCoverageMedication] instance.
  ReportSummaryAsyncResponseDataResultCoverageMedication({
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
      other is ReportSummaryAsyncResponseDataResultCoverageMedication &&
          other.trackedDays == trackedDays &&
          other.totalDays == totalDays;

  @override
  int get hashCode => trackedDays.hashCode + totalDays.hashCode;

  factory ReportSummaryAsyncResponseDataResultCoverageMedication.fromJson(
    Map<String, dynamic> json,
  ) => _$ReportSummaryAsyncResponseDataResultCoverageMedicationFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ReportSummaryAsyncResponseDataResultCoverageMedicationToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
