//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/medicine_enzyme_duels_response_duels.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medicine_enzyme_duels_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicineEnzymeDuelsResponse {
  /// Returns a new [MedicineEnzymeDuelsResponse] instance.
  MedicineEnzymeDuelsResponse({required this.status, this.duels});

  @JsonKey(
    name: r'status',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        MedicineEnzymeDuelsResponseStatusEnum.unknownDefaultOpenApi,
  )
  final MedicineEnzymeDuelsResponseStatusEnum status;

  @JsonKey(name: r'duels', required: false, includeIfNull: false)
  final List<MedicineEnzymeDuelsResponseDuels>? duels;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineEnzymeDuelsResponse &&
          other.status == status &&
          other.duels == duels;

  @override
  int get hashCode => status.hashCode + duels.hashCode;

  factory MedicineEnzymeDuelsResponse.fromJson(Map<String, dynamic> json) =>
      _$MedicineEnzymeDuelsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MedicineEnzymeDuelsResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum MedicineEnzymeDuelsResponseStatusEnum {
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

  const MedicineEnzymeDuelsResponseStatusEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
