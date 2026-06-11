//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

enum DataExportStatus {
  @JsonValue(r'requested')
  requested(r'requested'),
  @JsonValue(r'processing')
  processing(r'processing'),
  @JsonValue(r'completed')
  completed(r'completed'),
  @JsonValue(r'failed')
  failed(r'failed'),
  @JsonValue(r'unavailable')
  unavailable(r'unavailable'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const DataExportStatus(this.value);

  final String value;

  @override
  String toString() => value;
}
