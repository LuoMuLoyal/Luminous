//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/medicine_mechanism_paths_response_paths.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medicine_mechanism_paths_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicineMechanismPathsResponse {
  /// Returns a new [MedicineMechanismPathsResponse] instance.
  MedicineMechanismPathsResponse({required this.status, this.paths});

  @JsonKey(
    name: r'status',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        MedicineMechanismPathsResponseStatusEnum.unknownDefaultOpenApi,
  )
  final MedicineMechanismPathsResponseStatusEnum status;

  @JsonKey(name: r'paths', required: false, includeIfNull: false)
  final List<MedicineMechanismPathsResponsePaths>? paths;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineMechanismPathsResponse &&
          other.status == status &&
          other.paths == paths;

  @override
  int get hashCode => status.hashCode + paths.hashCode;

  factory MedicineMechanismPathsResponse.fromJson(Map<String, dynamic> json) =>
      _$MedicineMechanismPathsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MedicineMechanismPathsResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum MedicineMechanismPathsResponseStatusEnum {
  @JsonValue(r'ok')
  ok(r'ok'),
  @JsonValue(r'notConfigured')
  notConfigured(r'notConfigured'),
  @JsonValue(r'unavailable')
  unavailable(r'unavailable'),
  @JsonValue(r'timeout')
  timeout(r'timeout'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const MedicineMechanismPathsResponseStatusEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
