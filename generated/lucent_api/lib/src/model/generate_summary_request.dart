//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'generate_summary_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class GenerateSummaryRequest {
  /// Returns a new [GenerateSummaryRequest] instance.
  GenerateSummaryRequest({this.range, this.startDate, this.endDate});

  /// Supported report summary aggregation range.
  @JsonKey(
    name: r'range',
    required: false,
    includeIfNull: false,
    unknownEnumValue: GenerateSummaryRequestRangeEnum.unknownDefaultOpenApi,
  )
  final GenerateSummaryRequestRangeEnum? range;

  /// Required when range is \"custom\". ISO 8601 date string (YYYY-MM-DD).
  @JsonKey(name: r'startDate', required: false, includeIfNull: false)
  final String? startDate;

  /// Required when range is \"custom\". ISO 8601 date string (YYYY-MM-DD).
  @JsonKey(name: r'endDate', required: false, includeIfNull: false)
  final String? endDate;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GenerateSummaryRequest &&
          other.range == range &&
          other.startDate == startDate &&
          other.endDate == endDate;

  @override
  int get hashCode => range.hashCode + startDate.hashCode + endDate.hashCode;

  factory GenerateSummaryRequest.fromJson(Map<String, dynamic> json) =>
      _$GenerateSummaryRequestFromJson(json);

  Map<String, dynamic> toJson() => _$GenerateSummaryRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// Supported report summary aggregation range.
enum GenerateSummaryRequestRangeEnum {
  @JsonValue(r'last_7_days')
  last7Days(r'last_7_days'),
  @JsonValue(r'last_30_days')
  last30Days(r'last_30_days'),
  @JsonValue(r'custom')
  custom(r'custom'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const GenerateSummaryRequestRangeEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
