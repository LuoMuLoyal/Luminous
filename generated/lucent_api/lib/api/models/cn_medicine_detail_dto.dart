// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'cn_medicine_detail_dto.g.dart';

@JsonSerializable()
class CnMedicineDetailDto {
  const CnMedicineDetailDto({
    required this.kind,
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

  factory CnMedicineDetailDto.fromJson(Map<String, Object?> json) =>
      _$CnMedicineDetailDtoFromJson(json);

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

  Map<String, Object?> toJson() => _$CnMedicineDetailDtoToJson(this);
}
