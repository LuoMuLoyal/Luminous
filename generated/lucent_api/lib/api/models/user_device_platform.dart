// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

/// Device platform.
@JsonEnum()
enum UserDevicePlatform {
  @JsonValue('ios')
  ios('ios'),
  @JsonValue('android')
  android('android'),
  @JsonValue('web')
  web('web'),
  @JsonValue('windows')
  windows('windows'),
  @JsonValue('macos')
  macos('macos'),
  @JsonValue('linux')
  linux('linux'),
  @JsonValue('watchos')
  watchos('watchos'),
  @JsonValue('other')
  other('other'),

  /// Default value for all unparsed values, allows backward compatibility when adding new values on the backend.
  $unknown(null);

  const UserDevicePlatform(this.json);

  factory UserDevicePlatform.fromJson(String json) =>
      values.firstWhere((e) => e.json == json, orElse: () => $unknown);

  final String? json;

  String toJson() => json ?? 'null';

  @override
  String toString() => json ?? super.toString();

  /// Returns all defined enum values excluding the $unknown value.
  static List<UserDevicePlatform> get $valuesDefined =>
      values.where((value) => value != $unknown).toList();
}
