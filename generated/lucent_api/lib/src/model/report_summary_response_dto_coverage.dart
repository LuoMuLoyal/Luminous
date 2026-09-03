//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/report_summary_response_dto_coverage_medication.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'report_summary_response_dto_coverage.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReportSummaryResponseDtoCoverage {
  /// Returns a new [ReportSummaryResponseDtoCoverage] instance.
  ReportSummaryResponseDtoCoverage({
    required this.medication,

    required this.water,

    required this.sleep,
  });

  @JsonKey(name: r'medication', required: true, includeIfNull: false)
  final ReportSummaryResponseDtoCoverageMedication medication;

  @JsonKey(name: r'water', required: true, includeIfNull: false)
  final ReportSummaryResponseDtoCoverageMedication water;

  @JsonKey(name: r'sleep', required: true, includeIfNull: false)
  final ReportSummaryResponseDtoCoverageMedication sleep;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportSummaryResponseDtoCoverage &&
          other.medication == medication &&
          other.water == water &&
          other.sleep == sleep;

  @override
  int get hashCode => medication.hashCode + water.hashCode + sleep.hashCode;

  factory ReportSummaryResponseDtoCoverage.fromJson(
    Map<String, dynamic> json,
  ) => _$ReportSummaryResponseDtoCoverageFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ReportSummaryResponseDtoCoverageToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
