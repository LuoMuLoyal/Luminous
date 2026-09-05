//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'o_auth_authorize_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class OAuthAuthorizeResponse {
  /// Returns a new [OAuthAuthorizeResponse] instance.
  OAuthAuthorizeResponse({
    required this.authorizeUrl,

    required this.state,

    required this.expiresIn,

    this.callbackUri,
  });

  /// 第三方授权地址
  @JsonKey(name: r'authorizeUrl', required: true, includeIfNull: false)
  final String authorizeUrl;

  /// 本次授权 state
  @JsonKey(name: r'state', required: true, includeIfNull: false)
  final String state;

  /// state 过期时间（秒）
  @JsonKey(name: r'expiresIn', required: true, includeIfNull: false)
  final num expiresIn;

  /// 客户端回跳地址。桌面端 loopback 或可信 Web 回调登录时返回。
  @JsonKey(name: r'callbackUri', required: false, includeIfNull: false)
  final String? callbackUri;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OAuthAuthorizeResponse &&
          other.authorizeUrl == authorizeUrl &&
          other.state == state &&
          other.expiresIn == expiresIn &&
          other.callbackUri == callbackUri;

  @override
  int get hashCode =>
      authorizeUrl.hashCode +
      state.hashCode +
      expiresIn.hashCode +
      callbackUri.hashCode;

  factory OAuthAuthorizeResponse.fromJson(Map<String, dynamic> json) =>
      _$OAuthAuthorizeResponseFromJson(json);

  Map<String, dynamic> toJson() => _$OAuthAuthorizeResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
