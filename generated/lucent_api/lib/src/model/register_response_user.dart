//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'register_response_user.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RegisterResponseUser {
  /// Returns a new [RegisterResponseUser] instance.
  RegisterResponseUser({
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

  @JsonKey(name: r'email', required: true, includeIfNull: true)
  final String? email;

  @JsonKey(name: r'nickname', required: true, includeIfNull: true)
  final String? nickname;

  /// 邮箱是否已验证
  @JsonKey(name: r'emailVerified', required: true, includeIfNull: false)
  final bool emailVerified;

  @JsonKey(name: r'emailVerifiedAt', required: true, includeIfNull: true)
  final String? emailVerifiedAt;

  /// 创建时间 (ISO 8601)
  @JsonKey(name: r'createdAt', required: true, includeIfNull: false)
  final String createdAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RegisterResponseUser &&
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

  factory RegisterResponseUser.fromJson(Map<String, dynamic> json) =>
      _$RegisterResponseUserFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterResponseUserToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
