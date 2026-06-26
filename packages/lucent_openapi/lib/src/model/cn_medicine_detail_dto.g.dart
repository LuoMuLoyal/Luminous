// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cn_medicine_detail_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CnMedicineDetailDto _$CnMedicineDetailDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CnMedicineDetailDto', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['kind']);
      final val = CnMedicineDetailDto(
        kind: $checkedConvert('kind', (v) => v as String),
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
        pregnancy: $checkedConvert('pregnancy', (v) => v),
        lactation: $checkedConvert('lactation', (v) => v),
        pharmacologyToxicology: $checkedConvert(
          'pharmacologyToxicology',
          (v) => v,
        ),
        drugInteractions: $checkedConvert('drugInteractions', (v) => v),
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

Map<String, dynamic> _$CnMedicineDetailDtoToJson(
  CnMedicineDetailDto instance,
) => <String, dynamic>{
  'kind': instance.kind,
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
  if (instance.pregnancy != null) 'pregnancy': instance.pregnancy,
  if (instance.lactation != null) 'lactation': instance.lactation,
  if (instance.pharmacologyToxicology != null)
    'pharmacologyToxicology': instance.pharmacologyToxicology,
  if (instance.drugInteractions != null)
    'drugInteractions': instance.drugInteractions,
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
