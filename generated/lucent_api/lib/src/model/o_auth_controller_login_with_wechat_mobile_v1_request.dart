//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'o_auth_controller_login_with_wechat_mobile_v1_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class OAuthControllerLoginWithWechatMobileV1Request {
  /// Returns a new [OAuthControllerLoginWithWechatMobileV1Request] instance.
  OAuthControllerLoginWithWechatMobileV1Request({required this.code});

  /// OAuth 授权码
  @JsonKey(name: r'code', required: true, includeIfNull: false)
  final String code;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OAuthControllerLoginWithWechatMobileV1Request &&
          other.code == code;

  @override
  int get hashCode => code.hashCode;

  factory OAuthControllerLoginWithWechatMobileV1Request.fromJson(
    Map<String, dynamic> json,
  ) => _$OAuthControllerLoginWithWechatMobileV1RequestFromJson(json);

  Map<String, dynamic> toJson() =>
      _$OAuthControllerLoginWithWechatMobileV1RequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
