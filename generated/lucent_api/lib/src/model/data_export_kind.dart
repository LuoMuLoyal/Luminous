//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

enum DataExportKind {
  @JsonValue(r'hospital')
  hospital(r'hospital'),
  @JsonValue(r'monthly')
  monthly(r'monthly'),
  @JsonValue(r'print')
  print(r'print'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const DataExportKind(this.value);

  final String value;

  @override
  String toString() => value;
}
