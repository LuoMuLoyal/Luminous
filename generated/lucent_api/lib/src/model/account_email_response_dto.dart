//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'account_email_response_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AccountEmailResponseDto {
  /// Returns a new [AccountEmailResponseDto] instance.
  AccountEmailResponseDto({required this.email, required this.emailVerifiedAt});

  /// New email address.
  @JsonKey(name: r'email', required: true, includeIfNull: false)
  final String email;

  /// Email verification time in ISO 8601.
  @JsonKey(name: r'emailVerifiedAt', required: true, includeIfNull: false)
  final String emailVerifiedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountEmailResponseDto &&
          other.email == email &&
          other.emailVerifiedAt == emailVerifiedAt;

  @override
  int get hashCode => email.hashCode + emailVerifiedAt.hashCode;

  factory AccountEmailResponseDto.fromJson(Map<String, dynamic> json) =>
      _$AccountEmailResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AccountEmailResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
