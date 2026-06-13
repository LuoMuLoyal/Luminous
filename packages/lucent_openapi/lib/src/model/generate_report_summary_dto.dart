//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'generate_report_summary_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class GenerateReportSummaryDto {
  /// Returns a new [GenerateReportSummaryDto] instance.
  GenerateReportSummaryDto({this.range});

  /// Supported report summary aggregation range.
  @JsonKey(
    name: r'range',
    required: false,
    includeIfNull: false,
    unknownEnumValue: GenerateReportSummaryDtoRangeEnum.unknownDefaultOpenApi,
  )
  final GenerateReportSummaryDtoRangeEnum? range;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GenerateReportSummaryDto && other.range == range;

  @override
  int get hashCode => range.hashCode;

  factory GenerateReportSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$GenerateReportSummaryDtoFromJson(json);

  Map<String, dynamic> toJson() => _$GenerateReportSummaryDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// Supported report summary aggregation range.
enum GenerateReportSummaryDtoRangeEnum {
  /// Supported report summary aggregation range.
  @JsonValue(r'last_7_days')
  last7Days(r'last_7_days'),

  /// Supported report summary aggregation range.
  @JsonValue(r'last_30_days')
  last30Days(r'last_30_days'),

  /// Supported report summary aggregation range.
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const GenerateReportSummaryDtoRangeEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
