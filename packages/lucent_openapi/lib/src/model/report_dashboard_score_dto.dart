//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'report_dashboard_score_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReportDashboardScoreDto {
  /// Returns a new [ReportDashboardScoreDto] instance.
  ReportDashboardScoreDto({
    required this.value,

    required this.maxValue,

    required this.status,

    required this.summary,
  });

  @JsonKey(name: r'value', required: true, includeIfNull: false)
  final num value;

  @JsonKey(name: r'maxValue', required: true, includeIfNull: false)
  final num maxValue;

  @JsonKey(
    name: r'status',
    required: true,
    includeIfNull: false,
    unknownEnumValue: ReportDashboardScoreDtoStatusEnum.unknownDefaultOpenApi,
  )
  final ReportDashboardScoreDtoStatusEnum status;

  @JsonKey(name: r'summary', required: true, includeIfNull: false)
  final String summary;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportDashboardScoreDto &&
          other.value == value &&
          other.maxValue == maxValue &&
          other.status == status &&
          other.summary == summary;

  @override
  int get hashCode =>
      value.hashCode + maxValue.hashCode + status.hashCode + summary.hashCode;

  factory ReportDashboardScoreDto.fromJson(Map<String, dynamic> json) =>
      _$ReportDashboardScoreDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ReportDashboardScoreDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum ReportDashboardScoreDtoStatusEnum {
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

  const ReportDashboardScoreDtoStatusEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
