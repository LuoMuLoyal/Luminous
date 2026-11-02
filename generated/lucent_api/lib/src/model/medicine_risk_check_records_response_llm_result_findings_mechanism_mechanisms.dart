//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medicine_risk_check_records_response_llm_result_findings_mechanism_mechanisms.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicineRiskCheckRecordsResponseLlmResultFindingsMechanismMechanisms {
  /// Returns a new [MedicineRiskCheckRecordsResponseLlmResultFindingsMechanismMechanisms] instance.
  MedicineRiskCheckRecordsResponseLlmResultFindingsMechanismMechanisms({
    required this.kind,

    required this.geneSymbol,

    required this.entityName,

    required this.relation,
  });

  /// Pathway kind the evidence comes from.
  @JsonKey(
    name: r'kind',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        MedicineRiskCheckRecordsResponseLlmResultFindingsMechanismMechanismsKindEnum
            .unknownDefaultOpenApi,
  )
  final MedicineRiskCheckRecordsResponseLlmResultFindingsMechanismMechanismsKindEnum
  kind;

  /// Gene symbol of the enzyme/target/transporter, e.g. CYP2C9.
  @JsonKey(name: r'geneSymbol', required: true, includeIfNull: false)
  final String geneSymbol;

  /// Display name of that entity.
  @JsonKey(name: r'entityName', required: true, includeIfNull: false)
  final String entityName;

  /// What the primary medicine does to it (INHIBITS/INDUCES/ACTS_ON).
  @JsonKey(name: r'relation', required: true, includeIfNull: false)
  final String relation;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineRiskCheckRecordsResponseLlmResultFindingsMechanismMechanisms &&
          other.kind == kind &&
          other.geneSymbol == geneSymbol &&
          other.entityName == entityName &&
          other.relation == relation;

  @override
  int get hashCode =>
      kind.hashCode +
      geneSymbol.hashCode +
      entityName.hashCode +
      relation.hashCode;

  factory MedicineRiskCheckRecordsResponseLlmResultFindingsMechanismMechanisms.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$MedicineRiskCheckRecordsResponseLlmResultFindingsMechanismMechanismsFromJson(
        json,
      );

  Map<String, dynamic> toJson() =>
      _$MedicineRiskCheckRecordsResponseLlmResultFindingsMechanismMechanismsToJson(
        this,
      );

  @override
  String toString() {
    return toJson().toString();
  }
}

/// Pathway kind the evidence comes from.
enum MedicineRiskCheckRecordsResponseLlmResultFindingsMechanismMechanismsKindEnum {
  @JsonValue(r'enzyme')
  enzyme(r'enzyme'),
  @JsonValue(r'target')
  target(r'target'),
  @JsonValue(r'transporter')
  transporter(r'transporter'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const MedicineRiskCheckRecordsResponseLlmResultFindingsMechanismMechanismsKindEnum(
    this.value,
  );

  final String value;

  @override
  String toString() => value;
}
