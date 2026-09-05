//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'generate_summary_stream_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class GenerateSummaryStreamRequest {
  /// Returns a new [GenerateSummaryStreamRequest] instance.
  GenerateSummaryStreamRequest({this.range, this.startDate, this.endDate});

  /// Supported report summary aggregation range.
  @JsonKey(
    name: r'range',
    required: false,
    includeIfNull: false,
    unknownEnumValue:
        GenerateSummaryStreamRequestRangeEnum.unknownDefaultOpenApi,
  )
  final GenerateSummaryStreamRequestRangeEnum? range;

  /// Required when range is \"custom\". ISO 8601 date string (YYYY-MM-DD).
  @JsonKey(name: r'startDate', required: false, includeIfNull: false)
  final String? startDate;

  /// Required when range is \"custom\". ISO 8601 date string (YYYY-MM-DD).
  @JsonKey(name: r'endDate', required: false, includeIfNull: false)
  final String? endDate;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GenerateSummaryStreamRequest &&
          other.range == range &&
          other.startDate == startDate &&
          other.endDate == endDate;

  @override
  int get hashCode => range.hashCode + startDate.hashCode + endDate.hashCode;

  factory GenerateSummaryStreamRequest.fromJson(Map<String, dynamic> json) =>
      _$GenerateSummaryStreamRequestFromJson(json);

  Map<String, dynamic> toJson() => _$GenerateSummaryStreamRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// Supported report summary aggregation range.
enum GenerateSummaryStreamRequestRangeEnum {
  @JsonValue(r'last_7_days')
  last7Days(r'last_7_days'),
  @JsonValue(r'last_30_days')
  last30Days(r'last_30_days'),
  @JsonValue(r'custom')
  custom(r'custom'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const GenerateSummaryStreamRequestRangeEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
