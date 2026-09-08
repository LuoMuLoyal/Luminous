//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'report_summary_async_response_data_result_observed_pattern.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReportSummaryAsyncResponseDataResultObservedPattern {
  /// Returns a new [ReportSummaryAsyncResponseDataResultObservedPattern] instance.
  ReportSummaryAsyncResponseDataResultObservedPattern({
    required this.kind,

    required this.text,

    required this.source_,
  });

  @JsonKey(
    name: r'kind',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        ReportSummaryAsyncResponseDataResultObservedPatternKindEnum
            .unknownDefaultOpenApi,
  )
  final ReportSummaryAsyncResponseDataResultObservedPatternKindEnum kind;

  @JsonKey(name: r'text', required: true, includeIfNull: false)
  final String text;

  @JsonKey(name: r'source', required: true, includeIfNull: false)
  final String source_;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportSummaryAsyncResponseDataResultObservedPattern &&
          other.kind == kind &&
          other.text == text &&
          other.source_ == source_;

  @override
  int get hashCode => kind.hashCode + text.hashCode + source_.hashCode;

  factory ReportSummaryAsyncResponseDataResultObservedPattern.fromJson(
    Map<String, dynamic> json,
  ) => _$ReportSummaryAsyncResponseDataResultObservedPatternFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ReportSummaryAsyncResponseDataResultObservedPatternToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum ReportSummaryAsyncResponseDataResultObservedPatternKindEnum {
  @JsonValue(r'medication')
  medication(r'medication'),
  @JsonValue(r'hydration')
  hydration(r'hydration'),
  @JsonValue(r'sleep')
  sleep(r'sleep'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const ReportSummaryAsyncResponseDataResultObservedPatternKindEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
