//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'login_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class LoginRequest {
  /// Returns a new [LoginRequest] instance.
  LoginRequest({required this.email, this.password, this.code});

  /// 邮箱地址
  @JsonKey(name: r'email', required: true, includeIfNull: false)
  final String email;

  /// 密码（与验证码二选一）
  @JsonKey(name: r'password', required: false, includeIfNull: false)
  final String? password;

  /// 邮箱验证码（与密码二选一）
  @JsonKey(name: r'code', required: false, includeIfNull: false)
  final String? code;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoginRequest &&
          other.email == email &&
          other.password == password &&
          other.code == code;

  @override
  int get hashCode => email.hashCode + password.hashCode + code.hashCode;

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);

  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
