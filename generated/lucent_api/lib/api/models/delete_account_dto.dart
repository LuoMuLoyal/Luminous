// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'delete_account_dto.g.dart';

@JsonSerializable()
class DeleteAccountDto {
  const DeleteAccountDto({this.password, this.code});

  factory DeleteAccountDto.fromJson(Map<String, Object?> json) =>
      _$DeleteAccountDtoFromJson(json);

  /// 当前密码（有密码的用户使用此方式确认注销）
  final String? password;

  /// 邮箱验证码（OAuth-only 用户使用此方式确认注销）
  final String? code;

  Map<String, Object?> toJson() => _$DeleteAccountDtoToJson(this);
}
