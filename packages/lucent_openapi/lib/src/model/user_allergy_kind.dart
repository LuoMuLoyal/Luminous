//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

/// Allergy kind.
enum UserAllergyKind {
  /// Allergy kind.
  @JsonValue(r'drug')
  drug(r'drug'),

  /// Allergy kind.
  @JsonValue(r'food')
  food(r'food'),

  /// Allergy kind.
  @JsonValue(r'environment')
  environment(r'environment'),

  /// Allergy kind.
  @JsonValue(r'other')
  other(r'other'),

  /// Allergy kind.
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const UserAllergyKind(this.value);

  final String value;

  @override
  String toString() => value;
}
