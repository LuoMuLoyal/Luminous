// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum HealthProbeType {
  @JsonValue('live')
  live('live'),
  @JsonValue('ready')
  ready('ready'),
  @JsonValue('deep')
  deep('deep'),

  /// Default value for all unparsed values, allows backward compatibility when adding new values on the backend.
  $unknown(null);

  const HealthProbeType(this.json);

  factory HealthProbeType.fromJson(String json) =>
      values.firstWhere((e) => e.json == json, orElse: () => $unknown);

  final String? json;

  String toJson() => json ?? 'null';

  @override
  String toString() => json ?? super.toString();

  /// Returns all defined enum values excluding the $unknown value.
  static List<HealthProbeType> get $valuesDefined =>
      values.where((value) => value != $unknown).toList();
}
