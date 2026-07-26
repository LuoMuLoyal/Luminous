//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

enum PollenLevel {
  @JsonValue(r'low')
  low(r'low'),
  @JsonValue(r'medium')
  medium(r'medium'),
  @JsonValue(r'high')
  high(r'high'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const PollenLevel(this.value);

  final String value;

  @override
  String toString() => value;
}
