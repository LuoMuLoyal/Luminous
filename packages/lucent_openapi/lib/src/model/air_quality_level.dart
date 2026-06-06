//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

enum AirQualityLevel {
  @JsonValue(r'good')
  good(r'good'),
  @JsonValue(r'moderate')
  moderate(r'moderate'),
  @JsonValue(r'unhealthy_sensitive')
  unhealthySensitive(r'unhealthy_sensitive'),
  @JsonValue(r'unhealthy')
  unhealthy(r'unhealthy'),
  @JsonValue(r'very_unhealthy')
  veryUnhealthy(r'very_unhealthy'),
  @JsonValue(r'hazardous')
  hazardous(r'hazardous'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const AirQualityLevel(this.value);

  final String value;

  @override
  String toString() => value;
}
