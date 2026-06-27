// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'today_recommendation_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TodayRecommendationResponseDto _$TodayRecommendationResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('TodayRecommendationResponseDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['id', 'text']);
  final val = TodayRecommendationResponseDto(
    id: $checkedConvert('id', (v) => v as String),
    text: $checkedConvert('text', (v) => v as String),
    category: $checkedConvert('category', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$TodayRecommendationResponseDtoToJson(
  TodayRecommendationResponseDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'text': instance.text,
  if (instance.category != null) 'category': instance.category,
};
