//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/medicine_detail_response_drug_interactions.dart';
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

    required this.externalIdentifiers,

    required this.externalLinks,
  });

  @JsonKey(name: r'kind', required: true, includeIfNull: false)
  final String kind;

  @JsonKey(name: r'drugType', required: true, includeIfNull: true)
  final String? drugType;

  @JsonKey(name: r'state', required: true, includeIfNull: true)
  final String? state;

  @JsonKey(name: r'description', required: true, includeIfNull: true)
  final String? description;

  @JsonKey(name: r'indication', required: true, includeIfNull: true)
  final String? indication;

  @JsonKey(name: r'mechanismOfAction', required: true, includeIfNull: true)
  final String? mechanismOfAction;

  @JsonKey(name: r'pharmacodynamics', required: true, includeIfNull: true)
  final String? pharmacodynamics;

  @JsonKey(name: r'toxicity', required: true, includeIfNull: true)
  final String? toxicity;

  @JsonKey(name: r'metabolism', required: true, includeIfNull: true)
  final String? metabolism;

  @JsonKey(name: r'absorption', required: true, includeIfNull: true)
  final String? absorption;

  @JsonKey(name: r'halfLife', required: true, includeIfNull: true)
  final String? halfLife;

  @JsonKey(name: r'proteinBinding', required: true, includeIfNull: true)
  final String? proteinBinding;

  @JsonKey(name: r'routeOfElimination', required: true, includeIfNull: true)
  final String? routeOfElimination;

  @JsonKey(name: r'volumeOfDistribution', required: true, includeIfNull: true)
  final String? volumeOfDistribution;

  @JsonKey(name: r'clearance', required: true, includeIfNull: true)
  final String? clearance;

  @JsonKey(name: r'groups', required: true, includeIfNull: true)
  final List<String>? groups;

  @JsonKey(name: r'categories', required: true, includeIfNull: true)
  final List<String>? categories;

  @JsonKey(name: r'atcCodes', required: true, includeIfNull: true)
  final List<String>? atcCodes;

  @JsonKey(name: r'synonyms', required: true, includeIfNull: true)
  final List<String>? synonyms;

  @JsonKey(name: r'foodInteractions', required: true, includeIfNull: true)
  final List<String>? foodInteractions;

  @JsonKey(name: r'drugInteractions', required: true, includeIfNull: true)
  final List<MedicineDetailResponseDrugInteractions>? drugInteractions;

  @JsonKey(name: r'externalIdentifiers', required: true, includeIfNull: true)
  final Object? externalIdentifiers;

  @JsonKey(name: r'externalLinks', required: true, includeIfNull: true)
  final Object? externalLinks;

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
          other.externalIdentifiers == externalIdentifiers &&
          other.externalLinks == externalLinks;

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
      (externalIdentifiers == null ? 0 : externalIdentifiers.hashCode) +
      (externalLinks == null ? 0 : externalLinks.hashCode);

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
