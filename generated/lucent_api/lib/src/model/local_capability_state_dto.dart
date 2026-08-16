//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'local_capability_state_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class LocalCapabilityStateDto {
  /// Returns a new [LocalCapabilityStateDto] instance.
  LocalCapabilityStateDto({required this.state});

  /// Local scheduling capability state.
  @JsonKey(
    name: r'state',
    required: true,
    includeIfNull: false,
    unknownEnumValue: LocalCapabilityStateDtoStateEnum.unknownDefaultOpenApi,
  )
  final LocalCapabilityStateDtoStateEnum state;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalCapabilityStateDto && other.state == state;

  @override
  int get hashCode => state.hashCode;

  factory LocalCapabilityStateDto.fromJson(Map<String, dynamic> json) =>
      _$LocalCapabilityStateDtoFromJson(json);

  Map<String, dynamic> toJson() => _$LocalCapabilityStateDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// Local scheduling capability state.
enum LocalCapabilityStateDtoStateEnum {
  /// Local scheduling capability state.
  @JsonValue(r'active')
  active(r'active'),

  /// Local scheduling capability state.
  @JsonValue(r'unavailable')
  unavailable(r'unavailable'),

  /// Local scheduling capability state.
  @JsonValue(r'disabled')
  disabled(r'disabled'),

  /// Local scheduling capability state.
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const LocalCapabilityStateDtoStateEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
