//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

enum EnvironmentDataSource {
  @JsonValue(r'static')
  static_(r'static'),
  @JsonValue(r'live')
  live(r'live'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const EnvironmentDataSource(this.value);

  final String value;

  @override
  String toString() => value;
}
