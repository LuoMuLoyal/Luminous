//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'report_summary_response_low_risk_action.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReportSummaryResponseLowRiskAction {
  /// Returns a new [ReportSummaryResponseLowRiskAction] instance.
  ReportSummaryResponseLowRiskAction({required this.label, required this.text});

  @JsonKey(name: r'label', required: true, includeIfNull: false)
  final String label;

  @JsonKey(name: r'text', required: true, includeIfNull: false)
  final String text;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportSummaryResponseLowRiskAction &&
          other.label == label &&
          other.text == text;

  @override
  int get hashCode => label.hashCode + text.hashCode;

  factory ReportSummaryResponseLowRiskAction.fromJson(
    Map<String, dynamic> json,
  ) => _$ReportSummaryResponseLowRiskActionFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ReportSummaryResponseLowRiskActionToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
