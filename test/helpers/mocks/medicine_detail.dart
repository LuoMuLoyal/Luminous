import 'package:lucent_api/lucent_api.dart';

/// A test-only [MedicineDetailResponseDetail] whose [toJson] returns the raw
/// detail JSON map supplied by the test.
///
/// The generated [MedicineDetailResponseDetail] has strongly typed fields, but
/// the medicine-risk domain code still reads the detail payload as a dynamic
/// map. Using this fake lets tests keep passing the old free-form JSON shape
/// (including list values such as `drugInteractions`) without needing to encode
/// them as the generated model's typed fields.
///
/// The regenerated client declares every field as a required constructor
/// parameter (nullable types included), so the remaining monograph fields are
/// filled with `null` — [toJson] is overridden and never reads them.
class TestMedicineDetailDataDtoDetail extends MedicineDetailResponseDetail {
  TestMedicineDetailDataDtoDetail(this._rawJson)
    : super(
        kind: 'generic',
        groups: const [],
        categories: const [],
        atcCodes: const [],
        synonyms: const [],
        foodInteractions: const [],
        drugType: null,
        state: null,
        description: null,
        indication: null,
        mechanismOfAction: null,
        pharmacodynamics: null,
        toxicity: null,
        metabolism: null,
        absorption: null,
        halfLife: null,
        proteinBinding: null,
        routeOfElimination: null,
        volumeOfDistribution: null,
        clearance: null,
        drugInteractions: null,
        externalIdentifiers: null,
        externalLinks: null,
        approvalNumber: null,
        manufacturer: null,
        packageSpec: null,
        brandName: null,
        ingredients: null,
        properties: null,
        indications: null,
        dosage: null,
        adverseReactions: null,
        contraindications: null,
        precautions: null,
        pharmacologyToxicology: null,
        pharmacokinetics: null,
        overdose: null,
        storage: null,
        validityPeriod: null,
        barcode: null,
        nationalDrugCode: null,
        sourceUrl: null,
        imageUrl: null,
      );

  final Map<String, dynamic> _rawJson;

  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.of(_rawJson);
}
