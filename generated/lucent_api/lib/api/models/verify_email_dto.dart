// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'verify_email_dto.g.dart';

@JsonSerializable()
class VerifyEmailDto {
  const VerifyEmailDto({required this.email, required this.code});

  factory VerifyEmailDto.fromJson(Map<String, Object?> json) =>
      _$VerifyEmailDtoFromJson(json);

  /// 邮箱地址
  final String email;

  /// 验证码
  final String code;

  Map<String, Object?> toJson() => _$VerifyEmailDtoToJson(this);
}
