//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'security_pin_elevation_response_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SecurityPinElevationResponseDto {
  /// Returns a new [SecurityPinElevationResponseDto] instance.
  SecurityPinElevationResponseDto({
    required this.elevationToken,
    required this.expiresAt,
  });

  /// Short-lived signed elevation token
  @JsonKey(name: r'elevationToken', required: true, includeIfNull: false)
  final String elevationToken;

  /// ISO-8601 timestamp when the elevation token expires
  @JsonKey(name: r'expiresAt', required: true, includeIfNull: false)
  final String expiresAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SecurityPinElevationResponseDto &&
          other.elevationToken == elevationToken &&
          other.expiresAt == expiresAt;

  @override
  int get hashCode => elevationToken.hashCode + expiresAt.hashCode;

  factory SecurityPinElevationResponseDto.fromJson(Map<String, dynamic> json) =>
      _$SecurityPinElevationResponseDtoFromJson(json);

  Map<String, dynamic> toJson() =>
      _$SecurityPinElevationResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
