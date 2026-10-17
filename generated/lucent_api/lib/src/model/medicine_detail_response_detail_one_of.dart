//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/medicine_detail_response_external_identifiers.dart';
import 'package:lucent_api/src/model/medicine_detail_response_drug_interactions.dart';
import 'package:lucent_api/src/model/medicine_detail_response_external_links.dart';
import 'package:lucent_api/src/model/medicine_detail_response_sequence_summary.dart';
import 'package:lucent_api/src/model/medicine_detail_response_targets.dart';
import 'package:lucent_api/src/model/medicine_detail_response_structure.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medicine_detail_response_detail_one_of.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicineDetailResponseDetailOneOf {
  /// Returns a new [MedicineDetailResponseDetailOneOf] instance.
  MedicineDetailResponseDetailOneOf({
    required this.kind,

    required this.drugType,

    required this.state,

    required this.description,

    required this.indication,

    required this.mechanismOfAction,

    required this.pharmacodynamics,

    required this.toxicity,

    required this.metabolism,

    required this.absorption,

    required this.halfLife,

    required this.proteinBinding,

    required this.routeOfElimination,

    required this.volumeOfDistribution,

    required this.clearance,

    required this.groups,

    required this.categories,

    required this.atcCodes,

    required this.synonyms,

    required this.foodInteractions,

    required this.drugInteractions,

    required this.targets,

    required this.externalIdentifiers,

    required this.externalLinks,

    required this.sequenceSummary,

    required this.structure,
  });

  @JsonKey(
    name: r'kind',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        MedicineDetailResponseDetailOneOfKindEnum.unknownDefaultOpenApi,
  )
  final MedicineDetailResponseDetailOneOfKindEnum kind;

  /// Drug type (e.g. small molecule).
  @JsonKey(name: r'drugType', required: true, includeIfNull: true)
  final String? drugType;

  /// Physical state (e.g. solid).
  @JsonKey(name: r'state', required: true, includeIfNull: true)
  final String? state;

  /// Drug description.
  @JsonKey(name: r'description', required: true, includeIfNull: true)
  final String? description;

  /// Approved indications.
  @JsonKey(name: r'indication', required: true, includeIfNull: true)
  final String? indication;

  /// Mechanism of action.
  @JsonKey(name: r'mechanismOfAction', required: true, includeIfNull: true)
  final String? mechanismOfAction;

  /// Pharmacodynamics.
  @JsonKey(name: r'pharmacodynamics', required: true, includeIfNull: true)
  final String? pharmacodynamics;

  /// Toxicity summary.
  @JsonKey(name: r'toxicity', required: true, includeIfNull: true)
  final String? toxicity;

  /// Metabolism summary.
  @JsonKey(name: r'metabolism', required: true, includeIfNull: true)
  final String? metabolism;

  /// Absorption summary.
  @JsonKey(name: r'absorption', required: true, includeIfNull: true)
  final String? absorption;

  /// Half life.
  @JsonKey(name: r'halfLife', required: true, includeIfNull: true)
  final String? halfLife;

  /// Protein binding.
  @JsonKey(name: r'proteinBinding', required: true, includeIfNull: true)
  final String? proteinBinding;

  /// Route of elimination.
  @JsonKey(name: r'routeOfElimination', required: true, includeIfNull: true)
  final String? routeOfElimination;

  /// Volume of distribution.
  @JsonKey(name: r'volumeOfDistribution', required: true, includeIfNull: true)
  final String? volumeOfDistribution;

  /// Clearance.
  @JsonKey(name: r'clearance', required: true, includeIfNull: true)
  final String? clearance;

  /// Approval groups (e.g. approved, small molecule).
  @JsonKey(name: r'groups', required: true, includeIfNull: true)
  final List<String>? groups;

  /// ATC-like categories.
  @JsonKey(name: r'categories', required: true, includeIfNull: true)
  final List<String>? categories;

  /// ATC codes.
  @JsonKey(name: r'atcCodes', required: true, includeIfNull: true)
  final List<String>? atcCodes;

  /// Synonyms.
  @JsonKey(name: r'synonyms', required: true, includeIfNull: true)
  final List<String>? synonyms;

  /// Food interactions.
  @JsonKey(name: r'foodInteractions', required: true, includeIfNull: true)
  final List<String>? foodInteractions;

  /// DrugBank interaction entries used for interaction checking.
  @JsonKey(name: r'drugInteractions', required: true, includeIfNull: true)
  final List<MedicineDetailResponseDrugInteractions>? drugInteractions;

  /// Proteins/genes this drug acts on, with action labels.
  @JsonKey(name: r'targets', required: true, includeIfNull: true)
  final List<MedicineDetailResponseTargets>? targets;

  /// External cross-reference identifiers from the source.
  @JsonKey(name: r'externalIdentifiers', required: true, includeIfNull: true)
  final List<MedicineDetailResponseExternalIdentifiers>? externalIdentifiers;

  /// Outbound reference links from the source.
  @JsonKey(name: r'externalLinks', required: true, includeIfNull: true)
  final List<MedicineDetailResponseExternalLinks>? externalLinks;

  @JsonKey(name: r'sequenceSummary', required: true, includeIfNull: true)
  final MedicineDetailResponseSequenceSummary? sequenceSummary;

  @JsonKey(name: r'structure', required: true, includeIfNull: true)
  final MedicineDetailResponseStructure? structure;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineDetailResponseDetailOneOf &&
          other.kind == kind &&
          other.drugType == drugType &&
          other.state == state &&
          other.description == description &&
          other.indication == indication &&
          other.mechanismOfAction == mechanismOfAction &&
          other.pharmacodynamics == pharmacodynamics &&
          other.toxicity == toxicity &&
          other.metabolism == metabolism &&
          other.absorption == absorption &&
          other.halfLife == halfLife &&
          other.proteinBinding == proteinBinding &&
          other.routeOfElimination == routeOfElimination &&
          other.volumeOfDistribution == volumeOfDistribution &&
          other.clearance == clearance &&
          other.groups == groups &&
          other.categories == categories &&
          other.atcCodes == atcCodes &&
          other.synonyms == synonyms &&
          other.foodInteractions == foodInteractions &&
          other.drugInteractions == drugInteractions &&
          other.targets == targets &&
          other.externalIdentifiers == externalIdentifiers &&
          other.externalLinks == externalLinks &&
          other.sequenceSummary == sequenceSummary &&
          other.structure == structure;

  @override
  int get hashCode =>
      kind.hashCode +
      (drugType == null ? 0 : drugType.hashCode) +
      (state == null ? 0 : state.hashCode) +
      (description == null ? 0 : description.hashCode) +
      (indication == null ? 0 : indication.hashCode) +
      (mechanismOfAction == null ? 0 : mechanismOfAction.hashCode) +
      (pharmacodynamics == null ? 0 : pharmacodynamics.hashCode) +
      (toxicity == null ? 0 : toxicity.hashCode) +
      (metabolism == null ? 0 : metabolism.hashCode) +
      (absorption == null ? 0 : absorption.hashCode) +
      (halfLife == null ? 0 : halfLife.hashCode) +
      (proteinBinding == null ? 0 : proteinBinding.hashCode) +
      (routeOfElimination == null ? 0 : routeOfElimination.hashCode) +
      (volumeOfDistribution == null ? 0 : volumeOfDistribution.hashCode) +
      (clearance == null ? 0 : clearance.hashCode) +
      (groups == null ? 0 : groups.hashCode) +
      (categories == null ? 0 : categories.hashCode) +
      (atcCodes == null ? 0 : atcCodes.hashCode) +
      (synonyms == null ? 0 : synonyms.hashCode) +
      (foodInteractions == null ? 0 : foodInteractions.hashCode) +
      (drugInteractions == null ? 0 : drugInteractions.hashCode) +
      (targets == null ? 0 : targets.hashCode) +
      (externalIdentifiers == null ? 0 : externalIdentifiers.hashCode) +
      (externalLinks == null ? 0 : externalLinks.hashCode) +
      (sequenceSummary == null ? 0 : sequenceSummary.hashCode) +
      (structure == null ? 0 : structure.hashCode);

  factory MedicineDetailResponseDetailOneOf.fromJson(
    Map<String, dynamic> json,
  ) => _$MedicineDetailResponseDetailOneOfFromJson(json);

  Map<String, dynamic> toJson() =>
      _$MedicineDetailResponseDetailOneOfToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum MedicineDetailResponseDetailOneOfKindEnum {
  @JsonValue(r'drugbank')
  drugbank(r'drugbank'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const MedicineDetailResponseDetailOneOfKindEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
