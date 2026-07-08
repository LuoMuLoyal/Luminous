// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'login_data_dto.dart';

part 'login_response_dto.g.dart';

@JsonSerializable()
class LoginResponseDto {
  const LoginResponseDto({
    required this.code,
    required this.message,
    required this.data,
  });

  factory LoginResponseDto.fromJson(Map<String, Object?> json) =>
      _$LoginResponseDtoFromJson(json);

  /// 结果码
  final num code;

  /// 提示消息
  final String message;
  final LoginDataDto data;

  Map<String, Object?> toJson() => _$LoginResponseDtoToJson(this);
}
