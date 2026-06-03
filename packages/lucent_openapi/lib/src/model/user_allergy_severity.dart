//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

/// Severity level.
enum UserAllergySeverity {
  /// Severity level.
  @JsonValue(r'mild')
  mild(r'mild'),

  /// Severity level.
  @JsonValue(r'moderate')
  moderate(r'moderate'),

  /// Severity level.
  @JsonValue(r'severe')
  severe(r'severe'),

  /// Severity level.
  @JsonValue(r'unknown')
  unknown(r'unknown'),

  /// Severity level.
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const UserAllergySeverity(this.value);

  final String value;

  @override
  String toString() => value;
}
