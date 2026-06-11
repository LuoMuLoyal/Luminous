// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'support_resource_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SupportResourceDto _$SupportResourceDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('SupportResourceDto', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['id', 'scope', 'title', 'available'],
      );
      final val = SupportResourceDto(
        id: $checkedConvert('id', (v) => v as String),
        scope: $checkedConvert(
          'scope',
          (v) => $enumDecode(
            _$SupportResourceScopeEnumMap,
            v,
            unknownValue: SupportResourceScope.unknownDefaultOpenApi,
          ),
        ),
        title: $checkedConvert('title', (v) => v as String),
        titleKey: $checkedConvert('titleKey', (v) => v as String?),
        subtitle: $checkedConvert('subtitle', (v) => v as String?),
        subtitleKey: $checkedConvert('subtitleKey', (v) => v as String?),
        icon: $checkedConvert('icon', (v) => v as String?),
        actionUrl: $checkedConvert('actionUrl', (v) => v as String?),
        actionType: $checkedConvert(
          'actionType',
          (v) => $enumDecodeNullable(
            _$SupportResourceActionTypeEnumMap,
            v,
            unknownValue: SupportResourceActionType.unknownDefaultOpenApi,
          ),
        ),
        available: $checkedConvert('available', (v) => v as bool),
      );
      return val;
    });

Map<String, dynamic> _$SupportResourceDtoToJson(SupportResourceDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'scope': _$SupportResourceScopeEnumMap[instance.scope]!,
      'title': instance.title,
      if (instance.titleKey != null) 'titleKey': instance.titleKey,
      if (instance.subtitle != null) 'subtitle': instance.subtitle,
      if (instance.subtitleKey != null) 'subtitleKey': instance.subtitleKey,
      if (instance.icon != null) 'icon': instance.icon,
      if (instance.actionUrl != null) 'actionUrl': instance.actionUrl,
      if (_$SupportResourceActionTypeEnumMap[instance.actionType] != null)
        'actionType': _$SupportResourceActionTypeEnumMap[instance.actionType],
      'available': instance.available,
    };

const _$SupportResourceScopeEnumMap = {
  SupportResourceScope.campus: 'campus',
  SupportResourceScope.help: 'help',
  SupportResourceScope.about: 'about',
  SupportResourceScope.unknownDefaultOpenApi: 'unknown_default_open_api',
};

const _$SupportResourceActionTypeEnumMap = {
  SupportResourceActionType.url: 'url',
  SupportResourceActionType.phone: 'phone',
  SupportResourceActionType.internal: 'internal',
  SupportResourceActionType.unknownDefaultOpenApi: 'unknown_default_open_api',
};
