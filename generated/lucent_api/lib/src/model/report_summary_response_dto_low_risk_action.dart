//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'report_summary_response_dto_low_risk_action.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReportSummaryResponseDtoLowRiskAction {
  /// Returns a new [ReportSummaryResponseDtoLowRiskAction] instance.
  ReportSummaryResponseDtoLowRiskAction({
    required this.label,

    required this.text,
  });

  @JsonKey(name: r'label', required: true, includeIfNull: false)
  final String label;

  @JsonKey(name: r'text', required: true, includeIfNull: false)
  final String text;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportSummaryResponseDtoLowRiskAction &&
          other.label == label &&
          other.text == text;

  @override
  int get hashCode => label.hashCode + text.hashCode;

  factory ReportSummaryResponseDtoLowRiskAction.fromJson(
    Map<String, dynamic> json,
  ) => _$ReportSummaryResponseDtoLowRiskActionFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ReportSummaryResponseDtoLowRiskActionToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
