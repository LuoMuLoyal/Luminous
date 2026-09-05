//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'account_response_linked_identities.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AccountResponseLinkedIdentities {
  /// Returns a new [AccountResponseLinkedIdentities] instance.
  AccountResponseLinkedIdentities({
    required this.id,

    required this.provider,

    required this.email,

    required this.emailVerifiedAt,

    required this.linkedAt,
  });

  /// Account identity ID.
  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  /// OAuth provider name.
  @JsonKey(name: r'provider', required: true, includeIfNull: false)
  final String provider;

  @JsonKey(name: r'email', required: true, includeIfNull: true)
  final String? email;

  @JsonKey(name: r'emailVerifiedAt', required: true, includeIfNull: true)
  final String? emailVerifiedAt;

  /// Identity linked time in ISO 8601.
  @JsonKey(name: r'linkedAt', required: true, includeIfNull: false)
  final String linkedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountResponseLinkedIdentities &&
          other.id == id &&
          other.provider == provider &&
          other.email == email &&
          other.emailVerifiedAt == emailVerifiedAt &&
          other.linkedAt == linkedAt;

  @override
  int get hashCode =>
      id.hashCode +
      provider.hashCode +
      (email == null ? 0 : email.hashCode) +
      (emailVerifiedAt == null ? 0 : emailVerifiedAt.hashCode) +
      linkedAt.hashCode;

  factory AccountResponseLinkedIdentities.fromJson(Map<String, dynamic> json) =>
      _$AccountResponseLinkedIdentitiesFromJson(json);

  Map<String, dynamic> toJson() =>
      _$AccountResponseLinkedIdentitiesToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
