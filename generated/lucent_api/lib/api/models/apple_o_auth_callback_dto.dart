// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'apple_o_auth_callback_dto.g.dart';

@JsonSerializable()
class AppleOAuthCallbackDto {
  const AppleOAuthCallbackDto({
    required this.identityToken,
    this.authorizationCode,
    this.givenName,
    this.familyName,
  });

  factory AppleOAuthCallbackDto.fromJson(Map<String, Object?> json) =>
      _$AppleOAuthCallbackDtoFromJson(json);

  /// Apple 登录返回的 identityToken (JWT)
  final String identityToken;

  /// Apple 登录返回的 authorizationCode（可选）
  final String? authorizationCode;

  /// Apple 返回的 givenName（首次登录时返回）
  final String? givenName;

  /// Apple 返回的 familyName（首次登录时返回）
  final String? familyName;

  Map<String, Object?> toJson() => _$AppleOAuthCallbackDtoToJson(this);
}
