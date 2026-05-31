//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'cn_medicine_detail_dto.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CnMedicineDetailDto {
  /// Returns a new [CnMedicineDetailDto] instance.
  CnMedicineDetailDto({

    required  this.kind,

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

     this.pediatricUse,

     this.geriatricUse,

     this.pregnancyLactation,

     this.pharmacologyToxicology,

     this.drugInteractions,

     this.pharmacokinetics,

     this.overdose,

     this.storage,

     this.validityPeriod,

     this.barcode,

     this.nationalDrugCode,

     this.sourceUrl,

     this.imageUrl,
  });

  @JsonKey(
    
    name: r'kind',
    required: true,
    includeIfNull: false,
  )


  final String kind;



  @JsonKey(
    
    name: r'approvalNumber',
    required: false,
    includeIfNull: false,
  )


  final Object? approvalNumber;



  @JsonKey(
    
    name: r'manufacturer',
    required: false,
    includeIfNull: false,
  )


  final Object? manufacturer;



  @JsonKey(
    
    name: r'packageSpec',
    required: false,
    includeIfNull: false,
  )


  final Object? packageSpec;



  @JsonKey(
    
    name: r'brandName',
    required: false,
    includeIfNull: false,
  )


  final Object? brandName;



  @JsonKey(
    
    name: r'ingredients',
    required: false,
    includeIfNull: false,
  )


  final Object? ingredients;



  @JsonKey(
    
    name: r'properties',
    required: false,
    includeIfNull: false,
  )


  final Object? properties;



  @JsonKey(
    
    name: r'indications',
    required: false,
    includeIfNull: false,
  )


  final Object? indications;



  @JsonKey(
    
    name: r'dosage',
    required: false,
    includeIfNull: false,
  )


  final Object? dosage;



  @JsonKey(
    
    name: r'adverseReactions',
    required: false,
    includeIfNull: false,
  )


  final Object? adverseReactions;



  @JsonKey(
    
    name: r'contraindications',
    required: false,
    includeIfNull: false,
  )


  final Object? contraindications;



  @JsonKey(
    
    name: r'precautions',
    required: false,
    includeIfNull: false,
  )


  final Object? precautions;



  @JsonKey(
    
    name: r'pediatricUse',
    required: false,
    includeIfNull: false,
  )


  final Object? pediatricUse;



  @JsonKey(
    
    name: r'geriatricUse',
    required: false,
    includeIfNull: false,
  )


  final Object? geriatricUse;



  @JsonKey(
    
    name: r'pregnancyLactation',
    required: false,
    includeIfNull: false,
  )


  final Object? pregnancyLactation;



  @JsonKey(
    
    name: r'pharmacologyToxicology',
    required: false,
    includeIfNull: false,
  )


  final Object? pharmacologyToxicology;



  @JsonKey(
    
    name: r'drugInteractions',
    required: false,
    includeIfNull: false,
  )


  final Object? drugInteractions;



  @JsonKey(
    
    name: r'pharmacokinetics',
    required: false,
    includeIfNull: false,
  )


  final Object? pharmacokinetics;



  @JsonKey(
    
    name: r'overdose',
    required: false,
    includeIfNull: false,
  )


  final Object? overdose;



  @JsonKey(
    
    name: r'storage',
    required: false,
    includeIfNull: false,
  )


  final Object? storage;



  @JsonKey(
    
    name: r'validityPeriod',
    required: false,
    includeIfNull: false,
  )


  final Object? validityPeriod;



  @JsonKey(
    
    name: r'barcode',
    required: false,
    includeIfNull: false,
  )


  final Object? barcode;



  @JsonKey(
    
    name: r'nationalDrugCode',
    required: false,
    includeIfNull: false,
  )


  final Object? nationalDrugCode;



  @JsonKey(
    
    name: r'sourceUrl',
    required: false,
    includeIfNull: false,
  )


  final Object? sourceUrl;



  @JsonKey(
    
    name: r'imageUrl',
    required: false,
    includeIfNull: false,
  )


  final Object? imageUrl;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CnMedicineDetailDto &&
      other.kind == kind &&
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
      other.pediatricUse == pediatricUse &&
      other.geriatricUse == geriatricUse &&
      other.pregnancyLactation == pregnancyLactation &&
      other.pharmacologyToxicology == pharmacologyToxicology &&
      other.drugInteractions == drugInteractions &&
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
        (pediatricUse == null ? 0 : pediatricUse.hashCode) +
        (geriatricUse == null ? 0 : geriatricUse.hashCode) +
        (pregnancyLactation == null ? 0 : pregnancyLactation.hashCode) +
        (pharmacologyToxicology == null ? 0 : pharmacologyToxicology.hashCode) +
        (drugInteractions == null ? 0 : drugInteractions.hashCode) +
        (pharmacokinetics == null ? 0 : pharmacokinetics.hashCode) +
        (overdose == null ? 0 : overdose.hashCode) +
        (storage == null ? 0 : storage.hashCode) +
        (validityPeriod == null ? 0 : validityPeriod.hashCode) +
        (barcode == null ? 0 : barcode.hashCode) +
        (nationalDrugCode == null ? 0 : nationalDrugCode.hashCode) +
        (sourceUrl == null ? 0 : sourceUrl.hashCode) +
        (imageUrl == null ? 0 : imageUrl.hashCode);

  factory CnMedicineDetailDto.fromJson(Map<String, dynamic> json) => _$CnMedicineDetailDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CnMedicineDetailDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

