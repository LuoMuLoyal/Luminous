//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

/// Device platform.
enum UserDevicePlatform {
  /// Device platform.
  @JsonValue(r'ios')
  ios(r'ios'),

  /// Device platform.
  @JsonValue(r'android')
  android(r'android'),

  /// Device platform.
  @JsonValue(r'web')
  web(r'web'),

  /// Device platform.
  @JsonValue(r'windows')
  windows(r'windows'),

  /// Device platform.
  @JsonValue(r'macos')
  macos(r'macos'),

  /// Device platform.
  @JsonValue(r'linux')
  linux(r'linux'),

  /// Device platform.
  @JsonValue(r'watchos')
  watchos(r'watchos'),

  /// Device platform.
  @JsonValue(r'other')
  other(r'other'),

  /// Device platform.
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const UserDevicePlatform(this.value);

  final String value;

  @override
  String toString() => value;
}
