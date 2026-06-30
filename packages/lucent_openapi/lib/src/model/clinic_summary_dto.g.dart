// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clinic_summary_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClinicSummaryDto _$ClinicSummaryDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ClinicSummaryDto', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'generatedAt',
          'dataRange',
          'profile',
          'allergies',
          'conditions',
          'currentMedicines',
          'disclaimer',
        ],
      );
      final val = ClinicSummaryDto(
        generatedAt: $checkedConvert('generatedAt', (v) => v as String),
        dataRange: $checkedConvert('dataRange', (v) => v as String),
        profile: $checkedConvert(
          'profile',
          (v) => ClinicSummaryProfileDto.fromJson(v as Map<String, dynamic>),
        ),
        allergies: $checkedConvert(
          'allergies',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
        conditions: $checkedConvert(
          'conditions',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
        currentMedicines: $checkedConvert(
          'currentMedicines',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
        findings: $checkedConvert(
          'findings',
          (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
        ),
        disclaimer: $checkedConvert('disclaimer', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$ClinicSummaryDtoToJson(ClinicSummaryDto instance) =>
    <String, dynamic>{
      'generatedAt': instance.generatedAt,
      'dataRange': instance.dataRange,
      'profile': instance.profile.toJson(),
      'allergies': instance.allergies,
      'conditions': instance.conditions,
      'currentMedicines': instance.currentMedicines,
      if (instance.findings != null) 'findings': instance.findings,
      'disclaimer': instance.disclaimer,
    };
