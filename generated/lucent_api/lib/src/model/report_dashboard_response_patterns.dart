//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'report_dashboard_response_patterns.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReportDashboardResponsePatterns {
  /// Returns a new [ReportDashboardResponsePatterns] instance.
  ReportDashboardResponsePatterns({
    required this.kind,

    required this.title,

    required this.status,

    required this.body,

    required this.sparkline,
  });

  @JsonKey(
    name: r'kind',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        ReportDashboardResponsePatternsKindEnum.unknownDefaultOpenApi,
  )
  final ReportDashboardResponsePatternsKindEnum kind;

  @JsonKey(name: r'title', required: true, includeIfNull: false)
  final String title;

  @JsonKey(
    name: r'status',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        ReportDashboardResponsePatternsStatusEnum.unknownDefaultOpenApi,
  )
  final ReportDashboardResponsePatternsStatusEnum status;

  @JsonKey(name: r'body', required: true, includeIfNull: false)
  final String body;

  @JsonKey(name: r'sparkline', required: true, includeIfNull: false)
  final List<num> sparkline;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportDashboardResponsePatterns &&
          other.kind == kind &&
          other.title == title &&
          other.status == status &&
          other.body == body &&
          other.sparkline == sparkline;

  @override
  int get hashCode =>
      kind.hashCode +
      title.hashCode +
      status.hashCode +
      body.hashCode +
      sparkline.hashCode;

  factory ReportDashboardResponsePatterns.fromJson(Map<String, dynamic> json) =>
      _$ReportDashboardResponsePatternsFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ReportDashboardResponsePatternsToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum ReportDashboardResponsePatternsKindEnum {
  @JsonValue(r'medication')
  medication(r'medication'),
  @JsonValue(r'hydration')
  hydration(r'hydration'),
  @JsonValue(r'sleep')
  sleep(r'sleep'),
  @JsonValue(r'general')
  general(r'general'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const ReportDashboardResponsePatternsKindEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum ReportDashboardResponsePatternsStatusEnum {
  @JsonValue(r'good')
  good(r'good'),
  @JsonValue(r'stable')
  stable(r'stable'),
  @JsonValue(r'needs_attention')
  needsAttention(r'needs_attention'),
  @JsonValue(r'insufficient_data')
  insufficientData(r'insufficient_data'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const ReportDashboardResponsePatternsStatusEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
