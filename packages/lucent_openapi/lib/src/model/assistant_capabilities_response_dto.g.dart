// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assistant_capabilities_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssistantCapabilitiesResponseDto _$AssistantCapabilitiesResponseDtoFromJson(
  Map<String, dynamic> json,
) =>
    $checkedCreate('AssistantCapabilitiesResponseDto', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['code', 'message', 'data']);
      final val = AssistantCapabilitiesResponseDto(
        code: $checkedConvert('code', (v) => v as num),
        message: $checkedConvert('message', (v) => v as String),
        data: $checkedConvert(
          'data',
          (v) =>
              AssistantCapabilitiesDataDto.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$AssistantCapabilitiesResponseDtoToJson(
  AssistantCapabilitiesResponseDto instance,
) => <String, dynamic>{
  'code': instance.code,
  'message': instance.message,
  'data': instance.data.toJson(),
};
