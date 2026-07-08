// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'enable_security_pin_dto.g.dart';

@JsonSerializable()
class EnableSecurityPinDto {
  const EnableSecurityPinDto({required this.pin});

  factory EnableSecurityPinDto.fromJson(Map<String, Object?> json) =>
      _$EnableSecurityPinDtoFromJson(json);

  /// 6-digit numeric PIN
  final String pin;

  Map<String, Object?> toJson() => _$EnableSecurityPinDtoToJson(this);
}
