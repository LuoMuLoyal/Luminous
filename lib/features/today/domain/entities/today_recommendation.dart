import 'package:freezed_annotation/freezed_annotation.dart';

part 'today_recommendation.freezed.dart';

@freezed
abstract class TodayRecommendation with _$TodayRecommendation {
  const factory TodayRecommendation({
    required String id,
    required String text,
    String? category,
  }) = _TodayRecommendation;
}
