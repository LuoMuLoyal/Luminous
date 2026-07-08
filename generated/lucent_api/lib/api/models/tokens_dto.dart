// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'tokens_dto.g.dart';

@JsonSerializable()
class TokensDto {
  const TokensDto({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
  });

  factory TokensDto.fromJson(Map<String, Object?> json) =>
      _$TokensDtoFromJson(json);

  /// 访问令牌
  final String accessToken;

  /// 刷新令牌
  final String refreshToken;

  /// 访问令牌过期时间（秒）
  final num expiresIn;

  Map<String, Object?> toJson() => _$TokensDtoToJson(this);
}
