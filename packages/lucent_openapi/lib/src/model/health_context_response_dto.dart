//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_openapi/src/model/health_context_data_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'health_context_response_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class HealthContextResponseDto {
  /// Returns a new [HealthContextResponseDto] instance.
  HealthContextResponseDto({
    required this.code,

    required this.message,

    required this.data,
  });

  /// Result code
  @JsonKey(name: r'code', required: true, includeIfNull: false)
  final num code;

  /// Prompt message
  @JsonKey(name: r'message', required: true, includeIfNull: false)
  final String message;

  @JsonKey(name: r'data', required: true, includeIfNull: false)
  final HealthContextDataDto data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthContextResponseDto &&
          other.code == code &&
          other.message == message &&
          other.data == data;

  @override
  int get hashCode => code.hashCode + message.hashCode + data.hashCode;

  factory HealthContextResponseDto.fromJson(Map<String, dynamic> json) =>
      _$HealthContextResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$HealthContextResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
