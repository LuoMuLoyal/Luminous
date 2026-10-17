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

  /// Canonical SMILES.
  @JsonKey(name: r'smiles', required: true, includeIfNull: true)
  final String? smiles;

  /// InChIKey hash.
  @JsonKey(name: r'inchiKey', required: true, includeIfNull: true)
  final String? inchiKey;

  /// Full InChI string.
  @JsonKey(name: r'inchiIdentifier', required: true, includeIfNull: true)
  final String? inchiIdentifier;

  /// Molecular formula.
  @JsonKey(name: r'formula', required: true, includeIfNull: true)
  final String? formula;

  /// IUPAC name.
  @JsonKey(name: r'iupacName', required: true, includeIfNull: true)
  final String? iupacName;

  /// Average molecular weight.
  @JsonKey(name: r'molecularWeight', required: true, includeIfNull: true)
  final num? molecularWeight;

  /// Monoisotopic exact mass.
  @JsonKey(name: r'exactMass', required: true, includeIfNull: true)
  final num? exactMass;

  /// Wildman-Crippen LogP.
  @JsonKey(name: r'logP', required: true, includeIfNull: true)
  final num? logP;

  /// Topological polar surface area (A^2).
  @JsonKey(name: r'polarSurfaceArea', required: true, includeIfNull: true)
  final num? polarSurfaceArea;

  /// Average polarizability.
  @JsonKey(name: r'polarizability', required: true, includeIfNull: true)
  final num? polarizability;

  /// Molar refractivity.
  @JsonKey(name: r'refractivity', required: true, includeIfNull: true)
  final num? refractivity;

  /// ALOGPS LogP.
  @JsonKey(name: r'alogpsLogP', required: true, includeIfNull: true)
  final num? alogpsLogP;

  /// ALOGPS water solubility (log).
  @JsonKey(name: r'alogpsLogS', required: true, includeIfNull: true)
  final num? alogpsLogS;

  /// ALOGPS water solubility with units, e.g. \"4.64e-02 g/l\".
  @JsonKey(name: r'alogpsSolubility', required: true, includeIfNull: true)
  final String? alogpsSolubility;

  /// Strongest pKa.
  @JsonKey(name: r'pka', required: true, includeIfNull: true)
  final num? pka;

  /// Strongest acidic pKa.
  @JsonKey(name: r'pkaStrongestAcidic', required: true, includeIfNull: true)
  final num? pkaStrongestAcidic;

  /// Strongest basic pKa.
  @JsonKey(name: r'pkaStrongestBasic', required: true, includeIfNull: true)
  final num? pkaStrongestBasic;

  /// Formal charge.
  // minimum: -9007199254740991
  // maximum: 9007199254740991
  @JsonKey(name: r'formalCharge', required: true, includeIfNull: true)
  final int? formalCharge;

  /// Charge at physiological pH.
  // minimum: -9007199254740991
  // maximum: 9007199254740991
  @JsonKey(name: r'physiologicalCharge', required: true, includeIfNull: true)
  final int? physiologicalCharge;

  /// Charge of the neutral form.
  // minimum: -9007199254740991
  // maximum: 9007199254740991
  @JsonKey(name: r'neutralCharge', required: true, includeIfNull: true)
  final int? neutralCharge;

  /// Average charge across neutral microspecies.
  @JsonKey(
    name: r'averageNeutralMicrospeciesCharge',
    required: true,
    includeIfNull: true,
  )
  final num? averageNeutralMicrospeciesCharge;

  /// Heavy atom count.
  // minimum: -9007199254740991
  // maximum: 9007199254740991
  @JsonKey(name: r'atomCount', required: true, includeIfNull: true)
  final int? atomCount;

  /// Number of rings.
  // minimum: -9007199254740991
  // maximum: 9007199254740991
  @JsonKey(name: r'ringCount', required: true, includeIfNull: true)
  final int? ringCount;

  /// Number of rotatable bonds.
  // minimum: -9007199254740991
  // maximum: 9007199254740991
  @JsonKey(name: r'rotatableBondCount', required: true, includeIfNull: true)
  final int? rotatableBondCount;

  /// Hydrogen-bond acceptors.
  // minimum: -9007199254740991
  // maximum: 9007199254740991
  @JsonKey(name: r'acceptorCount', required: true, includeIfNull: true)
  final int? acceptorCount;

  /// Hydrogen-bond donors.
  // minimum: -9007199254740991
  // maximum: 9007199254740991
  @JsonKey(name: r'donorCount', required: true, includeIfNull: true)
  final int? donorCount;

  /// Lipinski rule-of-five pass (1/0).
  // minimum: -9007199254740991
  // maximum: 9007199254740991
  @JsonKey(name: r'ruleOfFive', required: true, includeIfNull: true)
  final int? ruleOfFive;

  /// Veber oral bioavailability rule (1/0).
  // minimum: -9007199254740991
  // maximum: 9007199254740991
  @JsonKey(name: r'veberRule', required: true, includeIfNull: true)
  final int? veberRule;

  /// Ghose filter pass (1/0).
  // minimum: -9007199254740991
  // maximum: 9007199254740991
  @JsonKey(name: r'ghoseFilter', required: true, includeIfNull: true)
  final int? ghoseFilter;

  /// MDDR-like rule pass (1/0).
  // minimum: -9007199254740991
  // maximum: 9007199254740991
  @JsonKey(name: r'mddrLikeRule', required: true, includeIfNull: true)
  final int? mddrLikeRule;

  /// Bioavailability score class (0/1).
  // minimum: -9007199254740991
  // maximum: 9007199254740991
  @JsonKey(name: r'bioavailability', required: true, includeIfNull: true)
  final int? bioavailability;

  /// Salt forms.
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
