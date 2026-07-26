//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_api/src/model/drugbank_drug_interaction_dto.dart';
import 'package:lucent_api/src/model/drugbank_medicine_detail_dto.dart';
import 'package:lucent_api/src/model/cn_medicine_detail_dto.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medicine_detail_data_dto_detail.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicineDetailDataDtoDetail {
  /// Returns a new [MedicineDetailDataDtoDetail] instance.
  MedicineDetailDataDtoDetail({
    required this.kind,

    this.drugType,

    this.state,

    this.description,

    this.indication,

    this.mechanismOfAction,

    this.pharmacodynamics,

    this.toxicity,

    this.metabolism,

    this.absorption,

    this.halfLife,

    this.proteinBinding,

    this.routeOfElimination,

    this.volumeOfDistribution,

    this.clearance,

    required this.groups,

    required this.categories,

    required this.atcCodes,

    required this.synonyms,

    required this.foodInteractions,

    this.drugInteractions,

    this.externalIdentifiers,

    this.externalLinks,

    this.approvalNumber,

    this.manufacturer,

    this.packageSpec,

    this.brandName,

    this.ingredients,

    this.properties,

    this.indications,

    this.dosage,

    this.adverseReactions,

    this.contraindications,

    this.precautions,

    this.pharmacologyToxicology,

    this.pharmacokinetics,

    this.overdose,

    this.storage,

    this.validityPeriod,

    this.barcode,

    this.nationalDrugCode,

    this.sourceUrl,

    this.imageUrl,
  });

  @JsonKey(name: r'kind', required: true, includeIfNull: false)
  final String kind;

  @JsonKey(name: r'drugType', required: false, includeIfNull: false)
  final String? drugType;

  @JsonKey(name: r'state', required: false, includeIfNull: false)
  final String? state;

  @JsonKey(name: r'description', required: false, includeIfNull: false)
  final String? description;

  @JsonKey(name: r'indication', required: false, includeIfNull: false)
  final String? indication;

  @JsonKey(name: r'mechanismOfAction', required: false, includeIfNull: false)
  final String? mechanismOfAction;

  @JsonKey(name: r'pharmacodynamics', required: false, includeIfNull: false)
  final String? pharmacodynamics;

  @JsonKey(name: r'toxicity', required: false, includeIfNull: false)
  final String? toxicity;

  @JsonKey(name: r'metabolism', required: false, includeIfNull: false)
  final String? metabolism;

  @JsonKey(name: r'absorption', required: false, includeIfNull: false)
  final String? absorption;

  @JsonKey(name: r'halfLife', required: false, includeIfNull: false)
  final String? halfLife;

  @JsonKey(name: r'proteinBinding', required: false, includeIfNull: false)
  final String? proteinBinding;

  @JsonKey(name: r'routeOfElimination', required: false, includeIfNull: false)
  final String? routeOfElimination;

  @JsonKey(name: r'volumeOfDistribution', required: false, includeIfNull: false)
  final String? volumeOfDistribution;

  @JsonKey(name: r'clearance', required: false, includeIfNull: false)
  final String? clearance;

  @JsonKey(name: r'groups', required: true, includeIfNull: false)
  final List<String> groups;

  @JsonKey(name: r'categories', required: true, includeIfNull: false)
  final List<String> categories;

  @JsonKey(name: r'atcCodes', required: true, includeIfNull: false)
  final List<String> atcCodes;

  @JsonKey(name: r'synonyms', required: true, includeIfNull: false)
  final List<String> synonyms;

  @JsonKey(name: r'foodInteractions', required: true, includeIfNull: false)
  final List<String> foodInteractions;

  /// DrugBank interaction entries used for interaction checking.
  @JsonKey(name: r'drugInteractions', required: false, includeIfNull: false)
  final List<DrugbankDrugInteractionDto>? drugInteractions;

  /// Raw source external identifier payload.
  @JsonKey(name: r'externalIdentifiers', required: false, includeIfNull: false)
  final Map<String, Object>? externalIdentifiers;

  /// Raw source external link payload.
  @JsonKey(name: r'externalLinks', required: false, includeIfNull: false)
  final Map<String, Object>? externalLinks;

  @JsonKey(name: r'approvalNumber', required: false, includeIfNull: false)
  final String? approvalNumber;

  @JsonKey(name: r'manufacturer', required: false, includeIfNull: false)
  final String? manufacturer;

  @JsonKey(name: r'packageSpec', required: false, includeIfNull: false)
  final String? packageSpec;

  @JsonKey(name: r'brandName', required: false, includeIfNull: false)
  final String? brandName;

  @JsonKey(name: r'ingredients', required: false, includeIfNull: false)
  final String? ingredients;

  @JsonKey(name: r'properties', required: false, includeIfNull: false)
  final String? properties;

  @JsonKey(name: r'indications', required: false, includeIfNull: false)
  final String? indications;

  @JsonKey(name: r'dosage', required: false, includeIfNull: false)
  final String? dosage;

  @JsonKey(name: r'adverseReactions', required: false, includeIfNull: false)
  final String? adverseReactions;

  @JsonKey(name: r'contraindications', required: false, includeIfNull: false)
  final String? contraindications;

  @JsonKey(name: r'precautions', required: false, includeIfNull: false)
  final String? precautions;

  @JsonKey(
    name: r'pharmacologyToxicology',
    required: false,
    includeIfNull: false,
  )
  final String? pharmacologyToxicology;

  @JsonKey(name: r'pharmacokinetics', required: false, includeIfNull: false)
  final String? pharmacokinetics;

  @JsonKey(name: r'overdose', required: false, includeIfNull: false)
  final String? overdose;

  @JsonKey(name: r'storage', required: false, includeIfNull: false)
  final String? storage;

  @JsonKey(name: r'validityPeriod', required: false, includeIfNull: false)
  final String? validityPeriod;

  @JsonKey(name: r'barcode', required: false, includeIfNull: false)
  final String? barcode;

  @JsonKey(name: r'nationalDrugCode', required: false, includeIfNull: false)
  final String? nationalDrugCode;

  @JsonKey(name: r'sourceUrl', required: false, includeIfNull: false)
  final String? sourceUrl;

  @JsonKey(name: r'imageUrl', required: false, includeIfNull: false)
  final String? imageUrl;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineDetailDataDtoDetail &&
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
      groups.hashCode +
      categories.hashCode +
      atcCodes.hashCode +
      synonyms.hashCode +
      foodInteractions.hashCode +
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

  factory MedicineDetailDataDtoDetail.fromJson(Map<String, dynamic> json) =>
      _$MedicineDetailDataDtoDetailFromJson(json);

  Map<String, dynamic> toJson() => _$MedicineDetailDataDtoDetailToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
