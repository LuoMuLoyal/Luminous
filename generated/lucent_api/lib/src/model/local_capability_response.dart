//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'local_capability_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class LocalCapabilityResponse {
  /// Returns a new [LocalCapabilityResponse] instance.
  LocalCapabilityResponse({required this.state});

  /// Persisted local scheduling capability state.
  @JsonKey(
    name: r'state',
    required: true,
    includeIfNull: false,
    unknownEnumValue: LocalCapabilityResponseStateEnum.unknownDefaultOpenApi,
  )
  final LocalCapabilityResponseStateEnum state;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalCapabilityResponse && other.state == state;

  @override
  int get hashCode => state.hashCode;

  factory LocalCapabilityResponse.fromJson(Map<String, dynamic> json) =>
      _$LocalCapabilityResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LocalCapabilityResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// Persisted local scheduling capability state.
enum LocalCapabilityResponseStateEnum {
  @JsonValue(r'active')
  active(r'active'),
  @JsonValue(r'unavailable')
  unavailable(r'unavailable'),
  @JsonValue(r'disabled')
  disabled(r'disabled'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const LocalCapabilityResponseStateEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
