import 'package:luminous/core/utils/type_conversion.dart';
import 'package:luminous/features/record/presentation/models/meal_analysis_view_data.dart';

/// 解析餐食 payload 的 `mealAnalysis`(契约 v2)。
///
/// payload 里只有 `mealAnalysis` 一个键;形状不匹配时返回 null,读路径不抛错
/// (与后端 `parseMealRecordPayload` 的「按没有分析处理」一致)。
MealAnalysisViewData? parseMealAnalysisViewData(Map<String, dynamic>? payload) {
  if (payload == null) return null;
  final analysis = asMap(payload['mealAnalysis']);
  if (analysis == null) return null;

  final status = asString(analysis['analysisStatus']);
  if (status == null) return null;

  return MealAnalysisViewData(
    status: status,
    failureReason: asString(analysis['failureReason']),
    calorieRange: _parseCalorieRange(analysis['calorieRange']),
    dishes: _parseDishes(analysis),
    items: _parseItems(analysis),
  );
}

/// 可编辑菜名列表(编辑页与详情页用);没有分析结果时为空。
List<String> parseMealDishNames(Map<String, dynamic>? payload) {
  final data = parseMealAnalysisViewData(payload);
  if (data == null) return const <String>[];
  return data.dishes.map((dish) => dish.name).toList(growable: false);
}

MealCalorieRangeViewData? _parseCalorieRange(Object? value) {
  final data = asMap(value);
  if (data == null) return null;
  final min = asNum(data['min'])?.round();
  final max = asNum(data['max'])?.round();
  if (min == null || max == null) return null;
  return MealCalorieRangeViewData(
    min: min,
    max: max,
    bucket: asString(data['bucket']),
  );
}

List<MealDishViewData> _parseDishes(Map<String, dynamic> analysis) {
  return asList(analysis['dishes'])
      .map(asMap)
      .whereType<Map<String, dynamic>>()
      .map((item) {
        final name = asString(item['name'])?.trim();
        if (name == null || name.isEmpty) return null;
        return MealDishViewData(name: name, source: asString(item['source']));
      })
      .whereType<MealDishViewData>()
      .toList(growable: false);
}

List<MealInsightViewData> _parseItems(Map<String, dynamic> analysis) {
  return asList(analysis['items'])
      .map(asMap)
      .whereType<Map<String, dynamic>>()
      .map((item) {
        final headline = asString(item['headline'])?.trim();
        final detail = asString(item['detail'])?.trim();
        if (headline == null || headline.isEmpty) return null;
        if (detail == null || detail.isEmpty) return null;
        return MealInsightViewData(
          rank: asNum(item['rank'])?.toInt() ?? 0,
          kind: asString(item['kind']),
          polarity: asString(item['polarity']),
          headline: headline,
          detail: detail,
        );
      })
      .whereType<MealInsightViewData>()
      .toList(growable: false)
    ..sort((a, b) => a.rank.compareTo(b.rank));
}
