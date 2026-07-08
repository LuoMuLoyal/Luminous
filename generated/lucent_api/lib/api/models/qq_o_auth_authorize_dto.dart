// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'qq_o_auth_authorize_dto.g.dart';

@JsonSerializable()
class QqOAuthAuthorizeDto {
  const QqOAuthAuthorizeDto({this.callbackUri});

  factory QqOAuthAuthorizeDto.fromJson(Map<String, Object?> json) =>
      _$QqOAuthAuthorizeDtoFromJson(json);

  /// QQ 授权完成后的客户端回跳地址
  final String? callbackUri;

  Map<String, Object?> toJson() => _$QqOAuthAuthorizeDtoToJson(this);
}
