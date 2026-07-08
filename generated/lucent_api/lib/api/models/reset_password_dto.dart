// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'reset_password_dto.g.dart';

@JsonSerializable()
class ResetPasswordDto {
  const ResetPasswordDto({
    required this.email,
    required this.code,
    required this.password,
  });

  factory ResetPasswordDto.fromJson(Map<String, Object?> json) =>
      _$ResetPasswordDtoFromJson(json);

  /// 邮箱地址
  final String email;

  /// 验证码
  final String code;

  /// 新密码（8-32位，需包含大小写字母和数字）
  final String password;

  Map<String, Object?> toJson() => _$ResetPasswordDtoToJson(this);
}
