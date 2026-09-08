//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'report_summary_stream_response_low_risk_action.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReportSummaryStreamResponseLowRiskAction {
  /// Returns a new [ReportSummaryStreamResponseLowRiskAction] instance.
  ReportSummaryStreamResponseLowRiskAction({
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
      other is ReportSummaryStreamResponseLowRiskAction &&
          other.label == label &&
          other.text == text;

  @override
  int get hashCode => label.hashCode + text.hashCode;

  factory ReportSummaryStreamResponseLowRiskAction.fromJson(
    Map<String, dynamic> json,
  ) => _$ReportSummaryStreamResponseLowRiskActionFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ReportSummaryStreamResponseLowRiskActionToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
