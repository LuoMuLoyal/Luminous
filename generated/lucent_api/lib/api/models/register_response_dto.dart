// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'register_data_dto.dart';

part 'register_response_dto.g.dart';

@JsonSerializable()
class RegisterResponseDto {
  const RegisterResponseDto({
    required this.code,
    required this.message,
    required this.data,
  });

  factory RegisterResponseDto.fromJson(Map<String, Object?> json) =>
      _$RegisterResponseDtoFromJson(json);

  /// 结果码
  final num code;

  /// 提示消息
  final String message;
  final RegisterDataDto data;

  Map<String, Object?> toJson() => _$RegisterResponseDtoToJson(this);
}
