// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'today_recommendation_response_dto.g.dart';

@JsonSerializable()
class TodayRecommendationResponseDto {
  const TodayRecommendationResponseDto({
    required this.id,
    required this.text,
    this.category,
  });

  factory TodayRecommendationResponseDto.fromJson(Map<String, Object?> json) =>
      _$TodayRecommendationResponseDtoFromJson(json);

  /// Unique recommendation id
  final String id;

  /// Recommendation text
  final String text;

  /// Recommendation category
  final String? category;

  Map<String, Object?> toJson() => _$TodayRecommendationResponseDtoToJson(this);
}
