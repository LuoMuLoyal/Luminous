// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'success_response_dto.g.dart';

@JsonSerializable()
class SuccessResponseDto {
  const SuccessResponseDto({
    required this.code,
    required this.message,
    required this.data,
  });

  factory SuccessResponseDto.fromJson(Map<String, Object?> json) =>
      _$SuccessResponseDtoFromJson(json);

  /// 结果码
  final num code;

  /// 提示消息
  final String message;

  /// 数据
  final dynamic data;

  Map<String, Object?> toJson() => _$SuccessResponseDtoToJson(this);
}
