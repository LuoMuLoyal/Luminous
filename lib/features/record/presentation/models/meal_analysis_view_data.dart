import 'package:luminous/features/record/domain/constants/meal_calorie_range.dart';

/// View data for one meal analysis (contract v2).
///
/// v2 是**一次多模态分析直出**:热量区间 + 按重要性排序的结论 + 可编辑菜名。
/// 没有成分分解、没有食物成分表接地、没有人工确认——状态只有
/// `analyzing | analyzed | analysis_failed`。
class MealAnalysisViewData {
  const MealAnalysisViewData({
    required this.status,
    required this.failureReason,
    required this.calorieRange,
    required this.dishes,
    required this.items,
  });

  final String? status;

  /// 稳定失败原因码(`image_count_invalid` / `vision_unavailable` /
  /// `model_failed` / `model_timeout` / `invalid_output`);客户端据此做 l10n。
  final String? failureReason;

  final MealCalorieRangeViewData? calorieRange;

  /// 菜名(模型识别 + 用户改名);用户可编辑的只有这一份列表。
  final List<MealDishViewData> dishes;

  /// 按 `rank` 排序的结论,同一条既有列表用的 `headline` 也有一句话的 `detail`。
  final List<MealInsightViewData> items;

  bool get isAnalyzing => status == 'analyzing';
  bool get hasFailed => status == 'analysis_failed';
  bool get isAnalyzed => status == 'analyzed';

  /// 列表条目那一行:最重要的一条结论。
  String? get headline => items.isEmpty ? null : items.first.headline;
}

class MealCalorieRangeViewData {
  const MealCalorieRangeViewData({
    required this.min,
    required this.max,
    required this.bucket,
  });

  final int min;
  final int max;

  /// `low` / `medium` / `high`,只作配色语义。
  final String? bucket;

  /// 粗化到百位的展示区间(四舍五入),例如 `500–800`。
  ///
  /// 与列表角标同口径:实现集中在 [formatCoarseCalorieRange],不要在这里就地
  /// 重算,否则详情页与列表会对同一条记录显示不同的区间。
  String get coarseLabel => formatCoarseCalorieRange(min: min, max: max);
}

class MealDishViewData {
  const MealDishViewData({required this.name, required this.source});

  final String name;

  /// `model`(识别结果)或 `user`(用户改过名)。
  final String? source;

  bool get isUserEdited => source == 'user';
}

class MealInsightViewData {
  const MealInsightViewData({
    required this.rank,
    required this.kind,
    required this.polarity,
    required this.headline,
    required this.detail,
  });

  final int rank;

  /// 封闭词表(carb/fat/protein/vegetable/fruit/fried/sugar/sodium/portion/
  /// balance/other)——机器语义的唯一来源。
  final String? kind;

  /// `good` / `watch` / `neutral`。
  final String? polarity;

  final String headline;
  final String detail;
}
