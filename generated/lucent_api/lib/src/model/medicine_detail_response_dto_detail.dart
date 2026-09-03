//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/medicine_detail_response_dto_detail_one_of_drug_interactions_inner.dart';
import 'package:lucent_api/src/model/medicine_detail_response_dto_detail_one_of.dart';
import 'package:lucent_api/src/model/medicine_detail_response_dto_detail_one_of1.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medicine_detail_response_dto_detail.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicineDetailResponseDtoDetail {
  /// Returns a new [MedicineDetailResponseDtoDetail] instance.
  MedicineDetailResponseDtoDetail({
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

    required this.approvalNumber,

    required this.manufacturer,

    required this.packageSpec,

    required this.brandName,

    required this.ingredients,

    required this.properties,

    required this.indications,

    required this.dosage,

    required this.adverseReactions,

    required this.contraindications,

    required this.precautions,

    required this.pharmacologyToxicology,

    required this.pharmacokinetics,

    required this.overdose,

    required this.storage,

    required this.validityPeriod,

    required this.barcode,

    required this.nationalDrugCode,

    required this.sourceUrl,

    required this.imageUrl,
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
  final List<MedicineDetailResponseDtoDetailOneOfDrugInteractionsInner>?
  drugInteractions;

  @JsonKey(name: r'externalIdentifiers', required: true, includeIfNull: true)
  final Object? externalIdentifiers;

  @JsonKey(name: r'externalLinks', required: true, includeIfNull: true)
  final Object? externalLinks;

  @JsonKey(name: r'approvalNumber', required: true, includeIfNull: true)
  final String? approvalNumber;

  @JsonKey(name: r'manufacturer', required: true, includeIfNull: true)
  final String? manufacturer;

  @JsonKey(name: r'packageSpec', required: true, includeIfNull: true)
  final String? packageSpec;

  @JsonKey(name: r'brandName', required: true, includeIfNull: true)
  final String? brandName;

  @JsonKey(name: r'ingredients', required: true, includeIfNull: true)
  final String? ingredients;

  @JsonKey(name: r'properties', required: true, includeIfNull: true)
  final String? properties;

  @JsonKey(name: r'indications', required: true, includeIfNull: true)
  final String? indications;

  @JsonKey(name: r'dosage', required: true, includeIfNull: true)
  final String? dosage;

  @JsonKey(name: r'adverseReactions', required: true, includeIfNull: true)
  final String? adverseReactions;

  @JsonKey(name: r'contraindications', required: true, includeIfNull: true)
  final String? contraindications;

  @JsonKey(name: r'precautions', required: true, includeIfNull: true)
  final String? precautions;

  @JsonKey(name: r'pharmacologyToxicology', required: true, includeIfNull: true)
  final String? pharmacologyToxicology;

  @JsonKey(name: r'pharmacokinetics', required: true, includeIfNull: true)
  final String? pharmacokinetics;

  @JsonKey(name: r'overdose', required: true, includeIfNull: true)
  final String? overdose;

  @JsonKey(name: r'storage', required: true, includeIfNull: true)
  final String? storage;

  @JsonKey(name: r'validityPeriod', required: true, includeIfNull: true)
  final String? validityPeriod;

  @JsonKey(name: r'barcode', required: true, includeIfNull: true)
  final String? barcode;

  @JsonKey(name: r'nationalDrugCode', required: true, includeIfNull: true)
  final String? nationalDrugCode;

  @JsonKey(name: r'sourceUrl', required: true, includeIfNull: true)
  final String? sourceUrl;

  @JsonKey(name: r'imageUrl', required: true, includeIfNull: true)
  final String? imageUrl;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineDetailResponseDtoDetail &&
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
          other.externalLinks == externalLinks &&
          other.approvalNumber == approvalNumber &&
          other.manufacturer == manufacturer &&
          other.packageSpec == packageSpec &&
          other.brandName == brandName &&
          other.ingredients == ingredients &&
          other.properties == properties &&
          other.indications == indications &&
          other.dosage == dosage &&
          other.adverseReactions == adverseReactions &&
          other.contraindications == contraindications &&
          other.precautions == precautions &&
          other.pharmacologyToxicology == pharmacologyToxicology &&
          other.pharmacokinetics == pharmacokinetics &&
          other.overdose == overdose &&
          other.storage == storage &&
          other.validityPeriod == validityPeriod &&
          other.barcode == barcode &&
          other.nationalDrugCode == nationalDrugCode &&
          other.sourceUrl == sourceUrl &&
          other.imageUrl == imageUrl;

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
      (externalLinks == null ? 0 : externalLinks.hashCode) +
      (approvalNumber == null ? 0 : approvalNumber.hashCode) +
      (manufacturer == null ? 0 : manufacturer.hashCode) +
      (packageSpec == null ? 0 : packageSpec.hashCode) +
      (brandName == null ? 0 : brandName.hashCode) +
      (ingredients == null ? 0 : ingredients.hashCode) +
      (properties == null ? 0 : properties.hashCode) +
      (indications == null ? 0 : indications.hashCode) +
      (dosage == null ? 0 : dosage.hashCode) +
      (adverseReactions == null ? 0 : adverseReactions.hashCode) +
      (contraindications == null ? 0 : contraindications.hashCode) +
      (precautions == null ? 0 : precautions.hashCode) +
      (pharmacologyToxicology == null ? 0 : pharmacologyToxicology.hashCode) +
      (pharmacokinetics == null ? 0 : pharmacokinetics.hashCode) +
      (overdose == null ? 0 : overdose.hashCode) +
      (storage == null ? 0 : storage.hashCode) +
      (validityPeriod == null ? 0 : validityPeriod.hashCode) +
      (barcode == null ? 0 : barcode.hashCode) +
      (nationalDrugCode == null ? 0 : nationalDrugCode.hashCode) +
      (sourceUrl == null ? 0 : sourceUrl.hashCode) +
      (imageUrl == null ? 0 : imageUrl.hashCode);

  factory MedicineDetailResponseDtoDetail.fromJson(Map<String, dynamic> json) =>
      _$MedicineDetailResponseDtoDetailFromJson(json);

  Map<String, dynamic> toJson() =>
      _$MedicineDetailResponseDtoDetailToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
