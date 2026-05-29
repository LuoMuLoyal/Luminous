import 'package:flutter/material.dart';
import 'package:luminous/constants/app_ui_constants.dart';
import 'package:luminous/constants/today_constants.dart';
import 'package:luminous/shared/design_tokens/design_tokens.dart';

/// 今日页健康指标统计卡片。
///
/// 展示单项健康指标（心率、血压、睡眠等），包含图标、数值、单位和标签。
/// 适用于健康快照区域的横向排列。
class TodayStatCard extends StatelessWidget {
  const TodayStatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.unit,
    required this.label,
    required this.accentColor,
    this.valueFontSize = TodayConstants.healthStatValueFontSize,
    this.unitFontSize = TodayConstants.healthStatUnitFontSize,
    this.labelFontSize = TodayConstants.healthStatLabelFontSize,
    this.iconSize = TodayConstants.healthStatIconSize,
  });

  /// 左侧图标。
  final IconData icon;

  /// 指标数值文本。
  final String value;

  /// 数值单位文本（如 次/分、mmHg、小时）。
  final String unit;

  /// 底部标签文本（如 心率、血压、睡眠）。
  final String label;

  /// 主题色（图标和背景 tint）。
  final Color accentColor;

  final double valueFontSize;
  final double unitFontSize;
  final double labelFontSize;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = theme.cardTheme.color ?? theme.colorScheme.surface;
    final tintedBg = Color.alphaBlend(
      accentColor.withValues(alpha: isDark ? 0.16 : 0.08),
      cardBg,
    );
    final textPrimary = isDark
        ? AppUiConstants.TEXT_PRIMARY_DARK
        : AppUiConstants.TEXT_PRIMARY;
    final textMuted = AppUiConstants.TEXT_MUTED;

    return Container(
      padding: AppSpacing.allCard,
      decoration: BoxDecoration(
        color: tintedBg,
        borderRadius: BorderRadius.circular(TodayConstants.healthStatRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: iconSize, color: accentColor),
          SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: valueFontSize,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                  height: 1.1,
                ),
              ),
              SizedBox(width: AppSpacing.xxs),
              Text(
                unit,
                style: TextStyle(
                  fontSize: unitFontSize,
                  fontWeight: FontWeight.w500,
                  color: textMuted,
                  height: 1.1,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xxs),
          Text(
            label,
            style: TextStyle(
              fontSize: labelFontSize,
              fontWeight: FontWeight.w500,
              color: textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
