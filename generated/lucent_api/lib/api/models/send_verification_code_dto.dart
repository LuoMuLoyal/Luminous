// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'send_verification_code_dto_scene_scene.dart';

part 'send_verification_code_dto.g.dart';

@JsonSerializable()
class SendVerificationCodeDto {
  const SendVerificationCodeDto({required this.email, required this.scene});

  factory SendVerificationCodeDto.fromJson(Map<String, Object?> json) =>
      _$SendVerificationCodeDtoFromJson(json);

  /// 邮箱地址
  final String email;

  /// 验证码场景
  final SendVerificationCodeDtoSceneScene scene;

  Map<String, Object?> toJson() => _$SendVerificationCodeDtoToJson(this);
}
