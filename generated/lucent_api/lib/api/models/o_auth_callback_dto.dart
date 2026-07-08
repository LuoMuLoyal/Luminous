// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'o_auth_callback_dto.g.dart';

@JsonSerializable()
class OAuthCallbackDto {
  const OAuthCallbackDto({required this.code, required this.state});

  factory OAuthCallbackDto.fromJson(Map<String, Object?> json) =>
      _$OAuthCallbackDtoFromJson(json);

  /// OAuth 授权码
  final String code;

  /// 授权时生成的 state
  final String state;

  Map<String, Object?> toJson() => _$OAuthCallbackDtoToJson(this);
}
