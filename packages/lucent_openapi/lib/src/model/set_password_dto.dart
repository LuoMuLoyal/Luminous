//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'set_password_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SetPasswordDto {
  /// Returns a new [SetPasswordDto] instance.
  SetPasswordDto({this.email, required this.code, required this.password});

  /// 邮箱（OAuth-only 用户尚无邮箱时必须提供，用于同时绑定邮箱）
  @JsonKey(name: r'email', required: false, includeIfNull: false)
  final String? email;

  /// 发往邮箱的验证码
  @JsonKey(name: r'code', required: true, includeIfNull: false)
  final String code;

  /// 新密码（8-32位，需包含大小写字母和数字）
  @JsonKey(name: r'password', required: true, includeIfNull: false)
  final String password;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SetPasswordDto &&
          other.email == email &&
          other.code == code &&
          other.password == password;

  @override
  int get hashCode => email.hashCode + code.hashCode + password.hashCode;

  factory SetPasswordDto.fromJson(Map<String, dynamic> json) =>
      _$SetPasswordDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SetPasswordDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
