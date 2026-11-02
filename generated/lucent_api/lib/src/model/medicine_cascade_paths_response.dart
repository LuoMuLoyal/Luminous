//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/medicine_cascade_paths_response_cascades.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medicine_cascade_paths_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicineCascadePathsResponse {
  /// Returns a new [MedicineCascadePathsResponse] instance.
  MedicineCascadePathsResponse({required this.status, this.cascades});

  @JsonKey(
    name: r'status',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        MedicineCascadePathsResponseStatusEnum.unknownDefaultOpenApi,
  )
  final MedicineCascadePathsResponseStatusEnum status;

  @JsonKey(name: r'cascades', required: false, includeIfNull: false)
  final List<MedicineCascadePathsResponseCascades>? cascades;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineCascadePathsResponse &&
          other.status == status &&
          other.cascades == cascades;

  @override
  int get hashCode => status.hashCode + cascades.hashCode;

  factory MedicineCascadePathsResponse.fromJson(Map<String, dynamic> json) =>
      _$MedicineCascadePathsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MedicineCascadePathsResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum MedicineCascadePathsResponseStatusEnum {
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

  const MedicineCascadePathsResponseStatusEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
