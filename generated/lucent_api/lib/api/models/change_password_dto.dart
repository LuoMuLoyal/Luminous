// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'change_password_dto.g.dart';

@JsonSerializable()
class ChangePasswordDto {
  const ChangePasswordDto({
    required this.oldPassword,
    required this.newPassword,
  });

  factory ChangePasswordDto.fromJson(Map<String, Object?> json) =>
      _$ChangePasswordDtoFromJson(json);

  /// 当前密码
  final String oldPassword;

  /// 新密码（8-32位，需包含大小写字母和数字）
  final String newPassword;

  Map<String, Object?> toJson() => _$ChangePasswordDtoToJson(this);
}
