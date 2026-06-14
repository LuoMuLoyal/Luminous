// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_app_info_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HealthAppInfoDto _$HealthAppInfoDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('HealthAppInfoDto', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'name',
          'env',
          'pid',
          'uptimeSeconds',
          'memoryRssBytes',
          'memoryHeapUsedBytes',
        ],
      );
      final val = HealthAppInfoDto(
        name: $checkedConvert('name', (v) => v as String),
        env: $checkedConvert('env', (v) => v as String),
        pid: $checkedConvert('pid', (v) => v as num),
        uptimeSeconds: $checkedConvert('uptimeSeconds', (v) => v as num),
        memoryRssBytes: $checkedConvert('memoryRssBytes', (v) => v as num),
        memoryHeapUsedBytes: $checkedConvert(
          'memoryHeapUsedBytes',
          (v) => v as num,
        ),
      );
      return val;
    });

Map<String, dynamic> _$HealthAppInfoDtoToJson(HealthAppInfoDto instance) =>
    <String, dynamic>{
      'name': instance.name,
      'env': instance.env,
      'pid': instance.pid,
      'uptimeSeconds': instance.uptimeSeconds,
      'memoryRssBytes': instance.memoryRssBytes,
      'memoryHeapUsedBytes': instance.memoryHeapUsedBytes,
    };
