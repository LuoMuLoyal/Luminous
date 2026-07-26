//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

enum HealthComponentStatus {
  @JsonValue(r'up')
  up(r'up'),
  @JsonValue(r'down')
  down(r'down'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const HealthComponentStatus(this.value);

  final String value;

  @override
  String toString() => value;
}
