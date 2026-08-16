//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'local_capability_data_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class LocalCapabilityDataDto {
  /// Returns a new [LocalCapabilityDataDto] instance.
  LocalCapabilityDataDto({required this.state});

  /// Persisted local scheduling capability state.
  @JsonKey(
    name: r'state',
    required: true,
    includeIfNull: false,
    unknownEnumValue: LocalCapabilityDataDtoStateEnum.unknownDefaultOpenApi,
  )
  final LocalCapabilityDataDtoStateEnum state;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalCapabilityDataDto && other.state == state;

  @override
  int get hashCode => state.hashCode;

  factory LocalCapabilityDataDto.fromJson(Map<String, dynamic> json) =>
      _$LocalCapabilityDataDtoFromJson(json);

  Map<String, dynamic> toJson() => _$LocalCapabilityDataDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// Persisted local scheduling capability state.
enum LocalCapabilityDataDtoStateEnum {
  /// Persisted local scheduling capability state.
  @JsonValue(r'active')
  active(r'active'),

  /// Persisted local scheduling capability state.
  @JsonValue(r'unavailable')
  unavailable(r'unavailable'),

  /// Persisted local scheduling capability state.
  @JsonValue(r'disabled')
  disabled(r'disabled'),

  /// Persisted local scheduling capability state.
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const LocalCapabilityDataDtoStateEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
