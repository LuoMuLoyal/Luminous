//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'account_controller_link_wechat_mobile_identity_v1_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AccountControllerLinkWechatMobileIdentityV1Request {
  /// Returns a new [AccountControllerLinkWechatMobileIdentityV1Request] instance.
  AccountControllerLinkWechatMobileIdentityV1Request({required this.code});

  /// OAuth 授权码
  @JsonKey(name: r'code', required: true, includeIfNull: false)
  final String code;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountControllerLinkWechatMobileIdentityV1Request &&
          other.code == code;

  @override
  int get hashCode => code.hashCode;

  factory AccountControllerLinkWechatMobileIdentityV1Request.fromJson(
    Map<String, dynamic> json,
  ) => _$AccountControllerLinkWechatMobileIdentityV1RequestFromJson(json);

  Map<String, dynamic> toJson() =>
      _$AccountControllerLinkWechatMobileIdentityV1RequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
