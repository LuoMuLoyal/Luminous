//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/medicine_sequence_response_targets.dart';
import 'package:lucent_api/src/model/medicine_sequence_response_drug.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medicine_sequence_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicineSequenceResponse {
  /// Returns a new [MedicineSequenceResponse] instance.
  MedicineSequenceResponse({
    required this.id,

    required this.source_,

    required this.drug,

    required this.targets,
  });

  /// Medicine id in the selected source.
  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  /// Knowledge source.
  @JsonKey(
    name: r'source',
    required: true,
    includeIfNull: false,
    unknownEnumValue: MedicineSequenceResponseSource_Enum.unknownDefaultOpenApi,
  )
  final MedicineSequenceResponseSource_Enum source_;

  /// Sequences of the drug itself (biologics have one per chain).
  @JsonKey(name: r'drug', required: true, includeIfNull: false)
  final List<MedicineSequenceResponseDrug> drug;

  /// Sequences of the drug targets, protein and coding gene.
  @JsonKey(name: r'targets', required: true, includeIfNull: false)
  final List<MedicineSequenceResponseTargets> targets;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineSequenceResponse &&
          other.id == id &&
          other.source_ == source_ &&
          other.drug == drug &&
          other.targets == targets;

  @override
  int get hashCode =>
      id.hashCode + source_.hashCode + drug.hashCode + targets.hashCode;

  factory MedicineSequenceResponse.fromJson(Map<String, dynamic> json) =>
      _$MedicineSequenceResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MedicineSequenceResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// Knowledge source.
enum MedicineSequenceResponseSource_Enum {
  @JsonValue(r'drugbank')
  drugbank(r'drugbank'),
  @JsonValue(r'cn')
  cn(r'cn'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const MedicineSequenceResponseSource_Enum(this.value);

  final String value;

  @override
  String toString() => value;
}
