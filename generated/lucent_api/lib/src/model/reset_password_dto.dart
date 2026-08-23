//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'reset_password_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ResetPasswordDto {
  /// Returns a new [ResetPasswordDto] instance.
  ResetPasswordDto({required this.token, required this.password});

  /// Better Auth 密码重置 token
  @JsonKey(name: r'token', required: true, includeIfNull: false)
  final String token;

  /// 新密码（8-32位，需包含大小写字母和数字）
  @JsonKey(name: r'password', required: true, includeIfNull: false)
  final String password;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResetPasswordDto &&
          other.token == token &&
          other.password == password;

  @override
  int get hashCode => token.hashCode + password.hashCode;

  factory ResetPasswordDto.fromJson(Map<String, dynamic> json) =>
      _$ResetPasswordDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ResetPasswordDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
