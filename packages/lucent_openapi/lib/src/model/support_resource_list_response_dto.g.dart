// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'support_resource_list_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SupportResourceListResponseDto _$SupportResourceListResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SupportResourceListResponseDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['code', 'message', 'data']);
  final val = SupportResourceListResponseDto(
    code: $checkedConvert('code', (v) => v as num),
    message: $checkedConvert('message', (v) => v as String),
    data: $checkedConvert(
      'data',
      (v) => SupportResourceListDataDto.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$SupportResourceListResponseDtoToJson(
  SupportResourceListResponseDto instance,
) => <String, dynamic>{
  'code': instance.code,
  'message': instance.message,
  'data': instance.data.toJson(),
};
