//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

enum DataExportRange {
  @JsonValue(r'last_7_days')
  last7Days(r'last_7_days'),
  @JsonValue(r'last_30_days')
  last30Days(r'last_30_days'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const DataExportRange(this.value);

  final String value;

  @override
  String toString() => value;
}
