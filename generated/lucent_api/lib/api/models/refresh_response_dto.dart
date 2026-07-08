// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'tokens_dto.dart';

part 'refresh_response_dto.g.dart';

@JsonSerializable()
class RefreshResponseDto {
  const RefreshResponseDto({
    required this.code,
    required this.message,
    required this.data,
  });

  factory RefreshResponseDto.fromJson(Map<String, Object?> json) =>
      _$RefreshResponseDtoFromJson(json);

  /// 结果码
  final num code;

  /// 提示消息
  final String message;
  final TokensDto data;

  Map<String, Object?> toJson() => _$RefreshResponseDtoToJson(this);
}
