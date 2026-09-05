//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'login_with_wechat_mobile_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class LoginWithWechatMobileRequest {
  /// Returns a new [LoginWithWechatMobileRequest] instance.
  LoginWithWechatMobileRequest({required this.code});

  /// OAuth 授权码
  @JsonKey(name: r'code', required: true, includeIfNull: false)
  final String code;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoginWithWechatMobileRequest && other.code == code;

  @override
  int get hashCode => code.hashCode;

  factory LoginWithWechatMobileRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginWithWechatMobileRequestFromJson(json);

  Map<String, dynamic> toJson() => _$LoginWithWechatMobileRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
