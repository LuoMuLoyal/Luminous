//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

/// Condition status.
enum UserConditionStatus {
          /// Condition status.
      @JsonValue(r'active')
      active(r'active'),
          /// Condition status.
      @JsonValue(r'resolved')
      resolved(r'resolved'),
          /// Condition status.
      @JsonValue(r'suspected')
      suspected(r'suspected'),
          /// Condition status.
      @JsonValue(r'unknown_default_open_api')
      unknownDefaultOpenApi(r'unknown_default_open_api');

  const UserConditionStatus(this.value);

  final String value;

  @override
  String toString() => value;
}
