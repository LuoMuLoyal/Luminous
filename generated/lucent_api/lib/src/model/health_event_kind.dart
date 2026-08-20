//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

enum HealthEventKind {
  @JsonValue(r'symptom')
  symptom(r'symptom'),
  @JsonValue(r'other')
  other(r'other'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const HealthEventKind(this.value);

  final String value;

  @override
  String toString() => value;
}
