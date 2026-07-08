// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'set_password_dto.g.dart';

@JsonSerializable()
class SetPasswordDto {
  const SetPasswordDto({
    required this.code,
    required this.password,
    this.email,
  });

  factory SetPasswordDto.fromJson(Map<String, Object?> json) =>
      _$SetPasswordDtoFromJson(json);

  /// 邮箱（OAuth-only 用户尚无邮箱时必须提供，用于同时绑定邮箱）
  final String? email;

  /// 发往邮箱的验证码
  final String code;

  /// 新密码（8-32位，需包含大小写字母和数字）
  final String password;

  Map<String, Object?> toJson() => _$SetPasswordDtoToJson(this);
}
