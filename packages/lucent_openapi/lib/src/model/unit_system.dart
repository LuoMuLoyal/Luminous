//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

/// Preferred unit system.
enum UnitSystem {
          /// Preferred unit system.
      @JsonValue(r'metric')
      metric(r'metric'),
          /// Preferred unit system.
      @JsonValue(r'imperial')
      imperial(r'imperial'),
          /// Preferred unit system.
      @JsonValue(r'unknown_default_open_api')
      unknownDefaultOpenApi(r'unknown_default_open_api');

  const UnitSystem(this.value);

  final String value;

  @override
  String toString() => value;
}
