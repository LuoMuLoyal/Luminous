//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medicine_detail_response_detail_one_of1.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicineDetailResponseDetailOneOf1 {
  /// Returns a new [MedicineDetailResponseDetailOneOf1] instance.
  MedicineDetailResponseDetailOneOf1({
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

    required this.pharmacokinetics,

    required this.overdose,

    required this.storage,

    required this.validityPeriod,

    required this.barcode,

    required this.nationalDrugCode,

    required this.sourceUrl,

    required this.imageUrl,
  });

  @JsonKey(
    name: r'kind',
    required: true,
    includeIfNull: false,
    unknownEnumValue:
        MedicineDetailResponseDetailOneOf1KindEnum.unknownDefaultOpenApi,
  )
  final MedicineDetailResponseDetailOneOf1KindEnum kind;

  /// Approval number (国药准字).
  @JsonKey(name: r'approvalNumber', required: true, includeIfNull: true)
  final String? approvalNumber;

  /// Manufacturer.
  @JsonKey(name: r'manufacturer', required: true, includeIfNull: true)
  final String? manufacturer;

  /// Package specification.
  @JsonKey(name: r'packageSpec', required: true, includeIfNull: true)
  final String? packageSpec;

  /// Brand name.
  @JsonKey(name: r'brandName', required: true, includeIfNull: true)
  final String? brandName;

  /// Ingredients.
  @JsonKey(name: r'ingredients', required: true, includeIfNull: true)
  final String? ingredients;

  /// Properties.
  @JsonKey(name: r'properties', required: true, includeIfNull: true)
  final String? properties;

  /// Indications.
  @JsonKey(name: r'indications', required: true, includeIfNull: true)
  final String? indications;

  /// Dosage.
  @JsonKey(name: r'dosage', required: true, includeIfNull: true)
  final String? dosage;

  /// Adverse reactions.
  @JsonKey(name: r'adverseReactions', required: true, includeIfNull: true)
  final String? adverseReactions;

  /// Contraindications.
  @JsonKey(name: r'contraindications', required: true, includeIfNull: true)
  final String? contraindications;

  /// Precautions.
  @JsonKey(name: r'precautions', required: true, includeIfNull: true)
  final String? precautions;

  /// Pharmacology / toxicology.
  @JsonKey(name: r'pharmacologyToxicology', required: true, includeIfNull: true)
  final String? pharmacologyToxicology;

  /// Pharmacokinetics.
  @JsonKey(name: r'pharmacokinetics', required: true, includeIfNull: true)
  final String? pharmacokinetics;

  /// Overdose handling.
  @JsonKey(name: r'overdose', required: true, includeIfNull: true)
  final String? overdose;

  /// Storage conditions.
  @JsonKey(name: r'storage', required: true, includeIfNull: true)
  final String? storage;

  /// Validity period.
  @JsonKey(name: r'validityPeriod', required: true, includeIfNull: true)
  final String? validityPeriod;

  /// Barcode.
  @JsonKey(name: r'barcode', required: true, includeIfNull: true)
  final String? barcode;

  /// National drug code.
  @JsonKey(name: r'nationalDrugCode', required: true, includeIfNull: true)
  final String? nationalDrugCode;

  /// Source URL.
  @JsonKey(name: r'sourceUrl', required: true, includeIfNull: true)
  final String? sourceUrl;

  /// Image URL.
  @JsonKey(name: r'imageUrl', required: true, includeIfNull: true)
  final String? imageUrl;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineDetailResponseDetailOneOf1 &&
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

  factory MedicineDetailResponseDetailOneOf1.fromJson(
    Map<String, dynamic> json,
  ) => _$MedicineDetailResponseDetailOneOf1FromJson(json);

  Map<String, dynamic> toJson() =>
      _$MedicineDetailResponseDetailOneOf1ToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum MedicineDetailResponseDetailOneOf1KindEnum {
  @JsonValue(r'cnProduct')
  cnProduct(r'cnProduct'),
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const MedicineDetailResponseDetailOneOf1KindEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
