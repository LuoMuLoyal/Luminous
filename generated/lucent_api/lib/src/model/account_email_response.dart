//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'account_email_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AccountEmailResponse {
  /// Returns a new [AccountEmailResponse] instance.
  AccountEmailResponse({required this.email, required this.emailVerifiedAt});

  /// New email address.
  @JsonKey(name: r'email', required: true, includeIfNull: false)
  final String email;

  @JsonKey(name: r'emailVerifiedAt', required: true, includeIfNull: true)
  final String? emailVerifiedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountEmailResponse &&
          other.email == email &&
          other.emailVerifiedAt == emailVerifiedAt;

  @override
  int get hashCode =>
      email.hashCode + (emailVerifiedAt == null ? 0 : emailVerifiedAt.hashCode);

  factory AccountEmailResponse.fromJson(Map<String, dynamic> json) =>
      _$AccountEmailResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AccountEmailResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
