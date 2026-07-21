// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'medicine_detail_data_dto_detail_detail.g.dart';

class MedicineDetailDataDtoDetailDetail {
  final Map<String, dynamic> _json;

  const MedicineDetailDataDtoDetailDetail(this._json);

  factory MedicineDetailDataDtoDetailDetail.fromJson(
    Map<String, dynamic> json,
  ) => MedicineDetailDataDtoDetailDetail(json);

  Map<String, dynamic> toJson() => _json;

  MedicineDetailDataDtoDetailDetailDrugbankMedicineDetailDto
  toDrugbankMedicineDetailDto() =>
      MedicineDetailDataDtoDetailDetailDrugbankMedicineDetailDto.fromJson(
        _json,
      );
  MedicineDetailDataDtoDetailDetailCnMedicineDetailDto
  toCnMedicineDetailDto() =>
      MedicineDetailDataDtoDetailDetailCnMedicineDetailDto.fromJson(_json);
}

@JsonSerializable()
class MedicineDetailDataDtoDetailDetailDrugbankMedicineDetailDto {
  final String kind;
  final String? drugType;
  final String? state;
  final String? description;
  final String? indication;
  final String? mechanismOfAction;
  final String? pharmacodynamics;
  final String? toxicity;
  final String? metabolism;
  final String? absorption;
  final String? halfLife;
  final String? proteinBinding;
  final String? routeOfElimination;
  final String? volumeOfDistribution;
  final String? clearance;
  final List<String> groups;
  final List<String> categories;
  final List<String> atcCodes;
  final List<String> synonyms;
  final List<String> foodInteractions;
  final dynamic drugInteractions;
  final dynamic externalIdentifiers;
  final dynamic externalLinks;

  const MedicineDetailDataDtoDetailDetailDrugbankMedicineDetailDto({
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

  factory MedicineDetailDataDtoDetailDetailDrugbankMedicineDetailDto.fromJson(
    Map<String, dynamic> json,
  ) => _$MedicineDetailDataDtoDetailDetailDrugbankMedicineDetailDtoFromJson(
    json,
  );

  Map<String, dynamic> toJson() =>
      _$MedicineDetailDataDtoDetailDetailDrugbankMedicineDetailDtoToJson(this);
}

@JsonSerializable()
class MedicineDetailDataDtoDetailDetailCnMedicineDetailDto {
  final String kind;
  final String? approvalNumber;
  final String? manufacturer;
  final String? packageSpec;
  final String? brandName;
  final String? ingredients;
  final String? properties;
  final String? indications;
  final String? dosage;
  final String? adverseReactions;
  final String? contraindications;
  final String? precautions;
  final String? pharmacologyToxicology;
  final String? drugInteractions;
  final String? pharmacokinetics;
  final String? overdose;
  final String? storage;
  final String? validityPeriod;
  final String? barcode;
  final String? nationalDrugCode;
  final String? sourceUrl;
  final String? imageUrl;

  const MedicineDetailDataDtoDetailDetailCnMedicineDetailDto({
    required this.kind,
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
    required this.drugInteractions,
    required this.pharmacokinetics,
    required this.overdose,
    required this.storage,
    required this.validityPeriod,
    required this.barcode,
    required this.nationalDrugCode,
    required this.sourceUrl,
    required this.imageUrl,
  });

  factory MedicineDetailDataDtoDetailDetailCnMedicineDetailDto.fromJson(
    Map<String, dynamic> json,
  ) => _$MedicineDetailDataDtoDetailDetailCnMedicineDetailDtoFromJson(json);

  Map<String, dynamic> toJson() =>
      _$MedicineDetailDataDtoDetailDetailCnMedicineDetailDtoToJson(this);
}
