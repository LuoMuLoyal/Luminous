//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'reports_controller_generate_summary_v1_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReportsControllerGenerateSummaryV1Request {
  /// Returns a new [ReportsControllerGenerateSummaryV1Request] instance.
  ReportsControllerGenerateSummaryV1Request({
    this.range,

    this.startDate,

    this.endDate,
  });

  /// Supported report summary aggregation range.
  @JsonKey(
    name: r'range',
    required: false,
    includeIfNull: false,
    unknownEnumValue: ReportsControllerGenerateSummaryV1RequestRangeEnum
        .unknownDefaultOpenApi,
  )
  final ReportsControllerGenerateSummaryV1RequestRangeEnum? range;

  /// Required when range is \"custom\". ISO 8601 date string (YYYY-MM-DD).
  @JsonKey(name: r'startDate', required: false, includeIfNull: false)
  final String? startDate;

  /// Required when range is \"custom\". ISO 8601 date string (YYYY-MM-DD).
  @JsonKey(name: r'endDate', required: false, includeIfNull: false)
  final String? endDate;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportsControllerGenerateSummaryV1Request &&
          other.range == range &&
          other.startDate == startDate &&
          other.endDate == endDate;

  @override
  int get hashCode => range.hashCode + startDate.hashCode + endDate.hashCode;

  factory ReportsControllerGenerateSummaryV1Request.fromJson(
    Map<String, dynamic> json,
  ) => _$ReportsControllerGenerateSummaryV1RequestFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ReportsControllerGenerateSummaryV1RequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// Supported report summary aggregation range.
enum ReportsControllerGenerateSummaryV1RequestRangeEnum {
  @JsonValue(r'last_7_days')
  last7Days(r'last_7_days'),
  @JsonValue(r'last_30_days')
  last30Days(r'last_30_days'),
  @JsonValue(r'custom')
  custom(r'custom'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const ReportsControllerGenerateSummaryV1RequestRangeEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
