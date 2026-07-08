// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'security_pin_elevation_response_dto.g.dart';

@JsonSerializable()
class SecurityPinElevationResponseDto {
  const SecurityPinElevationResponseDto({
    required this.elevationToken,
    required this.expiresAt,
  });

  factory SecurityPinElevationResponseDto.fromJson(Map<String, Object?> json) =>
      _$SecurityPinElevationResponseDtoFromJson(json);

  /// Short-lived signed elevation token
  final String elevationToken;

  /// ISO-8601 timestamp when the elevation token expires
  final String expiresAt;

  Map<String, Object?> toJson() =>
      _$SecurityPinElevationResponseDtoToJson(this);
}
