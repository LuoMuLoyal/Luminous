//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

enum HealthEventOutcome {
  @JsonValue(r'improved')
  improved(r'improved'),
  @JsonValue(r'unchanged')
  unchanged(r'unchanged'),
  @JsonValue(r'worsened')
  worsened(r'worsened'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const HealthEventOutcome(this.value);

  final String value;

  @override
  String toString() => value;
}
