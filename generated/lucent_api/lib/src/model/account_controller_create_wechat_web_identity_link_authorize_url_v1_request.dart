//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'account_controller_create_wechat_web_identity_link_authorize_url_v1_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AccountControllerCreateWechatWebIdentityLinkAuthorizeUrlV1Request {
  /// Returns a new [AccountControllerCreateWechatWebIdentityLinkAuthorizeUrlV1Request] instance.
  AccountControllerCreateWechatWebIdentityLinkAuthorizeUrlV1Request({
    this.callbackUri,
  });

  /// 授权完成后的客户端回跳地址。桌面端支持 loopback 地址，Web 端支持可信 CORS origin 下的 /login/oauth/wechat。
  @JsonKey(name: r'callbackUri', required: false, includeIfNull: false)
  final String? callbackUri;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountControllerCreateWechatWebIdentityLinkAuthorizeUrlV1Request &&
          other.callbackUri == callbackUri;

  @override
  int get hashCode => callbackUri.hashCode;

  factory AccountControllerCreateWechatWebIdentityLinkAuthorizeUrlV1Request.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$AccountControllerCreateWechatWebIdentityLinkAuthorizeUrlV1RequestFromJson(
        json,
      );

  Map<String, dynamic> toJson() =>
      _$AccountControllerCreateWechatWebIdentityLinkAuthorizeUrlV1RequestToJson(
        this,
      );

  @override
  String toString() {
    return toJson().toString();
  }
}
