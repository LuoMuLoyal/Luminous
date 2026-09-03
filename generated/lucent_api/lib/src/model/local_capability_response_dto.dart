//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'local_capability_response_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class LocalCapabilityResponseDto {
  /// Returns a new [LocalCapabilityResponseDto] instance.
  LocalCapabilityResponseDto({required this.state});

  /// Persisted local scheduling capability state.
  @JsonKey(
    name: r'state',
    required: true,
    includeIfNull: false,
    unknownEnumValue: LocalCapabilityResponseDtoStateEnum.unknownDefaultOpenApi,
  )
  final LocalCapabilityResponseDtoStateEnum state;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalCapabilityResponseDto && other.state == state;

  @override
  int get hashCode => state.hashCode;

  factory LocalCapabilityResponseDto.fromJson(Map<String, dynamic> json) =>
      _$LocalCapabilityResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$LocalCapabilityResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// Persisted local scheduling capability state.
enum LocalCapabilityResponseDtoStateEnum {
  @JsonValue(r'active')
  active(r'active'),
  @JsonValue(r'unavailable')
  unavailable(r'unavailable'),
  @JsonValue(r'disabled')
  disabled(r'disabled'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const LocalCapabilityResponseDtoStateEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
