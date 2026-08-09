//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'cn_medicine_detail_dto.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CnMedicineDetailDto {
  /// Returns a new [CnMedicineDetailDto] instance.
  CnMedicineDetailDto({
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
      other is CnMedicineDetailDto &&
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

  factory CnMedicineDetailDto.fromJson(Map<String, dynamic> json) =>
      _$CnMedicineDetailDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CnMedicineDetailDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
