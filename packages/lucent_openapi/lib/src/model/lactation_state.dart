//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

/// Lactation state for personalized medical guidance.
enum LactationState {
  /// Lactation state for personalized medical guidance.
  @JsonValue(r'not_applicable')
  notApplicable(r'not_applicable'),

  /// Lactation state for personalized medical guidance.
  @JsonValue(r'unknown')
  unknown(r'unknown'),

  /// Lactation state for personalized medical guidance.
  @JsonValue(r'no')
  no(r'no'),

  /// Lactation state for personalized medical guidance.
  @JsonValue(r'yes')
  yes(r'yes'),

  /// Lactation state for personalized medical guidance.
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const LactationState(this.value);

  final String value;

  @override
  String toString() => value;
}
