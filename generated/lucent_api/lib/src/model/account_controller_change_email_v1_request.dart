//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'account_controller_change_email_v1_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AccountControllerChangeEmailV1Request {
  /// Returns a new [AccountControllerChangeEmailV1Request] instance.
  AccountControllerChangeEmailV1Request({
    required this.newEmail,

    required this.code,

    required this.password,
  });

  /// 新邮箱
  @JsonKey(name: r'newEmail', required: true, includeIfNull: false)
  final String newEmail;

  /// 验证码
  @JsonKey(name: r'code', required: true, includeIfNull: false)
  final String code;

  /// 当前密码（敏感操作再认证用）
  @JsonKey(name: r'password', required: true, includeIfNull: false)
  final String password;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountControllerChangeEmailV1Request &&
          other.newEmail == newEmail &&
          other.code == code &&
          other.password == password;

  @override
  int get hashCode => newEmail.hashCode + code.hashCode + password.hashCode;

  factory AccountControllerChangeEmailV1Request.fromJson(
    Map<String, dynamic> json,
  ) => _$AccountControllerChangeEmailV1RequestFromJson(json);

  Map<String, dynamic> toJson() =>
      _$AccountControllerChangeEmailV1RequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
