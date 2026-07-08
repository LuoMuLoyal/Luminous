// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

/// 验证码场景
@JsonEnum()
enum SendVerificationCodeDtoSceneScene {
  @JsonValue('register')
  register('register'),
  @JsonValue('login')
  login('login'),
  @JsonValue('reset-password')
  resetPassword('reset-password'),
  @JsonValue('change-email')
  changeEmail('change-email'),
  @JsonValue('set-password')
  setPassword('set-password'),
  @JsonValue('delete-account')
  deleteAccount('delete-account'),

  /// Default value for all unparsed values, allows backward compatibility when adding new values on the backend.
  $unknown(null);

  const SendVerificationCodeDtoSceneScene(this.json);

  factory SendVerificationCodeDtoSceneScene.fromJson(String json) =>
      values.firstWhere((e) => e.json == json, orElse: () => $unknown);

  final String? json;

  String toJson() => json ?? 'null';

  @override
  String toString() => json ?? super.toString();

  /// Returns all defined enum values excluding the $unknown value.
  static List<SendVerificationCodeDtoSceneScene> get $valuesDefined =>
      values.where((value) => value != $unknown).toList();
}
