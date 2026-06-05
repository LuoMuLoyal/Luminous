//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'account_identity_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AccountIdentityDto {
  /// Returns a new [AccountIdentityDto] instance.
  AccountIdentityDto({
    required this.provider,

    required this.email,

    required this.emailVerifiedAt,

    required this.linkedAt,
  });

  /// OAuth provider name.
  @JsonKey(name: r'provider', required: true, includeIfNull: false)
  final String provider;

  /// Provider email when the provider exposes one.
  @JsonKey(name: r'email', required: true, includeIfNull: true)
  final Object? email;

  /// Provider email verification time in ISO 8601.
  @JsonKey(name: r'emailVerifiedAt', required: true, includeIfNull: true)
  final Object? emailVerifiedAt;

  /// Identity linked time in ISO 8601.
  @JsonKey(name: r'linkedAt', required: true, includeIfNull: false)
  final String linkedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountIdentityDto &&
          other.provider == provider &&
          other.email == email &&
          other.emailVerifiedAt == emailVerifiedAt &&
          other.linkedAt == linkedAt;

  @override
  int get hashCode =>
      provider.hashCode +
      (email == null ? 0 : email.hashCode) +
      (emailVerifiedAt == null ? 0 : emailVerifiedAt.hashCode) +
      linkedAt.hashCode;

  factory AccountIdentityDto.fromJson(Map<String, dynamic> json) =>
      _$AccountIdentityDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AccountIdentityDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
