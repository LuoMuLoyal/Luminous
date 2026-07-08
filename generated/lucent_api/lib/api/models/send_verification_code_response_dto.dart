// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'cooldown_message_dto.dart';

part 'send_verification_code_response_dto.g.dart';

@JsonSerializable()
class SendVerificationCodeResponseDto {
  const SendVerificationCodeResponseDto({
    required this.code,
    required this.message,
    required this.data,
  });

  factory SendVerificationCodeResponseDto.fromJson(Map<String, Object?> json) =>
      _$SendVerificationCodeResponseDtoFromJson(json);

  /// 结果码
  final num code;

  /// 提示消息
  final String message;
  final CooldownMessageDto data;

  Map<String, Object?> toJson() =>
      _$SendVerificationCodeResponseDtoToJson(this);
}
