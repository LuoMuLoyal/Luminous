// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'verify_email_data_dto.dart';

part 'verify_email_response_dto.g.dart';

@JsonSerializable()
class VerifyEmailResponseDto {
  const VerifyEmailResponseDto({
    required this.code,
    required this.message,
    required this.data,
  });

  factory VerifyEmailResponseDto.fromJson(Map<String, Object?> json) =>
      _$VerifyEmailResponseDtoFromJson(json);

  /// 结果码
  final num code;

  /// 提示消息
  final String message;
  final VerifyEmailDataDto data;

  Map<String, Object?> toJson() => _$VerifyEmailResponseDtoToJson(this);
}
