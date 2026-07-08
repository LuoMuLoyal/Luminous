// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'forgot_password_dto.g.dart';

@JsonSerializable()
class ForgotPasswordDto {
  const ForgotPasswordDto({required this.email});

  factory ForgotPasswordDto.fromJson(Map<String, Object?> json) =>
      _$ForgotPasswordDtoFromJson(json);

  /// 邮箱地址
  final String email;

  Map<String, Object?> toJson() => _$ForgotPasswordDtoToJson(this);
}
