// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drugbank_medicine_detail_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DrugbankMedicineDetailDto _$DrugbankMedicineDetailDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('DrugbankMedicineDetailDto', json, ($checkedConvert) {
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
  final val = DrugbankMedicineDetailDto(
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
    drugInteractions: $checkedConvert(
      'drugInteractions',
      (v) =>
          (v as Map<String, dynamic>?)?.map((k, e) => MapEntry(k, e as Object)),
    ),
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
  );
  return val;
});

Map<String, dynamic> _$DrugbankMedicineDetailDtoToJson(
  DrugbankMedicineDetailDto instance,
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
};
