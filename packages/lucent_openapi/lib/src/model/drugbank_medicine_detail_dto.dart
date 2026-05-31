//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'drugbank_medicine_detail_dto.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DrugbankMedicineDetailDto {
  /// Returns a new [DrugbankMedicineDetailDto] instance.
  DrugbankMedicineDetailDto({

    required  this.kind,

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

    required  this.groups,

    required  this.categories,

    required  this.atcCodes,

    required  this.synonyms,

    required  this.foodInteractions,

     this.drugInteractions,

     this.externalIdentifiers,

     this.externalLinks,
  });

  @JsonKey(
    
    name: r'kind',
    required: true,
    includeIfNull: false,
  )


  final String kind;



  @JsonKey(
    
    name: r'drugType',
    required: false,
    includeIfNull: false,
  )


  final Object? drugType;



  @JsonKey(
    
    name: r'state',
    required: false,
    includeIfNull: false,
  )


  final Object? state;



  @JsonKey(
    
    name: r'description',
    required: false,
    includeIfNull: false,
  )


  final Object? description;



  @JsonKey(
    
    name: r'indication',
    required: false,
    includeIfNull: false,
  )


  final Object? indication;



  @JsonKey(
    
    name: r'mechanismOfAction',
    required: false,
    includeIfNull: false,
  )


  final Object? mechanismOfAction;



  @JsonKey(
    
    name: r'pharmacodynamics',
    required: false,
    includeIfNull: false,
  )


  final Object? pharmacodynamics;



  @JsonKey(
    
    name: r'toxicity',
    required: false,
    includeIfNull: false,
  )


  final Object? toxicity;



  @JsonKey(
    
    name: r'metabolism',
    required: false,
    includeIfNull: false,
  )


  final Object? metabolism;



  @JsonKey(
    
    name: r'absorption',
    required: false,
    includeIfNull: false,
  )


  final Object? absorption;



  @JsonKey(
    
    name: r'halfLife',
    required: false,
    includeIfNull: false,
  )


  final Object? halfLife;



  @JsonKey(
    
    name: r'proteinBinding',
    required: false,
    includeIfNull: false,
  )


  final Object? proteinBinding;



  @JsonKey(
    
    name: r'routeOfElimination',
    required: false,
    includeIfNull: false,
  )


  final Object? routeOfElimination;



  @JsonKey(
    
    name: r'volumeOfDistribution',
    required: false,
    includeIfNull: false,
  )


  final Object? volumeOfDistribution;



  @JsonKey(
    
    name: r'clearance',
    required: false,
    includeIfNull: false,
  )


  final Object? clearance;



  @JsonKey(
    
    name: r'groups',
    required: true,
    includeIfNull: false,
  )


  final List<String> groups;



  @JsonKey(
    
    name: r'categories',
    required: true,
    includeIfNull: false,
  )


  final List<String> categories;



  @JsonKey(
    
    name: r'atcCodes',
    required: true,
    includeIfNull: false,
  )


  final List<String> atcCodes;



  @JsonKey(
    
    name: r'synonyms',
    required: true,
    includeIfNull: false,
  )


  final List<String> synonyms;



  @JsonKey(
    
    name: r'foodInteractions',
    required: true,
    includeIfNull: false,
  )


  final List<String> foodInteractions;



      /// Raw source interaction payload.
  @JsonKey(
    
    name: r'drugInteractions',
    required: false,
    includeIfNull: false,
  )


  final Map<String, Object>? drugInteractions;



      /// Raw source external identifier payload.
  @JsonKey(
    
    name: r'externalIdentifiers',
    required: false,
    includeIfNull: false,
  )


  final Map<String, Object>? externalIdentifiers;



      /// Raw source external link payload.
  @JsonKey(
    
    name: r'externalLinks',
    required: false,
    includeIfNull: false,
  )


  final Map<String, Object>? externalLinks;





    @override
    bool operator ==(Object other) => identical(this, other) || other is DrugbankMedicineDetailDto &&
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
        groups.hashCode +
        categories.hashCode +
        atcCodes.hashCode +
        synonyms.hashCode +
        foodInteractions.hashCode +
        (drugInteractions == null ? 0 : drugInteractions.hashCode) +
        (externalIdentifiers == null ? 0 : externalIdentifiers.hashCode) +
        (externalLinks == null ? 0 : externalLinks.hashCode);

  factory DrugbankMedicineDetailDto.fromJson(Map<String, dynamic> json) => _$DrugbankMedicineDetailDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DrugbankMedicineDetailDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

