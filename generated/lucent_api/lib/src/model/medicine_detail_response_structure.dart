//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medicine_detail_response_structure.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MedicineDetailResponseStructure {
  /// Returns a new [MedicineDetailResponseStructure] instance.
  MedicineDetailResponseStructure({
    required this.smiles,

    required this.inchiKey,

    required this.inchiIdentifier,

    required this.formula,

    required this.iupacName,

    required this.molecularWeight,

    required this.exactMass,

    required this.logP,

    required this.polarSurfaceArea,

    required this.polarizability,

    required this.refractivity,

    required this.alogpsLogP,

    required this.alogpsLogS,

    required this.alogpsSolubility,

    required this.pka,

    required this.pkaStrongestAcidic,

    required this.pkaStrongestBasic,

    required this.formalCharge,

    required this.physiologicalCharge,

    required this.neutralCharge,

    required this.averageNeutralMicrospeciesCharge,

    required this.atomCount,

    required this.ringCount,

    required this.rotatableBondCount,

    required this.acceptorCount,

    required this.donorCount,

    required this.ruleOfFive,

    required this.veberRule,

    required this.ghoseFilter,

    required this.mddrLikeRule,

    required this.bioavailability,

    required this.salts,
  });

  @JsonKey(name: r'smiles', required: true, includeIfNull: true)
  final String? smiles;

  @JsonKey(name: r'inchiKey', required: true, includeIfNull: true)
  final String? inchiKey;

  @JsonKey(name: r'inchiIdentifier', required: true, includeIfNull: true)
  final String? inchiIdentifier;

  @JsonKey(name: r'formula', required: true, includeIfNull: true)
  final String? formula;

  @JsonKey(name: r'iupacName', required: true, includeIfNull: true)
  final String? iupacName;

  @JsonKey(name: r'molecularWeight', required: true, includeIfNull: true)
  final num? molecularWeight;

  @JsonKey(name: r'exactMass', required: true, includeIfNull: true)
  final num? exactMass;

  @JsonKey(name: r'logP', required: true, includeIfNull: true)
  final num? logP;

  @JsonKey(name: r'polarSurfaceArea', required: true, includeIfNull: true)
  final num? polarSurfaceArea;

  @JsonKey(name: r'polarizability', required: true, includeIfNull: true)
  final num? polarizability;

  @JsonKey(name: r'refractivity', required: true, includeIfNull: true)
  final num? refractivity;

  @JsonKey(name: r'alogpsLogP', required: true, includeIfNull: true)
  final num? alogpsLogP;

  @JsonKey(name: r'alogpsLogS', required: true, includeIfNull: true)
  final num? alogpsLogS;

  @JsonKey(name: r'alogpsSolubility', required: true, includeIfNull: true)
  final String? alogpsSolubility;

  @JsonKey(name: r'pka', required: true, includeIfNull: true)
  final num? pka;

  @JsonKey(name: r'pkaStrongestAcidic', required: true, includeIfNull: true)
  final num? pkaStrongestAcidic;

  @JsonKey(name: r'pkaStrongestBasic', required: true, includeIfNull: true)
  final num? pkaStrongestBasic;

  // minimum: -9007199254740991
  // maximum: 9007199254740991
  @JsonKey(name: r'formalCharge', required: true, includeIfNull: true)
  final int? formalCharge;

  // minimum: -9007199254740991
  // maximum: 9007199254740991
  @JsonKey(name: r'physiologicalCharge', required: true, includeIfNull: true)
  final int? physiologicalCharge;

  // minimum: -9007199254740991
  // maximum: 9007199254740991
  @JsonKey(name: r'neutralCharge', required: true, includeIfNull: true)
  final int? neutralCharge;

  @JsonKey(
    name: r'averageNeutralMicrospeciesCharge',
    required: true,
    includeIfNull: true,
  )
  final num? averageNeutralMicrospeciesCharge;

  // minimum: -9007199254740991
  // maximum: 9007199254740991
  @JsonKey(name: r'atomCount', required: true, includeIfNull: true)
  final int? atomCount;

  // minimum: -9007199254740991
  // maximum: 9007199254740991
  @JsonKey(name: r'ringCount', required: true, includeIfNull: true)
  final int? ringCount;

  // minimum: -9007199254740991
  // maximum: 9007199254740991
  @JsonKey(name: r'rotatableBondCount', required: true, includeIfNull: true)
  final int? rotatableBondCount;

  // minimum: -9007199254740991
  // maximum: 9007199254740991
  @JsonKey(name: r'acceptorCount', required: true, includeIfNull: true)
  final int? acceptorCount;

  // minimum: -9007199254740991
  // maximum: 9007199254740991
  @JsonKey(name: r'donorCount', required: true, includeIfNull: true)
  final int? donorCount;

  // minimum: -9007199254740991
  // maximum: 9007199254740991
  @JsonKey(name: r'ruleOfFive', required: true, includeIfNull: true)
  final int? ruleOfFive;

  // minimum: -9007199254740991
  // maximum: 9007199254740991
  @JsonKey(name: r'veberRule', required: true, includeIfNull: true)
  final int? veberRule;

  // minimum: -9007199254740991
  // maximum: 9007199254740991
  @JsonKey(name: r'ghoseFilter', required: true, includeIfNull: true)
  final int? ghoseFilter;

  // minimum: -9007199254740991
  // maximum: 9007199254740991
  @JsonKey(name: r'mddrLikeRule', required: true, includeIfNull: true)
  final int? mddrLikeRule;

  // minimum: -9007199254740991
  // maximum: 9007199254740991
  @JsonKey(name: r'bioavailability', required: true, includeIfNull: true)
  final int? bioavailability;

  @JsonKey(name: r'salts', required: true, includeIfNull: true)
  final List<String>? salts;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineDetailResponseStructure &&
          other.smiles == smiles &&
          other.inchiKey == inchiKey &&
          other.inchiIdentifier == inchiIdentifier &&
          other.formula == formula &&
          other.iupacName == iupacName &&
          other.molecularWeight == molecularWeight &&
          other.exactMass == exactMass &&
          other.logP == logP &&
          other.polarSurfaceArea == polarSurfaceArea &&
          other.polarizability == polarizability &&
          other.refractivity == refractivity &&
          other.alogpsLogP == alogpsLogP &&
          other.alogpsLogS == alogpsLogS &&
          other.alogpsSolubility == alogpsSolubility &&
          other.pka == pka &&
          other.pkaStrongestAcidic == pkaStrongestAcidic &&
          other.pkaStrongestBasic == pkaStrongestBasic &&
          other.formalCharge == formalCharge &&
          other.physiologicalCharge == physiologicalCharge &&
          other.neutralCharge == neutralCharge &&
          other.averageNeutralMicrospeciesCharge ==
              averageNeutralMicrospeciesCharge &&
          other.atomCount == atomCount &&
          other.ringCount == ringCount &&
          other.rotatableBondCount == rotatableBondCount &&
          other.acceptorCount == acceptorCount &&
          other.donorCount == donorCount &&
          other.ruleOfFive == ruleOfFive &&
          other.veberRule == veberRule &&
          other.ghoseFilter == ghoseFilter &&
          other.mddrLikeRule == mddrLikeRule &&
          other.bioavailability == bioavailability &&
          other.salts == salts;

  @override
  int get hashCode =>
      (smiles == null ? 0 : smiles.hashCode) +
      (inchiKey == null ? 0 : inchiKey.hashCode) +
      (inchiIdentifier == null ? 0 : inchiIdentifier.hashCode) +
      (formula == null ? 0 : formula.hashCode) +
      (iupacName == null ? 0 : iupacName.hashCode) +
      (molecularWeight == null ? 0 : molecularWeight.hashCode) +
      (exactMass == null ? 0 : exactMass.hashCode) +
      (logP == null ? 0 : logP.hashCode) +
      (polarSurfaceArea == null ? 0 : polarSurfaceArea.hashCode) +
      (polarizability == null ? 0 : polarizability.hashCode) +
      (refractivity == null ? 0 : refractivity.hashCode) +
      (alogpsLogP == null ? 0 : alogpsLogP.hashCode) +
      (alogpsLogS == null ? 0 : alogpsLogS.hashCode) +
      (alogpsSolubility == null ? 0 : alogpsSolubility.hashCode) +
      (pka == null ? 0 : pka.hashCode) +
      (pkaStrongestAcidic == null ? 0 : pkaStrongestAcidic.hashCode) +
      (pkaStrongestBasic == null ? 0 : pkaStrongestBasic.hashCode) +
      (formalCharge == null ? 0 : formalCharge.hashCode) +
      (physiologicalCharge == null ? 0 : physiologicalCharge.hashCode) +
      (neutralCharge == null ? 0 : neutralCharge.hashCode) +
      (averageNeutralMicrospeciesCharge == null
          ? 0
          : averageNeutralMicrospeciesCharge.hashCode) +
      (atomCount == null ? 0 : atomCount.hashCode) +
      (ringCount == null ? 0 : ringCount.hashCode) +
      (rotatableBondCount == null ? 0 : rotatableBondCount.hashCode) +
      (acceptorCount == null ? 0 : acceptorCount.hashCode) +
      (donorCount == null ? 0 : donorCount.hashCode) +
      (ruleOfFive == null ? 0 : ruleOfFive.hashCode) +
      (veberRule == null ? 0 : veberRule.hashCode) +
      (ghoseFilter == null ? 0 : ghoseFilter.hashCode) +
      (mddrLikeRule == null ? 0 : mddrLikeRule.hashCode) +
      (bioavailability == null ? 0 : bioavailability.hashCode) +
      (salts == null ? 0 : salts.hashCode);

  factory MedicineDetailResponseStructure.fromJson(Map<String, dynamic> json) =>
      _$MedicineDetailResponseStructureFromJson(json);

  Map<String, dynamic> toJson() =>
      _$MedicineDetailResponseStructureToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
