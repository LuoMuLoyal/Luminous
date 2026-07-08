// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'change_email_dto.g.dart';

@JsonSerializable()
class ChangeEmailDto {
  const ChangeEmailDto({required this.newEmail, required this.code});

  factory ChangeEmailDto.fromJson(Map<String, Object?> json) =>
      _$ChangeEmailDtoFromJson(json);

  /// 新邮箱
  final String newEmail;

  /// 验证码
  final String code;

  Map<String, Object?> toJson() => _$ChangeEmailDtoToJson(this);
}
