// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medicine_safety_tip_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MedicineSafetyTipResponseDto _$MedicineSafetyTipResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('MedicineSafetyTipResponseDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['id', 'text', 'category']);
  final val = MedicineSafetyTipResponseDto(
    id: $checkedConvert('id', (v) => v as String),
    text: $checkedConvert('text', (v) => v as String),
    category: $checkedConvert('category', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$MedicineSafetyTipResponseDtoToJson(
  MedicineSafetyTipResponseDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'text': instance.text,
  'category': instance.category,
};
