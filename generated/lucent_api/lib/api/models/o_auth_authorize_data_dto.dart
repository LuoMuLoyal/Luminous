// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'o_auth_authorize_data_dto.g.dart';

@JsonSerializable()
class OAuthAuthorizeDataDto {
  const OAuthAuthorizeDataDto({
    required this.authorizeUrl,
    required this.state,
    required this.expiresIn,
    this.callbackUri,
  });

  factory OAuthAuthorizeDataDto.fromJson(Map<String, Object?> json) =>
      _$OAuthAuthorizeDataDtoFromJson(json);

  /// 第三方授权地址
  final String authorizeUrl;

  /// 本次授权 state
  final String state;

  /// state 过期时间（秒）
  final num expiresIn;

  /// 客户端回跳地址。桌面端 loopback 或可信 Web 回调登录时返回。
  final String? callbackUri;

  Map<String, Object?> toJson() => _$OAuthAuthorizeDataDtoToJson(this);
}
