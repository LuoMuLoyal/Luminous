//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

/// Condition status.
enum UserConditionStatus {
  @JsonValue(r'active')
  active(r'active'),
  @JsonValue(r'resolved')
  resolved(r'resolved'),
  @JsonValue(r'suspected')
  suspected(r'suspected'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const UserConditionStatus(this.value);

  final String value;

  @override
  String toString() => value;
}
