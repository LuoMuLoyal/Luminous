//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'disable_security_pin_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DisableSecurityPinDto {
  /// Returns a new [DisableSecurityPinDto] instance.
  DisableSecurityPinDto({required this.pin});

  /// Current 6-digit PIN
  @JsonKey(name: r'pin', required: true, includeIfNull: false)
  final String pin;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DisableSecurityPinDto && other.pin == pin;

  @override
  int get hashCode => pin.hashCode;

  factory DisableSecurityPinDto.fromJson(Map<String, dynamic> json) =>
      _$DisableSecurityPinDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DisableSecurityPinDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
