//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'account_email_data_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AccountEmailDataDto {
  /// Returns a new [AccountEmailDataDto] instance.
  AccountEmailDataDto({required this.email, required this.emailVerifiedAt});

  /// New email address.
  @JsonKey(name: r'email', required: true, includeIfNull: false)
  final String email;

  /// Email verification time in ISO 8601.
  @JsonKey(name: r'emailVerifiedAt', required: true, includeIfNull: false)
  final String emailVerifiedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountEmailDataDto &&
          other.email == email &&
          other.emailVerifiedAt == emailVerifiedAt;

  @override
  int get hashCode => email.hashCode + emailVerifiedAt.hashCode;

  factory AccountEmailDataDto.fromJson(Map<String, dynamic> json) =>
      _$AccountEmailDataDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AccountEmailDataDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
