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
};
