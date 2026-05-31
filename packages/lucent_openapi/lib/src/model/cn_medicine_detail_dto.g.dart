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
  'drugInteractions': ?instance.drugInteractions,
  'pharmacokinetics': ?instance.pharmacokinetics,
  'overdose': ?instance.overdose,
  'storage': ?instance.storage,
  'validityPeriod': ?instance.validityPeriod,
  'barcode': ?instance.barcode,
  'nationalDrugCode': ?instance.nationalDrugCode,
  'sourceUrl': ?instance.sourceUrl,
  'imageUrl': ?instance.imageUrl,
};
