// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'register_dto.g.dart';

@JsonSerializable()
class RegisterDto {
  const RegisterDto({
    required this.email,
    required this.password,
    required this.code,
    this.nickname,
  });

  factory RegisterDto.fromJson(Map<String, Object?> json) =>
      _$RegisterDtoFromJson(json);

  /// 邮箱地址
  final String email;

  /// 密码（8-32位，需包含大小写字母和数字）
  final String password;

  /// 邮箱验证码
  final String code;

  /// 昵称
  final String? nickname;

  Map<String, Object?> toJson() => _$RegisterDtoToJson(this);
}
