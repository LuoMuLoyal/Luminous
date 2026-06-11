// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_info_data_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppInfoDataDto _$AppInfoDataDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AppInfoDataDto', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const ['name', 'version', 'description', 'buildDate'],
  );
  final val = AppInfoDataDto(
    name: $checkedConvert('name', (v) => v as String),
    version: $checkedConvert('version', (v) => v as String),
    description: $checkedConvert('description', (v) => v as String),
    buildDate: $checkedConvert('buildDate', (v) => v as String),
    minClientVersion: $checkedConvert('minClientVersion', (v) => v as String?),
    supportEmail: $checkedConvert('supportEmail', (v) => v as String?),
    privacyPolicyUrl: $checkedConvert('privacyPolicyUrl', (v) => v as String?),
    termsOfServiceUrl: $checkedConvert(
      'termsOfServiceUrl',
      (v) => v as String?,
    ),
  );
  return val;
});

Map<String, dynamic> _$AppInfoDataDtoToJson(AppInfoDataDto instance) =>
    <String, dynamic>{
      'name': instance.name,
      'version': instance.version,
      'description': instance.description,
      'buildDate': instance.buildDate,
      if (instance.minClientVersion != null)
        'minClientVersion': instance.minClientVersion,
      if (instance.supportEmail != null) 'supportEmail': instance.supportEmail,
      if (instance.privacyPolicyUrl != null)
        'privacyPolicyUrl': instance.privacyPolicyUrl,
      if (instance.termsOfServiceUrl != null)
        'termsOfServiceUrl': instance.termsOfServiceUrl,
    };
