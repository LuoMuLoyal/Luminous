// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'o_auth_code_callback_dto.g.dart';

@JsonSerializable()
class OAuthCodeCallbackDto {
  const OAuthCodeCallbackDto({required this.code});

  factory OAuthCodeCallbackDto.fromJson(Map<String, Object?> json) =>
      _$OAuthCodeCallbackDtoFromJson(json);

  /// OAuth 授权码
  final String code;

  Map<String, Object?> toJson() => _$OAuthCodeCallbackDtoToJson(this);
}
