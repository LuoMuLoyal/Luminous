//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'o_auth_authorize_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class OAuthAuthorizeDto {
  /// Returns a new [OAuthAuthorizeDto] instance.
  OAuthAuthorizeDto({this.callbackUri});

  /// 授权完成后的客户端回跳地址。桌面端支持 loopback 地址，Web 端支持可信 CORS origin 下的 /login/oauth/wechat。
  @JsonKey(name: r'callbackUri', required: false, includeIfNull: false)
  final String? callbackUri;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OAuthAuthorizeDto && other.callbackUri == callbackUri;

  @override
  int get hashCode => callbackUri.hashCode;

  factory OAuthAuthorizeDto.fromJson(Map<String, dynamic> json) =>
      _$OAuthAuthorizeDtoFromJson(json);

  Map<String, dynamic> toJson() => _$OAuthAuthorizeDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
