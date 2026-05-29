import 'package:flutter/material.dart';
import 'package:luminous/shared/design_tokens/design_tokens.dart';
import 'package:luminous/shared/widgets/tinted_status_chip.dart';

/// 今日页环境提醒小标签。
///
/// 用于展示花粉、紫外线等环境指标，包含图标、名称和等级文字。
class TodayEnvChip extends StatelessWidget {
  const TodayEnvChip({
    super.key,
    required this.icon,
    required this.label,
    required this.level,
    required this.accentColor,
  });

  /// 图标。
  final IconData icon;

  /// 指标名称（如 "花粉"、"紫外线"）。
  final String label;

  /// 等级文字（如 "较高"、"中等"）。
  final String level;

  /// 主题色。
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return TintedStatusChip(
      icon: icon,
      text: '$label $level',
      color: accentColor,
      fontSize: AppTypography.tab,
      fontWeight: FontWeight.w600,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
    );
  }
}
