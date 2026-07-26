//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'verify_security_pin_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class VerifySecurityPinDto {
  /// Returns a new [VerifySecurityPinDto] instance.
  VerifySecurityPinDto({required this.pin});

  /// 6-digit PIN to verify
  @JsonKey(name: r'pin', required: true, includeIfNull: false)
  final String pin;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VerifySecurityPinDto && other.pin == pin;

  @override
  int get hashCode => pin.hashCode;

  factory VerifySecurityPinDto.fromJson(Map<String, dynamic> json) =>
      _$VerifySecurityPinDtoFromJson(json);

  Map<String, dynamic> toJson() => _$VerifySecurityPinDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
