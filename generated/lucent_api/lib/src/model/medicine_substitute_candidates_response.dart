//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/medicine_substitute_candidates_response_candidates.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medicine_substitute_candidates_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicineSubstituteCandidatesResponse {
  /// Returns a new [MedicineSubstituteCandidatesResponse] instance.
  MedicineSubstituteCandidatesResponse({required this.status, this.candidates});

  /// Whether the graph could answer the query.
  @JsonKey(
    name: r'status',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        MedicineSubstituteCandidatesResponseStatusEnum.unknownDefaultOpenApi,
  )
  final MedicineSubstituteCandidatesResponseStatusEnum status;

  @JsonKey(name: r'candidates', required: false, includeIfNull: false)
  final List<MedicineSubstituteCandidatesResponseCandidates>? candidates;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineSubstituteCandidatesResponse &&
          other.status == status &&
          other.candidates == candidates;

  @override
  int get hashCode => status.hashCode + candidates.hashCode;

  factory MedicineSubstituteCandidatesResponse.fromJson(
    Map<String, dynamic> json,
  ) => _$MedicineSubstituteCandidatesResponseFromJson(json);

  Map<String, dynamic> toJson() =>
      _$MedicineSubstituteCandidatesResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// Whether the graph could answer the query.
enum MedicineSubstituteCandidatesResponseStatusEnum {
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

  const MedicineSubstituteCandidatesResponseStatusEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
