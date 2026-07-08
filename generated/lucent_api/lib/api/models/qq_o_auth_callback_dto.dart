// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'qq_o_auth_callback_dto.g.dart';

@JsonSerializable()
class QqOAuthCallbackDto {
  const QqOAuthCallbackDto({required this.code, required this.state});

  factory QqOAuthCallbackDto.fromJson(Map<String, Object?> json) =>
      _$QqOAuthCallbackDtoFromJson(json);

  /// QQ 授权码
  final String code;

  /// 授权时生成的 state
  final String state;

  Map<String, Object?> toJson() => _$QqOAuthCallbackDtoToJson(this);
}
