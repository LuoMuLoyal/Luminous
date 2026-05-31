//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

/// Sex assigned at birth.
enum SexAtBirth {
          /// Sex assigned at birth.
      @JsonValue(r'female')
      female(r'female'),
          /// Sex assigned at birth.
      @JsonValue(r'male')
      male(r'male'),
          /// Sex assigned at birth.
      @JsonValue(r'intersex')
      intersex(r'intersex'),
          /// Sex assigned at birth.
      @JsonValue(r'unknown')
      unknown(r'unknown'),
          /// Sex assigned at birth.
      @JsonValue(r'unknown_default_open_api')
      unknownDefaultOpenApi(r'unknown_default_open_api');

  const SexAtBirth(this.value);

  final String value;

  @override
  String toString() => value;
}
