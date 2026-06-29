//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'confirm_two_factor_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ConfirmTwoFactorDto {
  /// Returns a new [ConfirmTwoFactorDto] instance.
  ConfirmTwoFactorDto({required this.code});

  /// TOTP verification code
  @JsonKey(name: r'code', required: true, includeIfNull: false)
  final String code;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConfirmTwoFactorDto && other.code == code;

  @override
  int get hashCode => code.hashCode;

  factory ConfirmTwoFactorDto.fromJson(Map<String, dynamic> json) =>
      _$ConfirmTwoFactorDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ConfirmTwoFactorDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
