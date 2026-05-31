// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medicine_detail_data_dto_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MedicineDetailDataDtoDetail _$MedicineDetailDataDtoDetailFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('MedicineDetailDataDtoDetail', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const [
      'kind',
      'groups',
      'categories',
      'atcCodes',
      'synonyms',
      'foodInteractions',
    ],
  );
  final val = MedicineDetailDataDtoDetail(
    kind: $checkedConvert('kind', (v) => v as String),
    drugType: $checkedConvert('drugType', (v) => v),
    state: $checkedConvert('state', (v) => v),
    description: $checkedConvert('description', (v) => v),
    indication: $checkedConvert('indication', (v) => v),
    mechanismOfAction: $checkedConvert('mechanismOfAction', (v) => v),
    pharmacodynamics: $checkedConvert('pharmacodynamics', (v) => v),
    toxicity: $checkedConvert('toxicity', (v) => v),
    metabolism: $checkedConvert('metabolism', (v) => v),
    absorption: $checkedConvert('absorption', (v) => v),
    halfLife: $checkedConvert('halfLife', (v) => v),
    proteinBinding: $checkedConvert('proteinBinding', (v) => v),
    routeOfElimination: $checkedConvert('routeOfElimination', (v) => v),
    volumeOfDistribution: $checkedConvert('volumeOfDistribution', (v) => v),
    clearance: $checkedConvert('clearance', (v) => v),
    groups: $checkedConvert(
      'groups',
      (v) => (v as List<dynamic>).map((e) => e as String).toList(),
    ),
    categories: $checkedConvert(
      'categories',
      (v) => (v as List<dynamic>).map((e) => e as String).toList(),
    ),
    atcCodes: $checkedConvert(
      'atcCodes',
      (v) => (v as List<dynamic>).map((e) => e as String).toList(),
    ),
    synonyms: $checkedConvert(
      'synonyms',
      (v) => (v as List<dynamic>).map((e) => e as String).toList(),
    ),
    foodInteractions: $checkedConvert(
      'foodInteractions',
      (v) => (v as List<dynamic>).map((e) => e as String).toList(),
    ),
    drugInteractions: $checkedConvert('drugInteractions', (v) => v),
    externalIdentifiers: $checkedConvert(
      'externalIdentifiers',
      (v) =>
          (v as Map<String, dynamic>?)?.map((k, e) => MapEntry(k, e as Object)),
    ),
    externalLinks: $checkedConvert(
      'externalLinks',
      (v) =>
          (v as Map<String, dynamic>?)?.map((k, e) => MapEntry(k, e as Object)),
    ),
    approvalNumber: $checkedConvert('approvalNumber', (v) => v),
    manufacturer: $checkedConvert('manufacturer', (v) => v),
    packageSpec: $checkedConvert('packageSpec', (v) => v),
    brandName: $checkedConvert('brandName', (v) => v),
    ingredients: $checkedConvert('ingredients', (v) => v),
    properties: $checkedConvert('properties', (v) => v),
    indications: $checkedConvert('indications', (v) => v),
    dosage: $checkedConvert('dosage', (v) => v),
    adverseReactions: $checkedConvert('adverseReactions', (v) => v),
    contraindications: $checkedConvert('contraindications', (v) => v),
    precautions: $checkedConvert('precautions', (v) => v),
    pediatricUse: $checkedConvert('pediatricUse', (v) => v),
    geriatricUse: $checkedConvert('geriatricUse', (v) => v),
    pregnancyLactation: $checkedConvert('pregnancyLactation', (v) => v),
    pharmacologyToxicology: $checkedConvert('pharmacologyToxicology', (v) => v),
    pharmacokinetics: $checkedConvert('pharmacokinetics', (v) => v),
    overdose: $checkedConvert('overdose', (v) => v),
    storage: $checkedConvert('storage', (v) => v),
    validityPeriod: $checkedConvert('validityPeriod', (v) => v),
    barcode: $checkedConvert('barcode', (v) => v),
    nationalDrugCode: $checkedConvert('nationalDrugCode', (v) => v),
    sourceUrl: $checkedConvert('sourceUrl', (v) => v),
    imageUrl: $checkedConvert('imageUrl', (v) => v),
  );
  return val;
});

Map<String, dynamic> _$MedicineDetailDataDtoDetailToJson(
  MedicineDetailDataDtoDetail instance,
) => <String, dynamic>{
  'kind': instance.kind,
  'drugType': ?instance.drugType,
  'state': ?instance.state,
  'description': ?instance.description,
  'indication': ?instance.indication,
  'mechanismOfAction': ?instance.mechanismOfAction,
  'pharmacodynamics': ?instance.pharmacodynamics,
  'toxicity': ?instance.toxicity,
  'metabolism': ?instance.metabolism,
  'absorption': ?instance.absorption,
  'halfLife': ?instance.halfLife,
  'proteinBinding': ?instance.proteinBinding,
  'routeOfElimination': ?instance.routeOfElimination,
  'volumeOfDistribution': ?instance.volumeOfDistribution,
  'clearance': ?instance.clearance,
  'groups': instance.groups,
  'categories': instance.categories,
  'atcCodes': instance.atcCodes,
  'synonyms': instance.synonyms,
  'foodInteractions': instance.foodInteractions,
  'drugInteractions': ?instance.drugInteractions,
  'externalIdentifiers': ?instance.externalIdentifiers,
  'externalLinks': ?instance.externalLinks,
  'approvalNumber': ?instance.approvalNumber,
  'manufacturer': ?instance.manufacturer,
  'packageSpec': ?instance.packageSpec,
  'brandName': ?instance.brandName,
  'ingredients': ?instance.ingredients,
  'properties': ?instance.properties,
  'indications': ?instance.indications,
  'dosage': ?instance.dosage,
  'adverseReactions': ?instance.adverseReactions,
  'contraindications': ?instance.contraindications,
  'precautions': ?instance.precautions,
  'pediatricUse': ?instance.pediatricUse,
  'geriatricUse': ?instance.geriatricUse,
  'pregnancyLactation': ?instance.pregnancyLactation,
  'pharmacologyToxicology': ?instance.pharmacologyToxicology,
  'pharmacokinetics': ?instance.pharmacokinetics,
  'overdose': ?instance.overdose,
  'storage': ?instance.storage,
  'validityPeriod': ?instance.validityPeriod,
  'barcode': ?instance.barcode,
  'nationalDrugCode': ?instance.nationalDrugCode,
  'sourceUrl': ?instance.sourceUrl,
  'imageUrl': ?instance.imageUrl,
};
