// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'login_dto.g.dart';

@JsonSerializable()
class LoginDto {
  const LoginDto({required this.email, this.password, this.code});

  factory LoginDto.fromJson(Map<String, Object?> json) =>
      _$LoginDtoFromJson(json);

  /// 邮箱地址
  final String email;

  /// 密码（与验证码二选一）
  final String? password;

  /// 邮箱验证码（与密码二选一）
  final String? code;

  Map<String, Object?> toJson() => _$LoginDtoToJson(this);
}
