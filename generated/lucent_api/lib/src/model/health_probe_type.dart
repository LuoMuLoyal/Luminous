//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

enum HealthProbeType {
  @JsonValue(r'live')
  live(r'live'),
  @JsonValue(r'ready')
  ready(r'ready'),
  @JsonValue(r'deep')
  deep(r'deep'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const HealthProbeType(this.value);

  final String value;

  @override
  String toString() => value;
}
