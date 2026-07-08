// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'disable_security_pin_dto.g.dart';

@JsonSerializable()
class DisableSecurityPinDto {
  const DisableSecurityPinDto({required this.pin});

  factory DisableSecurityPinDto.fromJson(Map<String, Object?> json) =>
      _$DisableSecurityPinDtoFromJson(json);

  /// Current 6-digit PIN
  final String pin;

  Map<String, Object?> toJson() => _$DisableSecurityPinDtoToJson(this);
}
