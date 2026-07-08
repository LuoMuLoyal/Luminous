// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'verify_security_pin_dto.g.dart';

@JsonSerializable()
class VerifySecurityPinDto {
  const VerifySecurityPinDto({required this.pin});

  factory VerifySecurityPinDto.fromJson(Map<String, Object?> json) =>
      _$VerifySecurityPinDtoFromJson(json);

  /// 6-digit PIN to verify
  final String pin;

  Map<String, Object?> toJson() => _$VerifySecurityPinDtoToJson(this);
}
