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
  if (instance.drugType != null) 'drugType': instance.drugType,
  if (instance.state != null) 'state': instance.state,
  if (instance.description != null) 'description': instance.description,
  if (instance.indication != null) 'indication': instance.indication,
  if (instance.mechanismOfAction != null)
    'mechanismOfAction': instance.mechanismOfAction,
  if (instance.pharmacodynamics != null)
    'pharmacodynamics': instance.pharmacodynamics,
  if (instance.toxicity != null) 'toxicity': instance.toxicity,
  if (instance.metabolism != null) 'metabolism': instance.metabolism,
  if (instance.absorption != null) 'absorption': instance.absorption,
  if (instance.halfLife != null) 'halfLife': instance.halfLife,
  if (instance.proteinBinding != null)
    'proteinBinding': instance.proteinBinding,
  if (instance.routeOfElimination != null)
    'routeOfElimination': instance.routeOfElimination,
  if (instance.volumeOfDistribution != null)
    'volumeOfDistribution': instance.volumeOfDistribution,
  if (instance.clearance != null) 'clearance': instance.clearance,
  'groups': instance.groups,
  'categories': instance.categories,
  'atcCodes': instance.atcCodes,
  'synonyms': instance.synonyms,
  'foodInteractions': instance.foodInteractions,
  if (instance.drugInteractions != null)
    'drugInteractions': instance.drugInteractions,
  if (instance.externalIdentifiers != null)
    'externalIdentifiers': instance.externalIdentifiers,
  if (instance.externalLinks != null) 'externalLinks': instance.externalLinks,
  if (instance.approvalNumber != null)
    'approvalNumber': instance.approvalNumber,
  if (instance.manufacturer != null) 'manufacturer': instance.manufacturer,
  if (instance.packageSpec != null) 'packageSpec': instance.packageSpec,
  if (instance.brandName != null) 'brandName': instance.brandName,
  if (instance.ingredients != null) 'ingredients': instance.ingredients,
  if (instance.properties != null) 'properties': instance.properties,
  if (instance.indications != null) 'indications': instance.indications,
  if (instance.dosage != null) 'dosage': instance.dosage,
  if (instance.adverseReactions != null)
    'adverseReactions': instance.adverseReactions,
  if (instance.contraindications != null)
    'contraindications': instance.contraindications,
  if (instance.precautions != null) 'precautions': instance.precautions,
  if (instance.pediatricUse != null) 'pediatricUse': instance.pediatricUse,
  if (instance.geriatricUse != null) 'geriatricUse': instance.geriatricUse,
  if (instance.pregnancyLactation != null)
    'pregnancyLactation': instance.pregnancyLactation,
  if (instance.pharmacologyToxicology != null)
    'pharmacologyToxicology': instance.pharmacologyToxicology,
  if (instance.pharmacokinetics != null)
    'pharmacokinetics': instance.pharmacokinetics,
  if (instance.overdose != null) 'overdose': instance.overdose,
  if (instance.storage != null) 'storage': instance.storage,
  if (instance.validityPeriod != null)
    'validityPeriod': instance.validityPeriod,
  if (instance.barcode != null) 'barcode': instance.barcode,
  if (instance.nationalDrugCode != null)
    'nationalDrugCode': instance.nationalDrugCode,
  if (instance.sourceUrl != null) 'sourceUrl': instance.sourceUrl,
  if (instance.imageUrl != null) 'imageUrl': instance.imageUrl,
};
