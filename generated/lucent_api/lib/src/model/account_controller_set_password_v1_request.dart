//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'account_controller_set_password_v1_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AccountControllerSetPasswordV1Request {
  /// Returns a new [AccountControllerSetPasswordV1Request] instance.
  AccountControllerSetPasswordV1Request({
    required this.code,

    required this.password,
  });

  /// 发往邮箱的验证码
  @JsonKey(name: r'code', required: true, includeIfNull: false)
  final String code;

  /// 新密码（8-32位，需包含大小写字母和数字）
  @JsonKey(name: r'password', required: true, includeIfNull: false)
  final String password;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountControllerSetPasswordV1Request &&
          other.code == code &&
          other.password == password;

  @override
  int get hashCode => code.hashCode + password.hashCode;

  factory AccountControllerSetPasswordV1Request.fromJson(
    Map<String, dynamic> json,
  ) => _$AccountControllerSetPasswordV1RequestFromJson(json);

  Map<String, dynamic> toJson() =>
      _$AccountControllerSetPasswordV1RequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
