//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

/// Persisted semantic kind used for check-in routing.
enum HealthEventKind {
  /// Persisted semantic kind used for check-in routing.
  @JsonValue(r'symptom')
  symptom(r'symptom'),

  /// Persisted semantic kind used for check-in routing.
  @JsonValue(r'other')
  other(r'other'),

  /// Persisted semantic kind used for check-in routing.
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const HealthEventKind(this.value);

  final String value;

  @override
  String toString() => value;
}
