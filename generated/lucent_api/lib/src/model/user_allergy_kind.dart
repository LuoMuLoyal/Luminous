//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

/// Allergy kind.
enum UserAllergyKind {
  @JsonValue(r'drug')
  drug(r'drug'),
  @JsonValue(r'food')
  food(r'food'),
  @JsonValue(r'environment')
  environment(r'environment'),
  @JsonValue(r'other')
  other(r'other'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const UserAllergyKind(this.value);

  final String value;

  @override
  String toString() => value;
}
