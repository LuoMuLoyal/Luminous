//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

/// Client platform.
enum UserDevicePlatform {
  /// Client platform.
  @JsonValue(r'ios')
  ios(r'ios'),

  /// Client platform.
  @JsonValue(r'android')
  android(r'android'),

  /// Client platform.
  @JsonValue(r'web')
  web(r'web'),

  /// Client platform.
  @JsonValue(r'windows')
  windows(r'windows'),

  /// Client platform.
  @JsonValue(r'macos')
  macos(r'macos'),

  /// Client platform.
  @JsonValue(r'linux')
  linux(r'linux'),

  /// Client platform.
  @JsonValue(r'watchos')
  watchos(r'watchos'),

  /// Client platform.
  @JsonValue(r'other')
  other(r'other'),

  /// Client platform.
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const UserDevicePlatform(this.value);

  final String value;

  @override
  String toString() => value;
}
