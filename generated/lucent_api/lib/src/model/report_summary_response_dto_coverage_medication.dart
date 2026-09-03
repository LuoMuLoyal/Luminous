//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'report_summary_response_dto_coverage_medication.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReportSummaryResponseDtoCoverageMedication {
  /// Returns a new [ReportSummaryResponseDtoCoverageMedication] instance.
  ReportSummaryResponseDtoCoverageMedication({
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
      other is ReportSummaryResponseDtoCoverageMedication &&
          other.trackedDays == trackedDays &&
          other.totalDays == totalDays;

  @override
  int get hashCode => trackedDays.hashCode + totalDays.hashCode;

  factory ReportSummaryResponseDtoCoverageMedication.fromJson(
    Map<String, dynamic> json,
  ) => _$ReportSummaryResponseDtoCoverageMedicationFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ReportSummaryResponseDtoCoverageMedicationToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
