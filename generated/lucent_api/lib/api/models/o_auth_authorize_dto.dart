// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'o_auth_authorize_dto.g.dart';

@JsonSerializable()
class OAuthAuthorizeDto {
  const OAuthAuthorizeDto({this.callbackUri});

  factory OAuthAuthorizeDto.fromJson(Map<String, Object?> json) =>
      _$OAuthAuthorizeDtoFromJson(json);

  /// 授权完成后的客户端回跳地址。桌面端支持 loopback 地址，Web 端支持可信 CORS origin 下的 /login/oauth/wechat。
  final String? callbackUri;

  Map<String, Object?> toJson() => _$OAuthAuthorizeDtoToJson(this);
}
