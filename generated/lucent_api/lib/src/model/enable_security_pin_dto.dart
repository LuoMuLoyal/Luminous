//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'enable_security_pin_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EnableSecurityPinDto {
  /// Returns a new [EnableSecurityPinDto] instance.
  EnableSecurityPinDto({required this.pin});

  /// 6-digit numeric PIN
  @JsonKey(name: r'pin', required: true, includeIfNull: false)
  final String pin;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnableSecurityPinDto && other.pin == pin;

  @override
  int get hashCode => pin.hashCode;

  factory EnableSecurityPinDto.fromJson(Map<String, dynamic> json) =>
      _$EnableSecurityPinDtoFromJson(json);

  Map<String, dynamic> toJson() => _$EnableSecurityPinDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
