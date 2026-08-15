//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/security_pin_elevation_data_dto.dart';
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
    required this.code,

    required this.message,

    required this.data,
  });

  /// Result code.
  @JsonKey(name: r'code', required: true, includeIfNull: false)
  final num code;

  /// Message.
  @JsonKey(name: r'message', required: true, includeIfNull: false)
  final String message;

  @JsonKey(name: r'data', required: true, includeIfNull: false)
  final SecurityPinElevationDataDto data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SecurityPinElevationResponseDto &&
          other.code == code &&
          other.message == message &&
          other.data == data;

  @override
  int get hashCode => code.hashCode + message.hashCode + data.hashCode;

  factory SecurityPinElevationResponseDto.fromJson(Map<String, dynamic> json) =>
      _$SecurityPinElevationResponseDtoFromJson(json);

  Map<String, dynamic> toJson() =>
      _$SecurityPinElevationResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
