//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/account_response_linked_identities.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'account_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AccountResponse {
  /// Returns a new [AccountResponse] instance.
  AccountResponse({
    required this.id,

    required this.email,

    required this.nickname,

    required this.avatar,

    required this.emailVerifiedAt,

    required this.hasPassword,

    required this.lastLoginAt,

    required this.linkedIdentities,

    required this.createdAt,

    required this.updatedAt,
  });

  /// User ID.
  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'email', required: true, includeIfNull: true)
  final String? email;

  @JsonKey(name: r'nickname', required: true, includeIfNull: true)
  final String? nickname;

  @JsonKey(name: r'avatar', required: true, includeIfNull: true)
  final String? avatar;

  @JsonKey(name: r'emailVerifiedAt', required: true, includeIfNull: true)
  final String? emailVerifiedAt;

  /// Whether the account has a local password.
  @JsonKey(name: r'hasPassword', required: true, includeIfNull: false)
  final bool hasPassword;

  @JsonKey(name: r'lastLoginAt', required: true, includeIfNull: true)
  final String? lastLoginAt;

  /// Linked third-party identities without provider user ids.
  @JsonKey(name: r'linkedIdentities', required: true, includeIfNull: false)
  final List<AccountResponseLinkedIdentities> linkedIdentities;

  /// Created time in ISO 8601.
  @JsonKey(name: r'createdAt', required: true, includeIfNull: false)
  final String createdAt;

  /// Updated time in ISO 8601.
  @JsonKey(name: r'updatedAt', required: true, includeIfNull: false)
  final String updatedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountResponse &&
          other.id == id &&
          other.email == email &&
          other.nickname == nickname &&
          other.avatar == avatar &&
          other.emailVerifiedAt == emailVerifiedAt &&
          other.hasPassword == hasPassword &&
          other.lastLoginAt == lastLoginAt &&
          other.linkedIdentities == linkedIdentities &&
          other.createdAt == createdAt &&
          other.updatedAt == updatedAt;

  @override
  int get hashCode =>
      id.hashCode +
      (email == null ? 0 : email.hashCode) +
      (nickname == null ? 0 : nickname.hashCode) +
      (avatar == null ? 0 : avatar.hashCode) +
      (emailVerifiedAt == null ? 0 : emailVerifiedAt.hashCode) +
      hasPassword.hashCode +
      (lastLoginAt == null ? 0 : lastLoginAt.hashCode) +
      linkedIdentities.hashCode +
      createdAt.hashCode +
      updatedAt.hashCode;

  factory AccountResponse.fromJson(Map<String, dynamic> json) =>
      _$AccountResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AccountResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
