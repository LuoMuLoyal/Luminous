// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_probe_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HealthProbeDto _$HealthProbeDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('HealthProbeDto', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'probe',
          'status',
          'checkedAt',
          'app',
          'summary',
          'components',
        ],
      );
      final val = HealthProbeDto(
        probe: $checkedConvert(
          'probe',
          (v) => $enumDecode(
            _$HealthProbeTypeEnumMap,
            v,
            unknownValue: HealthProbeType.unknownDefaultOpenApi,
          ),
        ),
        status: $checkedConvert(
          'status',
          (v) => $enumDecode(
            _$HealthOverallStatusEnumMap,
            v,
            unknownValue: HealthOverallStatus.unknownDefaultOpenApi,
          ),
        ),
        checkedAt: $checkedConvert('checkedAt', (v) => v as String),
        app: $checkedConvert(
          'app',
          (v) => HealthAppInfoDto.fromJson(v as Map<String, dynamic>),
        ),
        summary: $checkedConvert(
          'summary',
          (v) => HealthSummaryDto.fromJson(v as Map<String, dynamic>),
        ),
        components: $checkedConvert(
          'components',
          (v) => (v as List<dynamic>)
              .map(
                (e) => HealthComponentDto.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$HealthProbeDtoToJson(HealthProbeDto instance) =>
    <String, dynamic>{
      'probe': _$HealthProbeTypeEnumMap[instance.probe]!,
      'status': _$HealthOverallStatusEnumMap[instance.status]!,
      'checkedAt': instance.checkedAt,
      'app': instance.app.toJson(),
      'summary': instance.summary.toJson(),
      'components': instance.components.map((e) => e.toJson()).toList(),
    };

const _$HealthProbeTypeEnumMap = {
  HealthProbeType.live: 'live',
  HealthProbeType.ready: 'ready',
  HealthProbeType.deep: 'deep',
  HealthProbeType.unknownDefaultOpenApi: 'unknown_default_open_api',
};

const _$HealthOverallStatusEnumMap = {
  HealthOverallStatus.ok: 'ok',
  HealthOverallStatus.error: 'error',
  HealthOverallStatus.unknownDefaultOpenApi: 'unknown_default_open_api',
};
