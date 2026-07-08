// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'logout_dto.g.dart';

@JsonSerializable()
class LogoutDto {
  const LogoutDto({required this.refreshToken});

  factory LogoutDto.fromJson(Map<String, Object?> json) =>
      _$LogoutDtoFromJson(json);

  /// 刷新令牌
  final String refreshToken;

  Map<String, Object?> toJson() => _$LogoutDtoToJson(this);
}
