//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'generate_report_weekly_summary_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class GenerateReportWeeklySummaryDto {
  /// Returns a new [GenerateReportWeeklySummaryDto] instance.
  GenerateReportWeeklySummaryDto({this.range});

  /// Supported weekly summary aggregation range.
  @JsonKey(
    name: r'range',
    required: false,
    includeIfNull: false,
    unknownEnumValue:
        GenerateReportWeeklySummaryDtoRangeEnum.unknownDefaultOpenApi,
  )
  final GenerateReportWeeklySummaryDtoRangeEnum? range;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GenerateReportWeeklySummaryDto && other.range == range;

  @override
  int get hashCode => range.hashCode;

  factory GenerateReportWeeklySummaryDto.fromJson(Map<String, dynamic> json) =>
      _$GenerateReportWeeklySummaryDtoFromJson(json);

  Map<String, dynamic> toJson() => _$GenerateReportWeeklySummaryDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// Supported weekly summary aggregation range.
enum GenerateReportWeeklySummaryDtoRangeEnum {
  /// Supported weekly summary aggregation range.
  @JsonValue(r'last_7_days')
  last7Days(r'last_7_days'),

  /// Supported weekly summary aggregation range.
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const GenerateReportWeeklySummaryDtoRangeEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
