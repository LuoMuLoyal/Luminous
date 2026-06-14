// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_component_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HealthComponentDto _$HealthComponentDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('HealthComponentDto', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'name',
          'status',
          'critical',
          'durationMs',
          'error',
          'details',
        ],
      );
      final val = HealthComponentDto(
        name: $checkedConvert('name', (v) => v as String),
        status: $checkedConvert(
          'status',
          (v) => $enumDecode(
            _$HealthComponentStatusEnumMap,
            v,
            unknownValue: HealthComponentStatus.unknownDefaultOpenApi,
          ),
        ),
        critical: $checkedConvert('critical', (v) => v as bool),
        durationMs: $checkedConvert('durationMs', (v) => v as num),
        error: $checkedConvert('error', (v) => v as String?),
        details: $checkedConvert(
          'details',
          (v) => (v as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as Object),
          ),
        ),
      );
      return val;
    });

Map<String, dynamic> _$HealthComponentDtoToJson(HealthComponentDto instance) =>
    <String, dynamic>{
      'name': instance.name,
      'status': _$HealthComponentStatusEnumMap[instance.status]!,
      'critical': instance.critical,
      'durationMs': instance.durationMs,
      'error': instance.error,
      'details': instance.details,
    };

const _$HealthComponentStatusEnumMap = {
  HealthComponentStatus.up: 'up',
  HealthComponentStatus.down: 'down',
  HealthComponentStatus.unknownDefaultOpenApi: 'unknown_default_open_api',
};
