//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_wechat_web_identity_link_authorize_url_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateWechatWebIdentityLinkAuthorizeUrlRequest {
  /// Returns a new [CreateWechatWebIdentityLinkAuthorizeUrlRequest] instance.
  CreateWechatWebIdentityLinkAuthorizeUrlRequest({this.callbackUri});

  /// 授权完成后的客户端回跳地址。桌面端支持 loopback 地址，Web 端支持可信 CORS origin 下的 /login/oauth/wechat。
  @JsonKey(name: r'callbackUri', required: false, includeIfNull: false)
  final String? callbackUri;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateWechatWebIdentityLinkAuthorizeUrlRequest &&
          other.callbackUri == callbackUri;

  @override
  int get hashCode => callbackUri.hashCode;

  factory CreateWechatWebIdentityLinkAuthorizeUrlRequest.fromJson(
    Map<String, dynamic> json,
  ) => _$CreateWechatWebIdentityLinkAuthorizeUrlRequestFromJson(json);

  Map<String, dynamic> toJson() =>
      _$CreateWechatWebIdentityLinkAuthorizeUrlRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
