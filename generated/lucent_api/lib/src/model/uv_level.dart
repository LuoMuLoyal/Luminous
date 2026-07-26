//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

enum UvLevel {
  @JsonValue(r'low')
  low(r'low'),
  @JsonValue(r'moderate')
  moderate(r'moderate'),
  @JsonValue(r'high')
  high(r'high'),
  @JsonValue(r'very_high')
  veryHigh(r'very_high'),
  @JsonValue(r'extreme')
  extreme(r'extreme'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const UvLevel(this.value);

  final String value;

  @override
  String toString() => value;
}
