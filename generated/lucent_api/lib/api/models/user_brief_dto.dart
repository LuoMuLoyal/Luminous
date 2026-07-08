// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'user_brief_dto.g.dart';

@JsonSerializable()
class UserBriefDto {
  const UserBriefDto({
    required this.id,
    required this.email,
    required this.nickname,
    required this.emailVerified,
    required this.emailVerifiedAt,
    required this.createdAt,
  });

  factory UserBriefDto.fromJson(Map<String, Object?> json) =>
      _$UserBriefDtoFromJson(json);

  /// 用户 ID
  final String id;

  /// 邮箱地址，第三方账号可能为空
  final String? email;

  /// 昵称
  final String? nickname;

  /// 邮箱是否已验证
  final bool emailVerified;

  /// 邮箱验证时间 (ISO 8601)
  final String? emailVerifiedAt;

  /// 创建时间 (ISO 8601)
  final String createdAt;

  Map<String, Object?> toJson() => _$UserBriefDtoToJson(this);
}
