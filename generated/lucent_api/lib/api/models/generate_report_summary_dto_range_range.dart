// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

/// Supported report summary aggregation range.
@JsonEnum()
enum GenerateReportSummaryDtoRangeRange {
  @JsonValue('last_7_days')
  last7Days('last_7_days'),
  @JsonValue('last_30_days')
  last30Days('last_30_days'),
  @JsonValue('custom')
  custom('custom'),

  /// Default value for all unparsed values, allows backward compatibility when adding new values on the backend.
  $unknown(null);

  const GenerateReportSummaryDtoRangeRange(this.json);

  factory GenerateReportSummaryDtoRangeRange.fromJson(String json) =>
      values.firstWhere((e) => e.json == json, orElse: () => $unknown);

  final String? json;

  String toJson() => json ?? 'null';

  @override
  String toString() => json ?? super.toString();

  /// Returns all defined enum values excluding the $unknown value.
  static List<GenerateReportSummaryDtoRangeRange> get $valuesDefined =>
      values.where((value) => value != $unknown).toList();
}
