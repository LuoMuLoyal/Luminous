//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'today_recommendation_response_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TodayRecommendationResponseDto {
  /// Returns a new [TodayRecommendationResponseDto] instance.
  TodayRecommendationResponseDto({
    required this.id,

    required this.text,

    this.category,
  });

  /// Unique recommendation id
  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  /// Recommendation text
  @JsonKey(name: r'text', required: true, includeIfNull: false)
  final String text;

  /// Recommendation category
  @JsonKey(name: r'category', required: false, includeIfNull: false)
  final String? category;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodayRecommendationResponseDto &&
          other.id == id &&
          other.text == text &&
          other.category == category;

  @override
  int get hashCode => id.hashCode + text.hashCode + category.hashCode;

  factory TodayRecommendationResponseDto.fromJson(Map<String, dynamic> json) =>
      _$TodayRecommendationResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TodayRecommendationResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
