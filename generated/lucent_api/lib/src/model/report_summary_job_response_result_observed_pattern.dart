//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'report_summary_job_response_result_observed_pattern.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReportSummaryJobResponseResultObservedPattern {
  /// Returns a new [ReportSummaryJobResponseResultObservedPattern] instance.
  ReportSummaryJobResponseResultObservedPattern({
    required this.kind,

    required this.text,

    required this.source_,
  });

  @JsonKey(
    name: r'kind',
    required: true,
    includeIfNull: false,
    unknownEnumValue: ReportSummaryJobResponseResultObservedPatternKindEnum
        .unknownDefaultOpenApi,
  )
  final ReportSummaryJobResponseResultObservedPatternKindEnum kind;

  @JsonKey(name: r'text', required: true, includeIfNull: false)
  final String text;

  @JsonKey(name: r'source', required: true, includeIfNull: false)
  final String source_;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportSummaryJobResponseResultObservedPattern &&
          other.kind == kind &&
          other.text == text &&
          other.source_ == source_;

  @override
  int get hashCode => kind.hashCode + text.hashCode + source_.hashCode;

  factory ReportSummaryJobResponseResultObservedPattern.fromJson(
    Map<String, dynamic> json,
  ) => _$ReportSummaryJobResponseResultObservedPatternFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ReportSummaryJobResponseResultObservedPatternToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum ReportSummaryJobResponseResultObservedPatternKindEnum {
  @JsonValue(r'medication')
  medication(r'medication'),
  @JsonValue(r'hydration')
  hydration(r'hydration'),
  @JsonValue(r'sleep')
  sleep(r'sleep'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const ReportSummaryJobResponseResultObservedPatternKindEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
