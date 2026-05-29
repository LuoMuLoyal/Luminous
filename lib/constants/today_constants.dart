import 'package:flutter/material.dart';

/// 今日页全局常量。
///
/// 所有 UI 尺寸、默认值、Mock 数据均在此统一管理，
/// 避免魔法数字散落在 widget 代码中。
class TodayConstants {
  TodayConstants._();

  // ── 喝水追踪 ──

  /// 每日喝水目标次数（默认）。
  static const int defaultWaterGoal = 8;

  /// 喝水进度环尺寸。
  static const double waterRingSize = 80;

  /// 喝水进度环 strokeWidth。
  static const double waterRingStrokeWidth = 8;

  /// 喝水进度环背景透明度。
  static const double waterRingBgAlpha = 0.12;

  // ── 健康快照 ──

  /// 健康指标卡片圆角。
  static const double healthStatRadius = 12;

  /// 健康指标图标尺寸。
  static const double healthStatIconSize = 20;

  /// 健康指标数值字号。
  static const double healthStatValueFontSize = 16;

  /// 健康指标单位字号。
  static const double healthStatUnitFontSize = 11;

  /// 健康指标标签字号。
  static const double healthStatLabelFontSize = 12;

  /// 心率正常范围下限。
  static const int heartRateNormalLow = 60;

  /// 心率正常范围上限。
  static const int heartRateNormalHigh = 100;

  /// 收缩压正常范围下限。
  static const int systolicNormalLow = 90;

  /// 收缩压正常范围上限。
  static const int systolicNormalHigh = 140;

  /// 舒张压正常范围下限。
  static const int diastolicNormalLow = 60;

  /// 舒张压正常范围上限。
  static const int diastolicNormalHigh = 90;

  /// 睡眠时长正常范围下限（小时）。
  static const double sleepNormalLow = 6;

  /// 睡眠时长正常范围上限（小时）。
  static const double sleepNormalHigh = 9;

  // ── 用药提醒 ──

  /// 用药提醒卡片最大展示药品数。
  static const int medicationMaxDisplay = 3;

  // ── 环境提醒 ──

  /// 花粉指数「较低」上限。
  static const int pollenLowMax = 3;

  /// 花粉指数「中等」上限。
  static const int pollenMediumMax = 6;

  /// 紫外线指数「较弱」上限。
  static const int uvLowMax = 2;

  /// 紫外线指数「中等」上限。
  static const int uvMediumMax = 5;

  // ── 饮食建议 ──

  /// 饮食建议卡片圆角。
  static const double dietCardRadius = 14;

  /// 饮食建议图片尺寸。
  static const double dietImageSize = 56;

  // ── Lumi 建议 ──

  /// Lumi 头像尺寸。
  static const double lumiAvatarSize = 36;

  /// Lumi 建议卡片圆角。
  static const double lumiCardRadius = 16;

  // ── 区块间距 ──

  /// 页面顶部问候语下方间距。
  static const double greetingBottomSpacing = 16;

  /// 卡片之间垂直间距。
  static const double cardVerticalSpacing = 12;

  /// 卡片内部标题与内容间距。
  static const double cardTitleContentSpacing = 10;

  /// 卡片内部横向间距。
  static const double cardHorizontalPadding = 14;

  /// 卡片内部纵向间距。
  static const double cardVerticalPadding = 14;

  // ── Mock 数据 ──

  /// Mock: 今日喝水次数。
  static const int mockWaterIntake = 5;

  /// Mock: 心率值。
  static const int mockHeartRate = 72;

  /// Mock: 收缩压。
  static const int mockSystolic = 118;

  /// Mock: 舒张压。
  static const int mockDiastolic = 76;

  /// Mock: 睡眠时长（小时）。
  static const double mockSleepHours = 7.2;

  /// Mock: 待服药品数量。
  static const int mockPendingMedications = 1;

  /// Mock: 今日药品总数。
  static const int mockTotalMedications = 2;

  /// Mock: 下次服药时间。
  static const String mockNextMedicationTime = '12:00';

  /// Mock: 下次服药名称。
  static const String mockNextMedicationName = '阿托伐他汀';

  /// Mock: 花粉指数等级。
  static const String mockPollenLevel = '较高';

  /// Mock: 紫外线指数等级。
  static const String mockUvLevel = '中等';

  /// Mock: 饮食建议标题。
  static const String mockDietTitle = '高蛋白均衡餐';

  /// Mock: 饮食建议描述。
  static const String mockDietDescription = '鸡胸肉、藜麦、时蔬沙拉';

  /// Mock: Lumi 建议内容。
  static const String mockLumiAdvice = '今天空气干燥花粉较多，建议外出戴好口罩，注意防护呼吸道。';

  // ── 颜色语义 ──

  /// 喝水追踪主色（青蓝色）。
  static const Color waterPrimaryColor = Color(0xFF38BDF8);

  /// 心率色（玫红色）。
  static const Color heartRateColor = Color(0xFFEF4444);

  /// 血压色（橙色）。
  static const Color bloodPressureColor = Color(0xFFF97316);

  /// 睡眠色（靛蓝色）。
  static const Color sleepColor = Color(0xFF6366F1);

  /// 环境-花粉色（绿色）。
  static const Color pollenColor = Color(0xFF22C55E);

  /// 环境-紫外线色（琥珀色）。
  static const Color uvColor = Color(0xFFF59E0B);

  /// 用药提醒色（蓝紫色）。
  static const Color medicationColor = Color(0xFF8B5CF6);

  /// Lumi 建议色（翠绿色）。
  static const Color lumiColor = Color(0xFF10B981);
}
