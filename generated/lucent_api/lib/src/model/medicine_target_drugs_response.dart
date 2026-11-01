//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/medicine_target_drugs_response_drugs.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medicine_target_drugs_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicineTargetDrugsResponse {
  /// Returns a new [MedicineTargetDrugsResponse] instance.
  MedicineTargetDrugsResponse({required this.status, this.drugs});

  @JsonKey(
    name: r'status',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        MedicineTargetDrugsResponseStatusEnum.unknownDefaultOpenApi,
  )
  final MedicineTargetDrugsResponseStatusEnum status;

  @JsonKey(name: r'drugs', required: false, includeIfNull: false)
  final List<MedicineTargetDrugsResponseDrugs>? drugs;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineTargetDrugsResponse &&
          other.status == status &&
          other.drugs == drugs;

  @override
  int get hashCode => status.hashCode + drugs.hashCode;

  factory MedicineTargetDrugsResponse.fromJson(Map<String, dynamic> json) =>
      _$MedicineTargetDrugsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MedicineTargetDrugsResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum MedicineTargetDrugsResponseStatusEnum {
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

  const MedicineTargetDrugsResponseStatusEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
