// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'account_identity_dto.g.dart';

@JsonSerializable()
class AccountIdentityDto {
  const AccountIdentityDto({
    required this.id,
    required this.provider,
    required this.email,
    required this.emailVerifiedAt,
    required this.linkedAt,
  });

  factory AccountIdentityDto.fromJson(Map<String, Object?> json) =>
      _$AccountIdentityDtoFromJson(json);

  /// Account identity ID.
  final String id;

  /// OAuth provider name.
  final String provider;

  /// Provider email when the provider exposes one.
  final String? email;

  /// Provider email verification time in ISO 8601.
  final String? emailVerifiedAt;

  /// Identity linked time in ISO 8601.
  final String linkedAt;

  Map<String, Object?> toJson() => _$AccountIdentityDtoToJson(this);
}
