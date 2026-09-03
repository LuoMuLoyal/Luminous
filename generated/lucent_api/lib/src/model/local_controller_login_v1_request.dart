//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'local_controller_login_v1_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class LocalControllerLoginV1Request {
  /// Returns a new [LocalControllerLoginV1Request] instance.
  LocalControllerLoginV1Request({
    required this.email,

    this.password,

    this.code,
  });

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
      other is LocalControllerLoginV1Request &&
          other.email == email &&
          other.password == password &&
          other.code == code;

  @override
  int get hashCode => email.hashCode + password.hashCode + code.hashCode;

  factory LocalControllerLoginV1Request.fromJson(Map<String, dynamic> json) =>
      _$LocalControllerLoginV1RequestFromJson(json);

  Map<String, dynamic> toJson() => _$LocalControllerLoginV1RequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
