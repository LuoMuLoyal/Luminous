//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'o_auth_controller_create_weibo_authorize_url_v1_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class OAuthControllerCreateWeiboAuthorizeUrlV1Request {
  /// Returns a new [OAuthControllerCreateWeiboAuthorizeUrlV1Request] instance.
  OAuthControllerCreateWeiboAuthorizeUrlV1Request({this.callbackUri});

  /// 微博授权完成后的客户端回跳地址
  @JsonKey(name: r'callbackUri', required: false, includeIfNull: false)
  final String? callbackUri;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OAuthControllerCreateWeiboAuthorizeUrlV1Request &&
          other.callbackUri == callbackUri;

  @override
  int get hashCode => callbackUri.hashCode;

  factory OAuthControllerCreateWeiboAuthorizeUrlV1Request.fromJson(
    Map<String, dynamic> json,
  ) => _$OAuthControllerCreateWeiboAuthorizeUrlV1RequestFromJson(json);

  Map<String, dynamic> toJson() =>
      _$OAuthControllerCreateWeiboAuthorizeUrlV1RequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
