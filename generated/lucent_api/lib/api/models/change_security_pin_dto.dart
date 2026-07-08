// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'change_security_pin_dto.g.dart';

@JsonSerializable()
class ChangeSecurityPinDto {
  const ChangeSecurityPinDto({required this.oldPin, required this.newPin});

  factory ChangeSecurityPinDto.fromJson(Map<String, Object?> json) =>
      _$ChangeSecurityPinDtoFromJson(json);

  /// Current 6-digit PIN
  final String oldPin;

  /// New 6-digit PIN
  final String newPin;

  Map<String, Object?> toJson() => _$ChangeSecurityPinDtoToJson(this);
}
