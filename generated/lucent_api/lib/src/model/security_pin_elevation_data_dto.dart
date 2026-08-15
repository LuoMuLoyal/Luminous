//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'security_pin_elevation_data_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SecurityPinElevationDataDto {
  /// Returns a new [SecurityPinElevationDataDto] instance.
  SecurityPinElevationDataDto({
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
      other is SecurityPinElevationDataDto &&
          other.elevationToken == elevationToken &&
          other.expiresAt == expiresAt;

  @override
  int get hashCode => elevationToken.hashCode + expiresAt.hashCode;

  factory SecurityPinElevationDataDto.fromJson(Map<String, dynamic> json) =>
      _$SecurityPinElevationDataDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SecurityPinElevationDataDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
