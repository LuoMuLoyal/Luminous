//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'change_security_pin_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ChangeSecurityPinDto {
  /// Returns a new [ChangeSecurityPinDto] instance.
  ChangeSecurityPinDto({required this.oldPin, required this.newPin});

  /// Current 6-digit PIN
  @JsonKey(name: r'oldPin', required: true, includeIfNull: false)
  final String oldPin;

  /// New 6-digit PIN
  @JsonKey(name: r'newPin', required: true, includeIfNull: false)
  final String newPin;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChangeSecurityPinDto &&
          other.oldPin == oldPin &&
          other.newPin == newPin;

  @override
  int get hashCode => oldPin.hashCode + newPin.hashCode;

  factory ChangeSecurityPinDto.fromJson(Map<String, dynamic> json) =>
      _$ChangeSecurityPinDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ChangeSecurityPinDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
