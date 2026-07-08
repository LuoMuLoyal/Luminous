// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'drugbank_medicine_detail_dto.g.dart';

@JsonSerializable()
class DrugbankMedicineDetailDto {
  const DrugbankMedicineDetailDto({
    required this.kind,
    required this.groups,
    required this.categories,
    required this.atcCodes,
    required this.synonyms,
    required this.foodInteractions,
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
    this.drugInteractions,
    this.externalIdentifiers,
    this.externalLinks,
  });

  factory DrugbankMedicineDetailDto.fromJson(Map<String, Object?> json) =>
      _$DrugbankMedicineDetailDtoFromJson(json);

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

  /// Raw source interaction payload.
  final dynamic drugInteractions;

  /// Raw source external identifier payload.
  final dynamic externalIdentifiers;

  /// Raw source external link payload.
  final dynamic externalLinks;

  Map<String, Object?> toJson() => _$DrugbankMedicineDetailDtoToJson(this);
}
