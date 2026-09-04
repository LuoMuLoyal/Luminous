//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'account_controller_link_wechat_web_identity_v1_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AccountControllerLinkWechatWebIdentityV1Request {
  /// Returns a new [AccountControllerLinkWechatWebIdentityV1Request] instance.
  AccountControllerLinkWechatWebIdentityV1Request({
    required this.code,

    required this.state,
  });

  /// OAuth 授权码
  @JsonKey(name: r'code', required: true, includeIfNull: false)
  final String code;

  /// 授权时生成的 state
  @JsonKey(name: r'state', required: true, includeIfNull: false)
  final String state;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountControllerLinkWechatWebIdentityV1Request &&
          other.code == code &&
          other.state == state;

  @override
  int get hashCode => code.hashCode + state.hashCode;

  factory AccountControllerLinkWechatWebIdentityV1Request.fromJson(
    Map<String, dynamic> json,
  ) => _$AccountControllerLinkWechatWebIdentityV1RequestFromJson(json);

  Map<String, dynamic> toJson() =>
      _$AccountControllerLinkWechatWebIdentityV1RequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
