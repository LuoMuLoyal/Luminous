//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'register_with_cookie_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RegisterWithCookieRequest {
  /// Returns a new [RegisterWithCookieRequest] instance.
  RegisterWithCookieRequest({
    required this.email,

    required this.password,

    required this.code,

    this.captchaToken,

    this.nickname,
  });

  /// 邮箱地址
  @JsonKey(name: r'email', required: true, includeIfNull: false)
  final String email;

  /// 密码（至少8位，需通过强度校验）
  @JsonKey(name: r'password', required: true, includeIfNull: false)
  final String password;

  /// 邮箱验证码
  @JsonKey(name: r'code', required: true, includeIfNull: false)
  final String code;

  /// 人机验证令牌
  @JsonKey(name: r'captchaToken', required: false, includeIfNull: false)
  final String? captchaToken;

  /// 昵称
  @JsonKey(name: r'nickname', required: false, includeIfNull: false)
  final String? nickname;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RegisterWithCookieRequest &&
          other.email == email &&
          other.password == password &&
          other.code == code &&
          other.captchaToken == captchaToken &&
          other.nickname == nickname;

  @override
  int get hashCode =>
      email.hashCode +
      password.hashCode +
      code.hashCode +
      captchaToken.hashCode +
      nickname.hashCode;

  factory RegisterWithCookieRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterWithCookieRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterWithCookieRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
