//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'account_controller_change_password_v1_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AccountControllerChangePasswordV1Request {
  /// Returns a new [AccountControllerChangePasswordV1Request] instance.
  AccountControllerChangePasswordV1Request({
    required this.password,

    required this.newPassword,
  });

  /// 当前密码（敏感操作再认证用）
  @JsonKey(name: r'password', required: true, includeIfNull: false)
  final String password;

  /// 新密码（8-32位，需包含大小写字母和数字）
  @JsonKey(name: r'newPassword', required: true, includeIfNull: false)
  final String newPassword;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountControllerChangePasswordV1Request &&
          other.password == password &&
          other.newPassword == newPassword;

  @override
  int get hashCode => password.hashCode + newPassword.hashCode;

  factory AccountControllerChangePasswordV1Request.fromJson(
    Map<String, dynamic> json,
  ) => _$AccountControllerChangePasswordV1RequestFromJson(json);

  Map<String, dynamic> toJson() =>
      _$AccountControllerChangePasswordV1RequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
