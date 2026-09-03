//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'today_recommendation_response_dto_inner.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TodayRecommendationResponseDtoInner {
  /// Returns a new [TodayRecommendationResponseDtoInner] instance.
  TodayRecommendationResponseDtoInner({
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
      other is TodayRecommendationResponseDtoInner &&
          other.id == id &&
          other.text == text &&
          other.category == category;

  @override
  int get hashCode => id.hashCode + text.hashCode + category.hashCode;

  factory TodayRecommendationResponseDtoInner.fromJson(
    Map<String, dynamic> json,
  ) => _$TodayRecommendationResponseDtoInnerFromJson(json);

  Map<String, dynamic> toJson() =>
      _$TodayRecommendationResponseDtoInnerToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
