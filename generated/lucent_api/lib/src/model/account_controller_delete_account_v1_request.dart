//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'account_controller_delete_account_v1_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AccountControllerDeleteAccountV1Request {
  /// Returns a new [AccountControllerDeleteAccountV1Request] instance.
  AccountControllerDeleteAccountV1Request({this.password, this.code});

  /// 当前密码（有密码的用户使用此方式确认注销）
  @JsonKey(name: r'password', required: false, includeIfNull: false)
  final String? password;

  /// 邮箱验证码（OAuth-only 用户使用此方式确认注销）
  @JsonKey(name: r'code', required: false, includeIfNull: false)
  final String? code;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountControllerDeleteAccountV1Request &&
          other.password == password &&
          other.code == code;

  @override
  int get hashCode => password.hashCode + code.hashCode;

  factory AccountControllerDeleteAccountV1Request.fromJson(
    Map<String, dynamic> json,
  ) => _$AccountControllerDeleteAccountV1RequestFromJson(json);

  Map<String, dynamic> toJson() =>
      _$AccountControllerDeleteAccountV1RequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
