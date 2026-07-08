// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'refresh_dto.g.dart';

@JsonSerializable()
class RefreshDto {
  const RefreshDto({required this.refreshToken});

  factory RefreshDto.fromJson(Map<String, Object?> json) =>
      _$RefreshDtoFromJson(json);

  /// 刷新令牌
  final String refreshToken;

  Map<String, Object?> toJson() => _$RefreshDtoToJson(this);
}
