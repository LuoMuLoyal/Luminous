//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

/// Health-event lifecycle events report the outcome semantics (improved/unchanged/worsened), all other events report success/failure.
enum ProductEventResult {
  /// Health-event lifecycle events report the outcome semantics (improved/unchanged/worsened), all other events report success/failure.
  @JsonValue(r'success')
  success(r'success'),

  /// Health-event lifecycle events report the outcome semantics (improved/unchanged/worsened), all other events report success/failure.
  @JsonValue(r'failure')
  failure(r'failure'),

  /// Health-event lifecycle events report the outcome semantics (improved/unchanged/worsened), all other events report success/failure.
  @JsonValue(r'improved')
  improved(r'improved'),

  /// Health-event lifecycle events report the outcome semantics (improved/unchanged/worsened), all other events report success/failure.
  @JsonValue(r'unchanged')
  unchanged(r'unchanged'),

  /// Health-event lifecycle events report the outcome semantics (improved/unchanged/worsened), all other events report success/failure.
  @JsonValue(r'worsened')
  worsened(r'worsened'),

  /// Health-event lifecycle events report the outcome semantics (improved/unchanged/worsened), all other events report success/failure.
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const ProductEventResult(this.value);

  final String value;

  @override
  String toString() => value;
}
