//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

/// Severity level.
enum UserAllergySeverity {
  @JsonValue(r'mild')
  mild(r'mild'),
  @JsonValue(r'moderate')
  moderate(r'moderate'),
  @JsonValue(r'severe')
  severe(r'severe'),
  @JsonValue(r'unknown')
  unknown(r'unknown'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const UserAllergySeverity(this.value);

  final String value;

  @override
  String toString() => value;
}
