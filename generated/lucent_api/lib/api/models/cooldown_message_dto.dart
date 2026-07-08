// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'cooldown_message_dto.g.dart';

@JsonSerializable()
class CooldownMessageDto {
  const CooldownMessageDto({required this.cooldown, required this.message});

  factory CooldownMessageDto.fromJson(Map<String, Object?> json) =>
      _$CooldownMessageDtoFromJson(json);

  /// 冷却时间（秒）
  final num cooldown;

  /// 提示消息
  final String message;

  Map<String, Object?> toJson() => _$CooldownMessageDtoToJson(this);
}
