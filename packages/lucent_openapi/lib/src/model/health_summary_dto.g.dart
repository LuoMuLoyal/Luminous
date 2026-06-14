// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_summary_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HealthSummaryDto _$HealthSummaryDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('HealthSummaryDto', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['total', 'passed', 'failed']);
      final val = HealthSummaryDto(
        total: $checkedConvert('total', (v) => v as num),
        passed: $checkedConvert('passed', (v) => v as num),
        failed: $checkedConvert('failed', (v) => v as num),
      );
      return val;
    });

Map<String, dynamic> _$HealthSummaryDtoToJson(HealthSummaryDto instance) =>
    <String, dynamic>{
      'total': instance.total,
      'passed': instance.passed,
      'failed': instance.failed,
    };
