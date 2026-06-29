//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'verify_two_factor_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class VerifyTwoFactorDto {
  /// Returns a new [VerifyTwoFactorDto] instance.
  VerifyTwoFactorDto({required this.code, required this.tempToken});

  /// TOTP code or recovery code
  @JsonKey(name: r'code', required: true, includeIfNull: false)
  final String code;

  /// Temporary token from login response
  @JsonKey(name: r'tempToken', required: true, includeIfNull: false)
  final String tempToken;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VerifyTwoFactorDto &&
          other.code == code &&
          other.tempToken == tempToken;

  @override
  int get hashCode => code.hashCode + tempToken.hashCode;

  factory VerifyTwoFactorDto.fromJson(Map<String, dynamic> json) =>
      _$VerifyTwoFactorDtoFromJson(json);

  Map<String, dynamic> toJson() => _$VerifyTwoFactorDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
