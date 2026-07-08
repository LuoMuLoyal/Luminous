// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'account_identity_dto.dart';

part 'account_dto.g.dart';

@JsonSerializable()
class AccountDto {
  const AccountDto({
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

  factory AccountDto.fromJson(Map<String, Object?> json) =>
      _$AccountDtoFromJson(json);

  /// User ID.
  final String id;

  /// Account email. OAuth-only accounts may not have one.
  final String? email;

  /// Display nickname.
  final String? nickname;

  /// Avatar URL.
  final String? avatar;

  /// Account email verification time in ISO 8601.
  final String? emailVerifiedAt;

  /// Whether the account has a local password.
  final bool hasPassword;

  /// Last login time in ISO 8601.
  final String? lastLoginAt;

  /// Linked third-party identities without provider user ids.
  final List<AccountIdentityDto> linkedIdentities;

  /// Created time in ISO 8601.
  final String createdAt;

  /// Updated time in ISO 8601.
  final String updatedAt;

  Map<String, Object?> toJson() => _$AccountDtoToJson(this);
}
