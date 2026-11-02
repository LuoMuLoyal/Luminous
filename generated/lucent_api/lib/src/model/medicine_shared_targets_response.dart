//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/medicine_shared_targets_response_targets.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medicine_shared_targets_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicineSharedTargetsResponse {
  /// Returns a new [MedicineSharedTargetsResponse] instance.
  MedicineSharedTargetsResponse({required this.status, this.targets});

  @JsonKey(
    name: r'status',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        MedicineSharedTargetsResponseStatusEnum.unknownDefaultOpenApi,
  )
  final MedicineSharedTargetsResponseStatusEnum status;

  @JsonKey(name: r'targets', required: false, includeIfNull: false)
  final List<MedicineSharedTargetsResponseTargets>? targets;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineSharedTargetsResponse &&
          other.status == status &&
          other.targets == targets;

  @override
  int get hashCode => status.hashCode + targets.hashCode;

  factory MedicineSharedTargetsResponse.fromJson(Map<String, dynamic> json) =>
      _$MedicineSharedTargetsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MedicineSharedTargetsResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum MedicineSharedTargetsResponseStatusEnum {
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

  const MedicineSharedTargetsResponseStatusEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
