//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'user_brief_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UserBriefDto {
  /// Returns a new [UserBriefDto] instance.
  UserBriefDto({
    required this.id,

    required this.email,

    required this.nickname,

    required this.emailVerified,

    required this.emailVerifiedAt,

    required this.createdAt,
  });

  /// 用户 ID
  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  /// 邮箱地址，第三方账号可能为空
  @JsonKey(name: r'email', required: true, includeIfNull: true)
  final Object? email;

  /// 昵称
  @JsonKey(name: r'nickname', required: true, includeIfNull: true)
  final Object? nickname;

  /// 邮箱是否已验证
  @JsonKey(name: r'emailVerified', required: true, includeIfNull: false)
  final bool emailVerified;

  /// 邮箱验证时间 (ISO 8601)
  @JsonKey(name: r'emailVerifiedAt', required: true, includeIfNull: true)
  final Object? emailVerifiedAt;

  /// 创建时间 (ISO 8601)
  @JsonKey(name: r'createdAt', required: true, includeIfNull: false)
  final String createdAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserBriefDto &&
          other.id == id &&
          other.email == email &&
          other.nickname == nickname &&
          other.emailVerified == emailVerified &&
          other.emailVerifiedAt == emailVerifiedAt &&
          other.createdAt == createdAt;

  @override
  int get hashCode =>
      id.hashCode +
      (email == null ? 0 : email.hashCode) +
      (nickname == null ? 0 : nickname.hashCode) +
      emailVerified.hashCode +
      (emailVerifiedAt == null ? 0 : emailVerifiedAt.hashCode) +
      createdAt.hashCode;

  factory UserBriefDto.fromJson(Map<String, dynamic> json) =>
      _$UserBriefDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UserBriefDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
