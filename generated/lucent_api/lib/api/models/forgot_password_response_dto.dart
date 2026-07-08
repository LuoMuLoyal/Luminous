// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'cooldown_message_dto.dart';

part 'forgot_password_response_dto.g.dart';

@JsonSerializable()
class ForgotPasswordResponseDto {
  const ForgotPasswordResponseDto({
    required this.code,
    required this.message,
    required this.data,
  });

  factory ForgotPasswordResponseDto.fromJson(Map<String, Object?> json) =>
      _$ForgotPasswordResponseDtoFromJson(json);

  /// 结果码
  final num code;

  /// 提示消息
  final String message;
  final CooldownMessageDto data;

  Map<String, Object?> toJson() => _$ForgotPasswordResponseDtoToJson(this);
}
