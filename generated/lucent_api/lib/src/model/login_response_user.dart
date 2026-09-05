//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'login_response_user.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class LoginResponseUser {
  /// Returns a new [LoginResponseUser] instance.
  LoginResponseUser({
    required this.id,

    required this.email,

    required this.nickname,

    required this.avatar,

    required this.emailVerified,

    required this.emailVerifiedAt,

    required this.createdAt,

    required this.updatedAt,
  });

  /// 用户 ID
  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'email', required: true, includeIfNull: true)
  final String? email;

  @JsonKey(name: r'nickname', required: true, includeIfNull: true)
  final String? nickname;

  @JsonKey(name: r'avatar', required: true, includeIfNull: true)
  final String? avatar;

  /// 邮箱是否已验证
  @JsonKey(name: r'emailVerified', required: true, includeIfNull: false)
  final bool emailVerified;

  @JsonKey(name: r'emailVerifiedAt', required: true, includeIfNull: true)
  final String? emailVerifiedAt;

  /// 创建时间 (ISO 8601)
  @JsonKey(name: r'createdAt', required: true, includeIfNull: false)
  final String createdAt;

  /// 更新时间 (ISO 8601)
  @JsonKey(name: r'updatedAt', required: true, includeIfNull: false)
  final String updatedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoginResponseUser &&
          other.id == id &&
          other.email == email &&
          other.nickname == nickname &&
          other.avatar == avatar &&
          other.emailVerified == emailVerified &&
          other.emailVerifiedAt == emailVerifiedAt &&
          other.createdAt == createdAt &&
          other.updatedAt == updatedAt;

  @override
  int get hashCode =>
      id.hashCode +
      (email == null ? 0 : email.hashCode) +
      (nickname == null ? 0 : nickname.hashCode) +
      (avatar == null ? 0 : avatar.hashCode) +
      emailVerified.hashCode +
      (emailVerifiedAt == null ? 0 : emailVerifiedAt.hashCode) +
      createdAt.hashCode +
      updatedAt.hashCode;

  factory LoginResponseUser.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseUserFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseUserToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
